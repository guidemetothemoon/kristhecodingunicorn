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

I've seen quite a few misunderstandings and misconceptions related to the upgrade process for AKS clusters and Kubernetes clusters in general. Both when it comes to upgrading the cluster to a new Kubernetes version and upgrading a node image to a new OS version and/or in order to get newest patches and fixes. I've seen many organizations running their workloads on clusters with Kubernetes version that was 2-4 versions older than the latest GA version.

**SO, WHY CAN LACKING CLUSTER UPGRADE ROUTINE BECOME AN ISSUE?**

Kubernetes clusters, just like any other technology, get affected by security vulnerabilities. During the last few years more and more threat actors are targeting workloads running in Kubernetes clusters and year 2022 has been the year with the highest amount of security vulnerabilities that were registered for Kubernetes according to the CVE count at [CVE - Kubernetes](https://cve.mitre.org/cgi-bin/cvekey.cgi?keyword=kubernetes). Nodes that applications are running on in Kubernetes are basically VMs which must also be continuously patched and updated, just like regular virtual machines you may be running elsewhere, for example on-premises. When a security vulnerability gets disclosed there may often be a workaround or a quick fix that can be applied on currently running resources but in order to fully protect and fail-proof your resources you would need to perform an upgrade to get the latest patches and security fixes.

Another important reason are new and deprecated features and components. By upgrading to newer Kubernetes versions you get access to new functionality that can help you run your workloads more securely, efficiently and sustainably which is always a plus. At the same time, by not upgrading to newer Kubernetes versions you may end up in a situation where you can't scale out by creating more nodes or more clusters because the version you're attempting to use is not supported anymore. And that's a nasty situation to be in when you really need to scale your application😅 Another risk may be third-party applications that take specific versions out of support whether newer versions may not necessarily support a legacy Kubernetes version. In that case you may not even be able to pull the desupported version of the applicaiton which, even though is a more rare scenario, may still happen (trust me, I've seen it😑).

Last reason is related to support policy defined by cloud provider which applies in case you're using managed Kubernetes service. When it comes to managed Kubernetes service like AKS it's important to understand what you're responsible for in terms of keeping your AKS clusters and nodes upgraded:

