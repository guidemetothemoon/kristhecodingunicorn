---
author: "Kristina Devochko"
title: "Setting up OAuth 2.0 authentication for applications in AKS with AGIC and OAuth2 Proxy"
date: "2023-09-17"
description: "This blog post explains how to enable OAuth 2.0 authentication for an application running in AKS with help of Application Gateway Ingress Controller (AGIC) and OAuth2 Proxy."
draft: true
tags: [
    "kubernetes",
    "aks",
    "k8s",
    "agic",
    "ingress-controller",
    "auth",
    "oauth",
    "oauth2-proxy"
]
slug: "aks-oauth2-proxy-with-agic"
aliases: ["k8s_agic_oauth"]
---

## Introduction

This blog post is a continuation of an extensive blog post about OAuth2 Proxy, which I published earlier: [Setting Up OAuth 2.0 Authentication for Applications in AKS With NGINX and OAuth2 Proxy](https://kristhecodingunicorn.com/post/aks-oauth2-proxy-with-nginx-ingress-controller). In the original blog post NGINX Ingress Controller was used in AKS clusters, while this blog post will look into how authentication with OAuth2 Proxy can be implemented when AKS clusters are configured with Application Gateway Ingress Controller (AGIC). Multiple steps for setting up OAuth2 Proxy are similar to the ones described in the original blog post, therefore those will be linked here directly to avoid content duplication. To get most value out of this content I will strongly recommend to check out the original blog post or links to its specific sections that will be provided as part of this blog post.

Last time we talked about how you can implement OAuth 2.0 authentication for applications that are running in Azure Kubernetes Service with NGINX Ingress Controller. [OAuth2 Proxy](https://github.com/oauth2-proxy/oauth2-proxy) is a popular open source tool that is widely adopted in the tech community and makes it relatively straightforward to set up OAuth 2.0 authentication.

The process of setting up OAuth2 Proxy in AKS with Application Gateway Ingress Controller (AGIC) is pretty similar to how it's done when NGINX Ingress Controller is used, but there are still some differences that's worth knowing about. For this use case we'll be using Microsoft Entra (previously known as Azure Active Directory) as an identity provider.

Let's get to it!😼

## Deploy OAuth2 Proxy in AKS with AGIC

We'll need to perform following steps in order to integrate authentication with OAuth 2.0 and Microsoft Entra for our applications running in Azure Kubernetes Service and utilizing Application Gateway Ingress Controller for exposing the respective applications for public access:

1. Create an application in Microsoft Entra which will act on behalf of OAuth2 Proxy application and perform authentication of users attempting to access the respective application towards Microsoft Entra.

2. Deploy application with Ingress object to expose it for public access.

3. Deploy OAuth2 Proxy Helm chart that will run in front of the application and act as a reverse proxy that will enforce authentication prior to accessing the application.

> Please note that you also need to have a custom domain with a respective DNS A record pointing to AGIC public IP so that application is exposed for public access on the respective public URL of your choice. In addition you would need to have a certificate authority (CA) for TLS certificate provisioning. Setting up these components are out of scope for this blog post, but I would recommend to check out resources that are provided in the end of the blog post, that are related to cert-manager and hosting your domain in Azure DNS, for more information.

### 1 - Create Microsoft Entra application

This step is performed in the same way as when OAuth2 Proxy is set up towards AKS with NGINX Ingress Controller. An application registration will need to be done in Microsoft Entra with the respective ```<PUBLIC_APPLICATION_URL>/oauth2/callback``` redirect URI. In the example used in this blog post redirect URI will be ```https://chaos-nyan-cat.kristechlab.space/oauth2/callback```. Please follow the instructions outlined in the following link on how to create an application in Microsoft Entra which will act on behalf of OAuth2 Proxy: [Create OAuth2 Proxy application in Microsoft Entra ID](https://kristhecodingunicorn.com/post/aks-oauth2-proxy-with-nginx-ingress-controller#create-oauth2-proxy-application-in-microsoft-entra-id).

### 2 - Deploy application with Ingress

In this example we will use a simple static test application called ```chaos-nyan-cat```. For that I have created a Kubernetes YAML manifest that will deploy following resources once it's applied on an AKS cluster:

- Namespace where all the application resources will be deployed;
- Deployment with 1 replica of the application using an image that is publicly available on Docker Hub;
- Service that will run in front of the application Pods (i.e. replicas) and route traffic to the healthy Pods;
- Ingress that will expose the application for public access at ```https://chaos-nyan-cat.kristechlab.space``` via HTTPS with TLS certificate that's provisioned and managed by cert-manager that's deployed in the AKS cluster. ```kubernetes.io/ingress.class: azure/application-gateway``` annotation tells the Ingress that AGIC is used in this AKS cluster and this deployment will be managed by it.

``` yaml
# chaos-nyan-cat-deploy.yaml

apiVersion: v1
kind: Namespace
metadata:
  labels:
    kubernetes.io/metadata.name: chaos-nyan-cat
  name: chaos-nyan-cat
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: chaos-nyan-cat
  namespace: chaos-nyan-cat
spec:
  replicas: 1
  selector:
    matchLabels:
      app: chaos-nyan-cat
  template:
    metadata:
      labels:
        app: chaos-nyan-cat
    spec:
      containers:
      - name: chaos-nyan-cat
        image: guidemetothemoon/kube-nyan-cat:latest
        ports:
        - name: http
          containerPort: 80
          protocol: TCP
---
apiVersion: v1
kind: Service
metadata:
  name: chaos-nyan-cat-svc
  namespace: chaos-nyan-cat
spec:
  type: ClusterIP
  ports:
  - port: 80
    targetPort: http
    protocol: TCP
    name: http
  selector:
    app: chaos-nyan-cat
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: chaos-nyan-cat-ingress
  namespace: chaos-nyan-cat
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway # Required annotation for Application Gateway Ingress Controller
    cert-manager.io/cluster-issuer: letsencrypt-prod # TLS certificate provisioning with cert-manager and Let's Encrypt
    appgw.ingress.kubernetes.io/backend-path-prefix: "/" # Target URI where the traffic must be redirected
    appgw.ingress.kubernetes.io/ssl-redirect: "true" # Redirect to HTTPS
spec:
  tls:
  - hosts:
    - chaos-nyan-cat.kristechlab.space
    secretName: chaos-nyan-cat-secret
  rules:
  - host: chaos-nyan-cat.kristechlab.space
    http:
      paths:
      - backend:
          service:
            name: chaos-nyan-cat-svc
            port:
              number: 80
        path: /
        pathType: Prefix
```

We can deploy it with ```kubectl apply -f ./chaos-nyan-cat-deploy.yaml``` and thereafter access the application at ```https://chaos-nyan-cat.kristechlab.space```!

![Screenshot of deploying the chaos-nyan-cat application with Ingress via Kubernetes YAML manifests to AKS](../../images/k8s_oauth2_proxy/k8s_oauth2_agic_app_deploy.webp)

Since we haven't deployed any OAuth2 Proxy in front yet we can access the application directly without any authentication. Now, let's fix it!

### 3 - Deploy OAuth2 Proxy in front of the application

Now that we've create a Microsoft Entra application for OAuth2 Proxy and deployed our application we're ready to put OAuth2 Proxy in front of it and get that OAuth 2.0 authentication up and running. In this example I will be deploying OAuth2 Proxy Helm chart with minimal configuration, but you can check the original blog post for more details on how to deploy OAuth2 Proxy with Kubernetes YAML manifests for instance: [Configure and deploy OAuth2 Proxy](https://kristhecodingunicorn.com/post/aks-oauth2-proxy-with-nginx-ingress-controller#configure-and-deploy-oauth2-proxy).

Personally I prefer using OAuth2 Proxy Helm chart, because it's so much easier to maintain and configure, as well as it can install multiple additional components like Redis so that I don't need to do it manually myself. All we need to do is to create a Helm values YAML file where we will define the configuration for OAuth2 Proxy deployment based on the need of our application. Below you may see an example of such configuration with the following highlights:

- Install of Redis as a session storage to ensure that in case the session cookie coming from Microsoft Entra is too big which is a quite frequent case, we will have enough space to store it in Redis instead of using default client-side cookie storage.
- Enable Ingress with the user application public URI so that every time someone attempts to access the application, authentication via OAuth2 Proxy will be requested first.
- Provide Ingress annotations to ensure that OAuth2 Proxy Ingress is also managed via AGIC and traffic is flowing through HTTPS with a valid TLS certificate.
- Provide information about the configured Microsoft Entra application for OAuth2 Proxy: client id and client secret. In addition provide a cookie secret for session information storage (see [Cookie Secret](https://kristhecodingunicorn.com/post/aks-oauth2-proxy-with-nginx-ingress-controller#cookie-secret) for more details on generating a cookie secret). Store this configuration as Kubernetes Secrets (you can also take it a step further and integrate Azure Key Vault Provider for Secrets Store CSI Driver).
- Provide OAuth2 Proxy specific configuration where we define the generic OIDC provider to be used (you can also use azure as a value here but be cautious of following known issue: [OAuth2 Proxy version 7.3.0 - Issue with Azure provider](https://kristhecodingunicorn.com/post/aks-oauth2-proxy-with-nginx-ingress-controller#version-730---issue-with-azure-provider)), which Microsoft Entra tenant id to use for authentication and where to redirect after authentication is performed successfully. We also define that we want to skip OAuth2 Proxy specific UI and redirect to the respective provider's authentication UI directly.

Let's take a closer look at the ```upstreams``` parameter: TODO

You can find more configuration parameters in the official documentation: [OAuth2 Proxy - Command Line Options](https://oauth2-proxy.github.io/oauth2-proxy/docs/configuration/overview/#command-line-options).

``` yaml
# oauth2-proxy-values.yaml

redis:
  enabled: true
sessionStorage:
  type: redis
ingress:
  enabled: true
  hosts:
    - chaos-nyan-cat.kristechlab.space
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway # Required annotation for Application Gateway Ingress Controller
    cert-manager.io/cluster-issuer: letsencrypt-prod # TLS certificate provisioning with cert-manager and Let's Encrypt
    appgw.ingress.kubernetes.io/backend-path-prefix: "/" # Target URI where the traffic must be redirected
    appgw.ingress.kubernetes.io/ssl-redirect: "true" # Redirect to HTTPS
  tls:
    - secretName: chaos-nyan-cat-oauth2-proxy-secret
      hosts:
        - chaos-nyan-cat.kristechlab.space
proxyVarsAsSecrets: true # Use Kubernetes secrets instead of environment values for setting up OAUTH2_PROXY variables
config:
  cookieName: proxycookie
  clientID: <MICROSOFT_ENTRA_APP_CLIENT_ID>
  clientSecret: <MICROSOFT_ENTRA_APP_CLIENT_SECRET>
  cookieSecret: <OAUTH2_PROXY_COOKIE_SECRET>
  configFile: |-
        email_domains = [ "*" ]
        azure_tenant = "<MICROSOFT_ENTRA_APP_TENANT_ID>"
        oidc_issuer_url = "https://login.microsoftonline.com/<MICROSOFT_ENTRA_APP_TENANT_ID>/v2.0"
        upstreams = [ "http://chaos-nyan-cat-svc.chaos-nyan-cat.svc.cluster.local:80" ]
        provider = "oidc"
        skip_provider_button = true
podLabels:
  application: chaos-nyan-cat-oauth2-proxy
customLabels:
  application: chaos-nyan-cat-oauth2-proxy
replicaCount: 1
```

We can now deploy OAuth2 Proxy with ```helm upgrade chaos-nyan-cat-oauth2-proxy oauth2-proxy/oauth2-proxy --install -n chaos-nyan-cat -f ./oauth2-proxy-values.yaml``` command and once all the Pods are running we can see that Microsoft authentication is being enforced when we attempt to access our application at ```https://chaos-nyan-cat.kristechlab.space```, which is what we were trying to achieve!

To sum it up, the flow of setting up OAuth2 Proxy for applications running in AKS with AGIC is pretty similar to when NGINX Ingress Controller is used. Two significant differences are:

- It's not needed to add NGINX-related annotations on the Ingress object of your application;
- OAuth2 Proxy upstream configuration should point to the Service TODO

## Additional resources

Below you may find a few additional resources to learn more about Application Gateway Ingress Controller on AKS and OAuth2 Proxy:

- [Setting Up OAuth 2.0 Authentication for Applications in AKS With NGINX and OAuth2 Proxy](https://kristhecodingunicorn.com/post/aks-oauth2-proxy-with-nginx-ingress-controller)

- [What is Application Gateway Ingress Controller?](https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview)

- [Tutorial: Enable the ingress controller add-on for a new AKS cluster with a new application gateway instance](https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new)

- [Tutorial: Enable application gateway ingress controller add-on for an existing AKS cluster with an existing application gateway](https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing)

- [OAuth2 Proxy Documentation](https://oauth2-proxy.github.io/oauth2-proxy/docs)

- [GitHub repo: OAuth2 Proxy](https://github.com/oauth2-proxy/oauth2-proxy)

- [cert-manager: open source certificate management tool](https://cert-manager.io/docs/installation)

- [Host your domain on Azure DNS](https://learn.microsoft.com/en-us/training/modules/host-domain-azure-dns)

That's it from me this time, thanks for checking in!
If this article was helpful, I'd love to hear about it! You can reach out to me on LinkedIn, GitHub or BlueSky 😊

Stay secure, stay safe.
Till we connect again!😼
