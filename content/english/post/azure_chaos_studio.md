+++
author = "Kristina D."
title = "Resilience testing of Azure services with Azure Chaos Studio"
date = "2023-09-17"
description = "In this blog post we will explore how you can use Azure Chaos Studio to ensure resilience of non-Kubernetes services in Azure like App Service, Key Vault, Virtual Machine, etc."
draft = true
tags = [
    "azure",
    "devops",
    "chaos-engineering",
    "azure-chaos-studio",
    "sre"
]
+++

{{< table_of_contents >}}

***This blog post is a contribution to Azure Back to School which is an annual community event taking place in September. For the Community by the Community, during the whole month of September, contributors share their knowledge and experience about Azure. You're welcome to check out all the contributions here:*** [2023 Azure Back to School Session Schedule](https://azurebacktoschool.github.io/edge%20case/azure-back-to-school-2023-session-schedule)

![Azure Back to School logo](../../images/azure_back_to_school_logo.webp)

## Introduction

Chaos engineering has been known to the tech industry for quite many years now, but it has gained significant popularity and wider adoption during the last few years. There are good reasons for why this acceleration has happened. If we take a look at a modern software development landscape we will see that we're steadily building more complex, distributed systems and applications, with hundreds or even thousands of dependencies and interconnections. Ensuring that all of these bits and pieces play nicely together to provide availability, stability and security of our systems at all times is a challenge that's not for the faint-hearted.

That's where chaos engineering discipline comes in. It provides us with the tools and methodologies that can be used to perform controlled experiments that simulate real-life disruptive events, like outages or failures, so that we can monitor how our systems respond to and withstand turbulent events and identify ways to improve system resilience.

If you're not very familiar with chaos engineering yet, do keep an eye out for an introductory blog post that I will publish shortly after the release of this blog post. You can also check out an introductory session about chaos engineering which I did at [Women on Stage global virtual conference 2023](https://www.womenonstage.net/event-details/global-virtual-conference-2023).

## Azure Chaos Studio

Very often chaos engineering is being mentioned in context of Kubernetes and Kubernetes-specific workloads, but this is not the only place where you can integrate chaos engineering. There are multiple chaos engineering tools that support performing experiments targeting both regular servers/virtual machines and different PaaS offerings in public cloud.

Azure Chaos Studio is one of such tools. A subset of experiments in Azure Chaos Studio does indeed target Kubernetes and is built upon Chaos Mesh, which is an open source tool governed by CNCF. This part of Azure Chaos Studio functionality is out of scope for this blog post and will be covered in a subsequent blog post. In this blog post we will focus on the other subset of Azure Chaos Studio experiments which targets some of the Azure PaaS offerings like App Service and Key Vault. Since this is an introductory blog post we will look into what non-Kubernetes services we can currently target with Azure Chaos Studio, what value we can gain out of running such experiments and how we can create and execute the experiments targeting existing resources.

### Targets and use cases

There are quite many resources that you can target with Azure Chaos Studio experiments apart from Kubernetes. To name a few: Virtual Machines and Virtual Machine Scale Sets, Cosmos DB, Azure Cache for Redis, Key Vault and App Service, including resources of the "Microsoft.Web/sites" type like Azure Functions. You can find an overview of all the currently available targets and simulations you can execute against those targets here: [Fault library](https://learn.microsoft.com/en-us/azure/chaos-studio/chaos-studio-fault-library)

Since Azure Chaos Studio is still in preview I believe that with time we will see even more Azure services being added as targets to the library, as well as more simulation scenarios becoming available for the diverse Azure ecosystem.

**Now, why would you want to run such Azure Chaos Studio experiments and disrupt Azure services? What value do you gain from that?**

Let's take a look at a few examples.
TODO

Now that we've identified the what and why of running Azure Chaos Studio experiments against Azure services, let's see how we can actually configure and trigger the experiments themselves.

### Creating and executing experiments

**1. Enable targets for the experiments and adjust allowed actions.**

**2. Create an experiment.**

**3. Schedule a newly created experiment.**

You can also define targets and experiments as infrastructure-as-code, but if you're using Terraform, please note that while Azure Chaos Studio is in preview you will only be able to use the AzAPI provider to create the respective resources. You can find more information about it here: [Microsoft.Chaos experiments](https://learn.microsoft.com/en-us/azure/templates/microsoft.chaos/experiments?pivots=deployment-language-terraform)

Next time we'll get even more hands-on and create a production-like simulation for some of the Azure services with help of Azure Chaos Studio, adjust service configuration based on the results we get and improve outcome of the experiments. Stay tuned for the upcoming hands-on session on this topic!😼

## Additional resources

Below you may find a few additional resources to learn more about Azure Chaos Studio and chaos engineering:

- [What is Azure Chaos Studio Preview?](https://learn.microsoft.com/en-us/azure/chaos-studio/chaos-studio-overview)

- [Chaos Engineering - Learning Resources👾](https://github.com/guidemetothemoon/Festive-Tech-Calendar-2022/blob/main/learning-resources.md)

That's it from me this time, thanks for checking in!💖

If this article was helpful, I'd love to hear about it! You can reach out to me on LinkedIn, Twitter, GitHub or by using the contact form on this page.😺

Stay secure, stay safe.

Till we connect again!😻
