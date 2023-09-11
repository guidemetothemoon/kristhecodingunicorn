+++
author = "Kristina D."
title = "Setting up OAuth 2.0 authentication for applications in AKS with AGIC and OAuth2 Proxy"
date = "2023-09-15"
description = "This blog post explains how to enable OAuth 2.0 authentication for an application running in AKS with help of Application Gateway Ingress Controller (AGIC) and OAuth2 Proxy."
draft = true
tags = [
    "kubernetes",
    "aks",
    "k8s",
    "agic",
    "ingress-controller",
    "auth",
    "oauth",
    "oauth2-proxy"
]
+++

{{< table_of_contents >}}

This blog post is a continuation of an extensive blog post about OAuth2 Proxy, which I published earlier: [Setting Up OAuth 2.0 Authentication for Applications in AKS With NGINX and OAuth2 Proxy](https://kristhecodingunicorn.com/post/k8s_nginx_oauth). In the original blog post NGINX Ingress Controller was deployed in AKS clusters, while this blog post will look into how authentication with OAuth2 Proxy can be implemented when AKS clusters are configured with Application Gateway Ingress Controller (AGIC). Multiple steps for setting up OAuth2 Proxy are similar to the ones described in the original blog post, therefore those will be linked here directly to avoid content duplication. To get most value out of this content I will strongly recommend to check out the original blog post or links to its specific sections that will be provided as part of this blog post.

TODO

## Additional resources

Below you may find a few additional resources to learn more about Application Gateway Ingress Controller on AKS and OAuth2 Proxy:

- [Setting Up OAuth 2.0 Authentication for Applications in AKS With NGINX and OAuth2 Proxy](https://kristhecodingunicorn.com/post/k8s_nginx_oauth)

- [What is Application Gateway Ingress Controller?](https://learn.microsoft.com/en-us/azure/application-gateway/ingress-controller-overview)

- [Tutorial: Enable the ingress controller add-on for a new AKS cluster with a new application gateway instance](https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-new)

- [Tutorial: Enable application gateway ingress controller add-on for an existing AKS cluster with an existing application gateway](https://learn.microsoft.com/en-us/azure/application-gateway/tutorial-ingress-controller-add-on-existing)

- [OAuth2 Proxy Documentation](https://oauth2-proxy.github.io/oauth2-proxy/docs)

- [GitHub repo: OAuth2 Proxy](https://github.com/oauth2-proxy/oauth2-proxy)

That's it from me this time, thanks for checking in!💖

If this article was helpful, I'd love to hear about it! You can reach out to me on LinkedIn, Twitter, GitHub or by using the contact form on this page.😺

Stay secure, stay safe.

Till we connect again!😻