1. **AKS cluster and node upgrade to a new Kubernetes version:** you're responsible for upgrading your AKS clusters to newer Kubernetes versions. Kubernetes release frequency is approximately 3 times per year for minor version releases + quite frequent (monthly or even weekly) patch releases for fixing security vulnerabilities or bugs of significant severity. AKS normally has weekly releases with 2-week rollout window in order to make new changes available for all regions in a controlled and safe manner. AKS releases may include adding support for new Kubernetes versions, fixes, feature and component updates, including node OS image updates. In order to stay on a version that is officially supported by Microsoft, you must upgrade at least once a year. If you're running AKS clusters that have been out of support for more than 3 minor versions and it poses a security risk (for example, to Microsoft's infrastructure which is shared among customers), Microsoft will nicely ask you to upgrade your clusters. If you ignore the request, Microsoft will have no other choice then to upgrade the clusters on your behalf. YOU. HAVE. BEEN. WARNED. 😈 

2. **Linux and Windows Node OS image upgrade to newer OS version or in order to get latest fixes and patches:** you're responsible for patching and upgrading operating system that your worker nodes (nodes where your applications are deployed) are running on. Patching and node OS image upgrade for master nodes in AKS is handled by Microsoft. Process is different for Linux and Windows nodes: updates for Linux nodes are released weekly or even daily and are applied to existing Linux nodes automatically, apart from reboot. You're responsible to perform reboot to finalize the upgrade of Linux nodes. Updates for Windows nodes are released as a new Windows image monthly which means that Windows updates are not applied to Windows nodes automatically - you're responsible for upgrading Windows nodes to the newest Windows image which also includes latest patches. If you don't have a routine for upgrading OS image manually or automatically, **you may end up running your applications on unpatched and vulnerable nodes!** And you don't want that.


Overall conclusion is that there are many strong arguments for why you should keep your clusters updated and with a good routine in place upgrade process can be like a walk in the park (almost). You can read more about AKS support and upgrade policies in the links that are provided in "Additional resources" section below.

Now let's take a look at how upgrade process looks like and how you can automate it.😼

## Cluster and Node OS image upgrade process

I will not go into all the details of AKS cluster and node OS image upgrade - it's well-documented in official Microsoft documentation, links to which you can find in the end of this blog post.😺

Instead I would like to illustrate the upgrade process and mention a few highlights that you need to be aware of. 

There are 3 important pieces that you need to decide upon prior to doing your first upgrade:

* **Pod Disruption Budget.** It is important that all the applications running in Kubernetes cluster are configured with Pod Disruption Budgets (PDB). PDB ensures that a defined amount of application replicas are available during voluntary/planned disruptions like planned maintenance - which will provide you a capability to perform zero downtime upgrades. I will point out that **PDBs should be configured so that at least 1 Pod can be drained** - if it's configured with unevictable Pods, a Node drain operation hangs and never gets to complete. You can read more about Pod Disruption Budgets here: [Pod disruption budgets](https://kubernetes.io/docs/concepts/workloads/pods/disruptions/#pod-disruption-budgets)

* **Node surge value.** Node surge defines how many worker nodes can be take offline at the same time for upgrade. Default value is 1 Node but it is configurable with a ```--max-surge``` setting. Recommendation from Microsoft is to define ```--max-surge``` setting no larger than ```33%``` for production clusters. You can read more about node surge here: [Customize node surge upgrade](https://learn.microsoft.com/en-us/azure/aks/upgrade-cluster?tabs=azure-cli#customize-node-surge-upgrade) 

* **Maintenance window.** You can enable Planned Maintenance functionality (In Preview at the point of writing this blog post) to secure that upgrades are performed during the time range that works best for you in terms of minimizing planned and unplanned disruption. This may be beneficial especially when auto-upgrade is enabled. You can read more about it here: [Use Planned Maintenance to schedule maintenance windows for your Azure Kubernetes Service (AKS) cluster (preview)](https://learn.microsoft.com/en-us/azure/aks/planned-maintenance)

Now, let's take a look at concrete example here: in the animation below I've visualized an AKS cluster upgrade flow. We have an AKS cluster with 2 nodes which will be upgraded to a new Kubernetes version with latest node OS image. Node surge value is set to default where only 1 Node at a time will be taken down for upgrade.

There are 2 applications in the game: 
- DeerCat application with 8 replicas spread across existing 2 nodes. DeerCat application has PDB defined where 6 out of 8 Pods must be available at all times. 
- BlackHatCat application with 2 replicas which will be deployed to the same AKS cluster while the upgrade process is ongoing.

The upgrade will happen as follows:

1. Create buffer node, Node 3, on the chosen new version.
2. Choose Node 1 to upgrade. 
3. Prohibit scheduling of new deployments (cordon) to this Node.
4. Empty Node 1 (drain) by re-creating all Pods on other available Nodes, including the buffer node. The amount of Pods to be killed and re-created simultaneously is defined by Pod Disruption Budgets.
5. Upgrade Node 1 to new Kubernetes version and Node OS image. Allow scheduling of new deployments (uncordon) to this Node.
6. Node 1 becomes buffer node for Node 2.
7. Choose Node 2 to upgrade. Perform step 3-5 for Node 2.
8. Node 2 becomes buffer node.
9. No subsequent nodes to upgrade. Empty and remove lastly tagged buffer node (Node 2). Repeat step 3-4 for Node 2.
10. Delete Node 2. AKS cluster upgrade complete!

I hope that you liked my festive visualization of the upgrade process.😻

![AKS Upgrade Flow GIF](../../images/k8s_upgrade_strategy/aks_upgrade_flow.gif)

As I mentioned earlier, you can perform the upgrade manually, in a controlled manner, but you can also configure it to happen automatically whenever a new Kubernetes version or node image becomes available - let's dig into how we can do that in the next section! 👀

## AKS Auto-upgrade


### Auto-upgrade considerations



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