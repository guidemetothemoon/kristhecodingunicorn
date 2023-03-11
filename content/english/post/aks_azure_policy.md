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

As you may know already, Kubernetes doesn't come with 100% built-in security by default. The same applies for managed Kubernetes service like AKS. Some cloud providers offer more hardened default configuration for a managed Kubernetes, some offer less hardened and more beginner-friendly default configuration, but the fact stays the fact - cloud services are a shared responsibility. It means that you're responsible to properly harden and secure Kubernetes clusters that you're provisioning, also in Azure.

**But is there a way that can help you make this process easier and ensure continuous complliance?**

There is a way indeed, and it's called Azure Policy. Now let's dig into what Azure Policy is and how it can be applied to AKS. 😼

## Azure Policy for Kubernetes

## Enforcing Azure Policy definitions

### Azure Portal

### Terraform (IaC)

## Custom Azure Policy definitions

## Additional resources


That's it from me this time, thanks for checking in!💖

If this article was helpful, I'd love to hear about it! You can reach out to me on LinkedIn, Twitter, GitHub or by using the contact form on this page.😺

Stay secure, stay safe.

Till we connect again!😻