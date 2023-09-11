+++
author = "Kristina D."
title = "Resilience testing of Azure services with Azure Chaos Studio"
date = "2023-09-21"
description = "In this blog post we will explore how you can use Azure Chaos Studio to ensure resilience of non-Kubernetes services in Azure like App Service, Key Vault, Virtual Machine, etc."
draft = true
tags = [
    "azure",
    "devops",
    "chaos-engineering",
    "azure-chaos-studio".
    "sre"
]
+++

{{< table_of_contents >}}

***This blog post is a contribution to Azure Back to School which is an annual community event taking place in September. For the Community by the Community, during the whole month of September, contributors share their knowledge and experience about Azure. You're welcome to check out all the contributions here:*** [2023 Azure Back to School Session Schedule](https://azurebacktoschool.github.io/edge%20case/azure-back-to-school-2023-session-schedule)

## Introduction

Chaos engineering has been known to the tech industry for quite many years now, but it has gained significant popularity and wider adoption during the last few years. There are good reasons for why this acceleration has happened. If we take a look at a modern software development landscape we will see that we're steadily building more complex, distributed systems and applications, with hundreds or even thousands of dependencies and interconnections. Ensuring that all of these bits and pieces play nicely together to provide availability, stability and security of our systems at all times is a challenge that's not for the faint-hearted.

That's where chaos engineering discipline comes in. It provides us with the tools and methodologies that can be used to perform controlled experiments that simulate real-life disruptive events, like outages or failures, so that we can monitor how our systems respond to and withstand turbulent events and identify ways to improve system resilience.

If you're not very familiar with chaos engineering yet, do keep an eye out for an introductory blog post that I will publish shortly after the release of this blog post. You can also check out an introductory session about chaos engineering which I did at [Women on Stage global virtual conference 2023](https://www.womenonstage.net/event-details/global-virtual-conference-2023).

## Azure Chaos Studio

Very often chaos engineering is being mentioned in context of Kubernetes and Kubernetes-specific workloads, but this is not the only service where you can work integrate chaos engineering. There are multiple chaos engineering tools that support performing experiments targeting both regular servers/virtual machines and different PaaS offerings in public cloud.

Azure Chaos Studio is one of such tools. A subset of experiments in Azure Chaos Studio does indeed target Kubernetes and is built upon Chaos Mesh which is an open source tool governed by CNCF. This part of Azure Chaos Studio functionality is out of scope for this blog post and will be covered in a subsequent blog post. In this blog post we will focus on the other subset of Azure Chaos Studio experiments which targets some of the Azure PaaS offerings like App Service and Key Vault. We will use Azure Chaos Studio to run experiments targeting these offerings, learn from the results the experiments give us and use those results to improve resilience of the respective services.

Let's do it!😼

### Preparations

TODO

### Experiment 1: Azure Key Vault

TODO

### Experiment 2: Azure App Service

TODO

## Additional resources

Below you may find a few additional resources to learn more about Azure Chaos Studio and chaos engineering:

- [What is Azure Chaos Studio Preview?](https://learn.microsoft.com/en-us/azure/chaos-studio/chaos-studio-overview)

- [Chaos Engineering - Learning Resources👾](https://github.com/guidemetothemoon/Festive-Tech-Calendar-2022/blob/main/learning-resources.md)

That's it from me this time, thanks for checking in!💖

If this article was helpful, I'd love to hear about it! You can reach out to me on LinkedIn, Twitter, GitHub or by using the contact form on this page.😺

Stay secure, stay safe.

Till we connect again!😻
