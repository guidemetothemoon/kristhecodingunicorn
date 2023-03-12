+++
author = "Kristina D."
title = "Keeping AKS clusters continuously secure with Azure Policy"
date = "2023-03-11"
description = "In this blog post we'll look into how we can enhance security and governance of AKS clusters with Azure Policy."
draft = true
tags = [
    "kubernetes",
    "aks",
    "k8s",
    "azure",
    "devops"
]
+++

![Article banner for enhancing security in AKS with Azure Policy](../../images/k8s_azure_policy/aks_azure_policy_banner.png)

{{< table_of_contents >}}

🐇***This blog post is also a contribution to Azure Spring Clean 2023 where during 5 weekdays of March, 13th-17th, community contributors will share learning resources that highlight best-practices, lessons learned, and help with some of the more difficult topics of Azure Management. You're welcome to check out all the contributions here:*** [Azure Spring Clean 2023](https://www.azurespringclean.com)

As you may know already, Kubernetes doesn't come with 100% built-in security by default. The same applies for managed Kubernetes service offerings like Azure Kubernetes Service (AKS). Some cloud providers offer more hardened default configuration for a managed Kubernetes service, some offer less hardened and more beginner-friendly default configuration, but the fact stays the fact - cloud services are a shared responsibility. It means that you're responsible to properly harden and secure Kubernetes clusters that you're provisioning in the cloud, also in Azure.

**But is there a way that can help you make this process easier and ensure continuous compliance and security?**

There are multiple ways to the goal indeed, and one of the ways is called Azure Policy. Now let's dig into what Azure Policy is and how it can be applied to AKS. 😼

## AzPolicy 💜 K8s: Introduction and highlights

If you're not familiar with Azure Policy and are working (or planning to work) with Azure, I definitely recommend you to start using it asap. Azure Policy is a service that provides you with a collection of rules, aka policy definitions, that you can enforce in order to ensure proper automatic and continuous governance and compliance of your Azure workloads, and even hybrid workloads like Azure Arc resources. You can also create custom policies to govern the areas that are not covered by the default collection of policies. We'll shortly see how you can combine both default and custom policies to govern AKS clusters.😺

You're welcome to check out the [Additional resources](https://kristhecodingunicorn.com/post/aks_azure_policy#additional-resources) section in the bottom of this blog post for more learning material on Azure Policy.

Azure Policy has a dedicated category called **"Kubernetes"** which contains all the built-in policy definitions that can be applied to AKS and Azure Arc-enabled Kubernetes clusters. You can use this category as a filter to quickly get access to all the policies that can be applied to Kubernetes clusters and workloads.

![Screenshot of Azure Policy category for Kubernetes in Azure portal](../../images/k8s_azure_policy/aks_azpolicy_category.png)

**So, how does Kubernetes governance with Azure Policy work behind the scenes?** Once enabled, Azure Policy is installed as an add-on in the respective AKS clusters. Azure Policy for Kubernetes is based on extension of Gatekeeper v3 which is an admission controller webhook for Open Policy Agent (OPA). OPA is an open source policy agent that is widely used for governance of not only Kubernetes in general but also a bunch of different services like API gateways, CI/CD pipelines, event streaming platforms like Apache Kafka, etc. 

The way that Azure Policy for Kubernetes was implemented comes with an additional benefit when it comes to extensibility: since the implementation is based on top of an existing open source technology that is widely used in the industry, it allows us to extend governance to those areas which are not covered by the built-in policy definitions. We can do that by creating custom Azure Policy definitions and use OPA's policy language called Rego to define the Constraints and ConstraintTemplates that we want to be used for custom policy enforcement and evaluation.

I will not go through all the built-in Azure policy definitions that are included in the Kubernetes category - most of them have a well-defined, helpful description. It's important to highlight though that most of the built-in policies represent security controls that are required by security frameworks like OWASP Top 10 for Docker/Kubernetes, CIS Kubernetes/Docker Benchmark, Kubernetes Hardening Guidance and AKS security baseline. Therefore, enforcing Azure Policy definitions in your AKS clusters and acting upon and remediating findings from the policy evaluation will help you ensure and document continuous compliance with the well-established security frameworks and standards, which may be required by your users and customers.

