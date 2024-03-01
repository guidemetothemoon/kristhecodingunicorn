+++
author = "Kristina D."
title = "Christmas the Whole Year Round...and Year++ with Kubernetes LTS"
date = "2023-12-29"
description = "In this blog post we'll discuss in which use cases Kubernetes LTS makes sense, what this means for the core Kubernetes projects, and how the Kubernetes LTS works in context of AKS."
draft = false
tags = [
    "kubernetes",
    "aks",
    "k8s",
    "cloudops",
    "devops"
]
slug = "kubernetes-lts"
+++

{{< table_of_contents >}}

🎄***This blog post is also a contribution to Festive Tech Calendar 2023, where during the month of December, experts from the tech community share their knowledge about a multitude of tech topics. As part of this initiative you can also support a*** [fundraising](https://www.justgiving.com/page/festive-tech-calendar-2023) ***for the Raspberry Pi Foundation. You're welcome to check out all the contributions here:*** [Festive Tech Calendar 2023](https://festivetechcalendar.com)

## Kubernetes release cycle and its challenges

As you might know since the beginning of time Kubernetes has been known for its quite frequent release cycle. With approximately 4 releases of new Kubernetes versions per year a specific version was supported for **9 months** until Kubernetes version ```1.18```. With Kubernetes version ```1.19``` community support got extended by **3 months**. At the time of publishing this blog post a specific version of Kubernetes is supported for **1 year**. Support in this case means patching of security-related, dependency-related or other critical core issues.

Managed Kubernetes Service offerings like Azure Kubernetes Service have been following the same release cycle since their offerings are built on top of core Kubernetes project.

Such a frequent release cycle does put a significant pressure on the end users, making it challenging for some of the organizations to keep up with the upgrade requirements. Significant amount of API deprecations and removals that result in the constant need for refactoring, limited competence, availability or even motivation may be some of the factors due to which companies may end up being significantly behind on their cluster upgrades. A very popular argument that I hear many times is: *"We're using limited Kubernetes functionality, we're not interested in new features, why should we invest time in upgrading if the current version is stable and sufficient?"*. Well, regular upgrades are not just about getting new features. Just as with any upgrade you need to keep it consistent for multiple reasons:

- **Security fixes, including fixes to third-party dependencies.** There are cases where a security fix for a dependency can only be delivered for a newer version of the dependency, which in turn may not be compatible with the older Kubernetes version that you may be running.

- **Dependency updates.** As mentioned in the previous point, if you want to get new functionality or specific patches by updating a third-party dependency to a newer version, in some cases it will not be available for older versions of Kubernetes.

- **Compliance with public cloud provider's support agreement**. If you're using a managed Kubernetes service in public cloud and you don't keep it continuously updated with one of the supported versions you risk losing provider support. It can become crucial in case something goes wrong, for example on the control plane side, which is managed by the cloud provider. For instance, when it comes to AKS, if you have been running a cluster with Kubernetes version that has been out of support for more than **3** minor versions and it has been confirmed to pose a security risk Microsoft may update the cluster on your behalf in case no mitigation actions have been taken on your side. More information can be found here: [Supported Kubernetes versions in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/en-us/azure/aks/supported-kubernetes-versions).

## Kubernetes long-term support and its availability for AKS

The trend is changing. Kubernetes core is becoming mature and stable, less API deprecations and removals are happening, and we see that the community support window for a Kubernetes version has become longer. Now is a much more suitable time for something like long-term support to come into picture. Microsoft is one of the first managed Kubernetes service providers who started paving the way for this functionality by making it available in AKS.

Long-term support for AKS was officially announced during KubeCon + CloudNativeCon Europe 2023 conference, which took place in Amsterdam in April. LTS for AKS provides an additional year of support for a specific version of Kubernetes,  which means that a specific version of Kubernetes on AKS will be supported for **2** years instead of **1** year that community support provides. In order to offer this functionality in a scalable manner Microsoft forked the official Kubernetes repository and will maintain its [fork](https://github.com/aks-lts/kubernetes) in the open to be able to offer an additional year of support. This project is also welcoming community contributions.

Microsoft has also been contributing to restart of the [CNCF Working Group for official Kubernetes LTS project](https://github.com/kubernetes/community/tree/master/wg-lts), where community can continuously collaborate to define and create a standard for how a long-term support release for Kubernetes should look like and how it can be offered in a stable, secure and scalable manner. The working group is meeting bi-weekly on Tuesdays and it's open for all community members.

**Personally I think that** having a long-term support offering for Kubernetes makes sense, also for managed Kubernetes service offerings. **The default strategy should always be to keep your clusters up-to-date** by following the official community support release cycle. For companies with proper in-house competence and well-established operational and upgrade routines with a high level of automation this shouldn't pose any challenges. But there are still quite a few companies out there who have valid reasons for why they may require additional time in-between cluster upgrades. Some of these reasons may be: lacking level of automation and/or competence, time-consuming development routines, additional procedures (f.ex., security-related) that must be followed for each upgrade, etc. Changing some of these processes may take time, sometimes years, therefore using a Kubernetes version with extended support can be the golden mean solution for such organizations.

## Creating and upgrading an AKS cluster with LTS support

> Please note that creating an AKS cluster with long-term support version requires a Premium tier, which incurs additional cost that's billed with a fixed price per cluster hour. See more about AKS tiers here: [AKS pricing tier comparison](https://azure.microsoft.com/en-us/pricing/details/kubernetes-service/#pricing).

Long-term support in AKS is available from Kubernetes version ```1.27```. In order to be able to use an LTS version you must both enable the premium tier type and LTS support plan parameters.

> One more thing to be aware of is that not all add-ons and features are supported for a Kubernetes version that's outside of the official community support (which an LTS version would still be at this point), therefore you will not be able to create or move your cluster to Long Term support if any of these add-ons or features are enabled. An overview of unsupported add-ons and features is available here: [Long term support, add-ons and features](https://learn.microsoft.com/en-us/azure/aks/long-term-support#long-term-support-add-ons-and-features).

Here's an example Bicep code for setting up a simple AKS cluster with LTS support enabled:

``` bicep
// main.bicep

@description('AKS cluster name.')
param clusterName string = 'aks-dev-ktcu'

@description('Region to deploy AKS cluster to.')
param location string = resourceGroup().location

@description('The size of the Virtual Machine.')
param nodePoolSize string = 'Standard_B2s'

resource aks 'Microsoft.ContainerService/managedClusters@2023-07-02-preview' = {
  name: clusterName
  location: location
  sku:{
    name: 'Base'
    tier: 'Premium' // <-- Set tier to Premium to enable LTS on the cluster
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    dnsPrefix: '${clusterName}-dns'
    kubernetesVersion: '1.27.7'
    supportPlan: 'AKSLongTermSupport' // <-- Set supportPlan to AKSLongTermSupport to enable LTS on the cluster
    agentPoolProfiles: [
      {
        name: 'syspool'
        count: 1
        vmSize: nodePoolSize
        osType: 'Linux'
        mode: 'System'
      }
      {
        name: 'userpool'
        count: 1
        vmSize: nodePoolSize
        osType: 'Linux'
        mode: 'User'
      }
    ]
  }
}

```

Once a cluster is created we can verify that the settings are set correctly by running following command in the command shell: ```az aks show -n aks-dev-ktcu -g kris-aks-lts-test | grep -E '"supportPlan"|"tier"'```

![Screenshot of the command shell output to verify that LTS support is enabled on AKS](../../images/k8s/aks_lts_bash_cmd.webp)

When it comes to upgrading an AKS cluster with LTS support both manual and automatic upgrade is supported, and it's pretty straightforward to migrate to and from LTS support to the regular community support. As long as tier and support plan are correctly defined it's all about targeting the desired Kubernetes version. Check Microsoft documentation for how future LTS versions for AKS are chosen: [How we decide the next LTS version](https://learn.microsoft.com/en-us/azure/aks/long-term-support#how-we-decide-the-next-lts-version).

**Summing it up**, I think that longer community support for Kubernetes definitely has a place to be. Now that Kubernetes core is becoming more and more stable with each release it can very much happen at some point. There are definitely use cases for this and we'll most likely see other public cloud providers offering the same LTS functionality as Microsoft has recently done. It'll be interesting to see where the Kubernetes LTS journey takes the community in any case!

If you would like to share any thoughts or experiences around the topic of Kubernetes LTS, including your experience with using it on AKS, don't hesitate to drop me a message😊

## Additional resources

If you would like to learn more about Kubernetes long-term support, check out an interesting discussion we had at Kubernetes Unpacked podcast with Kubernetes co-founder, Brendan Burns: [KU042: Kubernetes Long-Term Support With Kubernetes Co-Founder Brendan Burns](https://packetpushers.net/podcast/ku042-kubernetes-long-term-support-with-kubernetes-co-founder-brendan-burns).

To learn more about Kubernetes long-term support for AKS, check out following documentation: [Azure Kubernetes Service - Long term support](https://learn.microsoft.com/en-us/azure/aks/long-term-support).

Finally, to learn more about the CNCF Kubernetes LTS working group, check out their subfolder in Kubernetes GitHub repository: [LTS Working Group](https://github.com/kubernetes/community/blob/master/wg-lts/README.md). In this working group community is working on creating an understanding an alignment around what long-term support means for Kubernetes and how it can be offered in a stable and secure manner.

That's it from me this time, thanks for checking in!💖

If this article was helpful, I'd love to hear about it! You can reach out to me on LinkedIn, X, GitHub or by using the contact form on this page.😺

Stay secure, stay safe.

Till we connect again!😻
