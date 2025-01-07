---
author: "Kristina Devochko"
title: "Overview of Azure Private DNS zone fallback to internet functionality"
date: "2025-01-07"
description: "In this blog post we will explore newly released preview functionality for Azure Private DNS zones that allows fallback to internet on domain name resolution."
draft: true
tags: [
    "azure",
    "devops",
    "azure-private-endpoint",
    "azure-dns"
]
slug: "azure-private-dns-zone-fallback-to-public"
---

Towards the end of 2024 Microsoft announced new configuration opportunity for Azure Private DNS zones called fallback to Internet. I think that it was announced more or less right after the 2024 Microsoft Ignite event. This functionality is at the point of writing this blog post still in preview so proceed with caution 😼

I've recently implemented this functionality and I would like to share a use case here where utilizing this can make sense, and how you can use it yourself.

## How does it work?

Fallback to Internet for private DNS zones can prove very handy when you're utilizing private endpoints, especially in a multi-region scenario. Let's take a look at a typical example workflow for creating a private endpoint for an Azure Key Vault (the same workflow is applicable for any other Azure resource that supports private endpoints):

1. Create a private DNS zone that will contain records mapping every Key Vault behind private endpoint to its private IP address. Normally it will be `privatelink.vaultcore.azure.net`.
2. Create a virtual network link between the private DNS zone and a virtual network that will provision private IP addresses for the respective private endpoints.
3. Create a private endpoint and connect it to the respective Azure Key Vault.
4. Disable public network access on the respective Azure Key Vault.

This example workflow is somewhat simplified - depending on what resources you would like to put behind private endpoints and what kind of architecture you have in place you may need to do additional things like creating virtual network peerings, private DNS resolvers, etc. But this can be a dedicated blog post in itself 😅

The point is that once all the steps are done and the Azure Key Vault is only accessible via private endpoint, on its private IP address, **all of the queries attempting to reach the resource will only be resolvable by the respective private DNS zone**.

But, what if you would like to whitelist a specific IP address, for example for a specific build agent or a VM to be able to access the Key Vault? Or maybe you have a multi-region setup where a specific resource from different needs access to this specific Key Vault and you don't want (or can't) implement virtual network peerings or interconnected multi-regional setup and would like to just whitelist the IP of that resource that requires access on the Key Vault level? That wouldn't work out of the box, either not at all or it would require you to make larger changes and potentially increase complexity by for example introducing cross-regional vnet peering.

That's where this new fallback to Internet functionality comes into picture. By enabling this configuration setting ...

In my use case there was a multi-regional setup where every region operated in isolation, but there was a specific, common resource in one of the regions that needed access to some of the resources behind the private endpoints in a different region. An option here would've been to introduce cross-regional virtual network peering, but it wasn't applicable in my use case due to security restrictions and the undesirable additional complexity that this change could bring. Utilizing this functionality actually made it pretty quick and simple for me to resolve this challenge and whitelist the IP of the resource that needed access to the resources behind the private endpoint, while still enforcing resolution of all the other traffic to the respective private IP address.

## How to enable it?

Configuration option for this functionality is available in API version `2024-06-01` or higher. At the point of writing this blog post it was unfortunately not available in the Azure Verified Module for private DNS zone or in the AzureRM provider for Terraform, but there are a few options on how you can configure it anyway😸

### Bicep

``` azurebicep

```

### Terraform

It's also not yet available in the AzureRM provider for Terraform, but you can configure it with AzAPI provider like this:

``` terraform

```

### Azure CLI

``` shell

```

You can also go the classic way and configure it via Azure portal (also on existing private DNS zones) - check out first linked article in the session below for more information on how to do that!

## Additional resources

Below you may find a few additional resources to learn more about the topic of this blog post:

- [Fallback to internet for Azure Private DNS zones (Preview)](https://learn.microsoft.com/en-us/azure/dns/private-dns-fallback)
- [Overview of private endpoint DNS zone values for different Azure resources](https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-dns)

That's it from me this time, thanks for checking in!
If this article was helpful, I'd love to hear about it! You can reach out to me on LinkedIn, GitHub or BlueSky 😊

Stay secure, stay safe.
Till we connect again!😼