Another interesting highlight is that in Kubernetes category in Azure Policy definitions list you can find two policy initiatives that represent a purposefully created collection of policy definitions that will be enabled together as a result of enabling the policy initiative itself. Policy initiative will be marked as compliant once all the resources are compliant with all policy definitions that are part of the policy initiative. You can see mentioned policy initiatives in the screenshot below. These initiatives represent Kubernetes Pod Security Standards (PSS) - a collection of best practices for implementing baseline (minimally restrictive) and heavily restricted security level for Kubernetes workloads. PSS are established and maintained by the Kubernetes community and you can find a detailed overview of all the policies in official Kubernetes documentation (link provided below).

![Screenshot of Azure Policy initiative for Kubernetes in Azure portal](../../images/k8s_azure_policy/aks_azpolicy_initiatives.png)

Now, let's take a look at how we can implement Azure Policy for Kubernetes in practice.😼

## AzPolicy 💜 K8s: Practical walkthrough

It's time to get more hands-on! In this walkthrough we'll see what pre-requisites are needed in order to start using Azure Policy for Kubernetes, and how to enforce built-in and custom policies in AKS clusters - both through Azure portal and infrastructure-as-code with Terraform.

### Azure Policy add-on

In order to start using Azure Policy for Kubernetes you need to enable Azure Policy add-on on the clusters that you want to govern. Once enabled, it will deploy Gatekeeper and Azure Policy Pods in the respective clusters:

![Screenshot of the Gatekeeper and Azure Policy Pods that are deployed in every AKS cluster by the Azure Policy add-on](../../images/k8s_azure_policy/aks_azpolicy_addon_pods.png)

