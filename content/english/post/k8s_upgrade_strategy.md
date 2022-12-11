+++
author = "Kristina D."
title = "[Azure Advent Calendar] Exploring upgrade strategies in Azure Kubernetes Service"
date = "2022-12-11"
description = "In this blog post we'll look into importance of continuous upgrade of AKS clusters and nodes, and what are possible strategies to do it manually and automatically."
draft = true
tags = [
    "kubernetes",
    "aks",
    "k8s",
    "azure",
    "devops"
]
+++

![Article banner for exploring upgrade strategies in AKS](../../images/k8s_upgrade_strategy/k8s_upgrade_strategy_banner.png)

{{< table_of_contents >}}

Have you already seen "Automatic upgrade" property when creating a new AKS cluster in Azure Portal?

![Screenshot of automatic upgrade property in new AKS cluster creation in Azure Portal](../../images/k8s_upgrade_strategy/aks_automatic_upgrade_property.png)

Auto-upgrade of an AKS cluster is actually **not** a new functionality and has been available since January 2021. It is just recently it has been made configurable from the Azure Portal, when you create a new AKS cluster.

Before we dive into what auto-upgrade functionality can do for us let's take a look at why we need to bother about upgrading AKS clusters we create and why it's important to do it frequently and continuously.

## Why upgrading AKS clusters is important?

I've seen quite a few misunderstandings and misconceptions related to the upgrade process for AKS clusters and Kubernetes clusters in general. Both when it comes to upgrading the cluster to a new Kubernetes version and upgrading a node image to a new OS version and/or to get newest patches and fixes. I've seen many organizations running their workloads on clusters with Kubernetes version that was 2-4 versions older than the latest GA version.

**So, why can lacking cluster upgrade routine become an issue?**




This cat represents application A that is deployed with 8 Pods across 2 Nodes;


![AKS Upgrade Flow GIF](../../images/k8s_upgrade_strategy/aks_upgrade_flow.gif)

## Additional resources

Below you may find a few resources to learn more about auto-upgrading AKS clusters and about the cluster and node image upgrade process in general:

- []()
- []()
- []()
- []()

That\'s it from me this time, thanks for checking in!💖

If this article was helpful, I\'d love to hear about it! You can reach out to me on LinkedIn, Twitter, GitHub or by using the contact form on this page.😺

Stay secure, stay safe.

Till we connect again!😻