Please note that the more resources need to be evaluated the more resources will be consumed by Azure Policy and Gatekeeper components in the cluster. You need therefore to ensure that you have enough resources to begin with and can scale accordingly in order to avoid unpredictably failing audit and enforcement operations. Please check general [Recommendations](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes#recommendations) and [Limitations](https://learn.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes#limitations) for using Azure Policy add-on for Kubernetes for more information.

You can enable Azure Policy add-on for AKS clusters in multiple ways:

**Azure Portal**

Upon creating an AKS cluster you can enable Azure Policy add-on in the Integrations section, as shown in the screenshot below:

![Screenshot of enabling Azure Policy add-on from Azure portal upon cluster creation](../../images/k8s_azure_policy/aks_azpolicy_addon_portal.png)

You can enable Azure Policy add-on on existing AKS cluster from the Settings -> Policies section, as shown in the screenshot below:

![Screenshot of enabling Azure Policy add-on from Azure portal for an existing AKS cluster](../../images/k8s_azure_policy/aks_azpolicy_addon_portal_existing.png)

**Azure CLI**

Upon creating an AKS cluster with Azure CLI you can enable Azure Policy add-on with ```--enable-addons azure-policy``` parameter. For example:

```az aks create --name chamber-of-secrets --resource-group hogwarts-rg --enable-addons azure-policy```

**Terraform**

```azure_policy_enabled = true``` argument can be used to enable Azure Policy add-on with AzureRM provider for Terraform. 

For example:

``` terraform
resource "azurerm_kubernetes_cluster" "aks_cluster" {
  location                           = "norwayeast"
  name                               = "chamber-of-secrets"
  resource_group_name     = "hogwarts-rg"
  azure_policy_enabled      = true
  
  default_node_pool {
    name                 = "agentpool"
    vm_size              = "Standard_B2s"
  }
}
```
#### Microsoft Defender for Containers

To enable Azure Policy add-on at scale, by automating the process both for new and existing AKS clusters, I would recommend to either use IaC with tools like Terraform, as demonstrated in example above, or use Microsoft Defender for Containers. Or both which is the best option!😸 By enabling Microsoft Defender for Containers you get additional value beyond just automating deployment of Azure Policy add-on at scale...you get additional perks like runtime threat protection and alerting, vulnerability assessment of images stored in Azure Container Registry, best practice cluster hardening audit and recommendations. Detailed information about Microsoft Defender for Containers can be found here: [Microsoft Defender for Containers](https://learn.microsoft.com/en-us/azure/defender-for-cloud/defender-for-containers-introduction).

You can enable Azure Policy add-on with Microsoft Defender for Containers from Defender plans -> Containers -> Settings:

![Screenshot of enabling Azure Policy add-on through Microsoft Defender for Containers](../../images/k8s_azure_policy/aks_azpolicy_msdefender.png)

### Enforce Azure Policy definitions

Once Azure Policy add-on has been enabled, it's time to enforce some Azure Policy definitions. Let's start by enabling a built-in policy definition. I will use **"Kubernetes cluster should not allow privileged containers"** as an example. This policy will check if a deployment uses containers with privileged mode enabled and will deny non-compliant deployments to the respective AKS clusters.

#### Azure Portal

The approach of enabling Azure Policy definitions for Kubernetes is pretty much the same as for any other resource in Azure so I will not go through the whole process. I would like to highlight two things that are worth being aware of:

- **Azure Policy definition scope**: you can enforce a policy either on the resource group level, subscriptions level or tenant level. In most cases you would want to enable policies either on subscription or tenant level to ensure that the same policies apply to all the new AKS clusters that will be created across subscription or even subscriptions in the same tenant.

- **Azure Policy definition parameters**: in the Parameters section of the policy assignment view I would recommend to always leave **"Only show parameters that need input or review"** unchecked, because in that case all the available configuration options for the respective policy definition will be visible and you can ensure that the policy's behaviour is configured correctly as per your use case. Below you can see an example of all possible configuration options for the policy that we're using in this walkthrough:

![Screenshot of default parameters for Azure Policy definition for disallowing usage of container privileged mode](../../images/k8s_azure_policy/aks_azpolicy_params.png)

Once the policy is enabled you will be able to see it in the list of assigned policies in addition to the resource compliance state in the Compliance blade of the Azure Policy page:

![Screenshot of the Azure Policy compliance blade with enabled Azure Policy definition for disallowing usage of container privileged mode](../../images/k8s_azure_policy/aks_azpolicy_compliance.png)

> Please note that it may take up to **30** minutes for a new or updated policy to take effect and be evaluated across clusters. If you want to instantly trigger re-evaluation, you can use ```az policy state trigger-scan``` command.

If we now attempt to create a deployment with privileged mode enabled...

``` yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: aks-helloworld
  namespace: aks-helloworld
spec:
  replicas: 2
  selector:
    matchLabels:
      app: aks-helloworld
  template:
    metadata:
      labels:
        app: aks-helloworld
    spec:
      containers:
      - name: aks-helloworld-one
        image: aks-helloworld:latest
        securityContext:
          privileged: true # <- Non-compliant configuration!

    # REST OF THE CODE IS OMITTED
```

...we will get an error and no deployment will be created in the AKS cluster:

![Screenshot of the non-compliant Deployment being denied by enforced Azure Policy definition for disallowing usage of container privileged mode](../../images/k8s_azure_policy/aks_azpolicy_denied_deploy.png)

#### Azure CLI

#### Terraform (IaC)



### Create and enforce custom Azure Policy definitions

Built-in Azure Policy definitions can't cover all the areas that you may want to be audited, therefore creating custom Azure Policy definitions can come really handy in such cases.

### Azure Policy Remediation

## Additional resources




That's it from me this time, thanks for checking in!💖

If this article was helpful, I'd love to hear about it! You can reach out to me on LinkedIn, Twitter, GitHub or by using the contact form on this page.😺

Stay secure, stay safe.

Till we connect again!😻