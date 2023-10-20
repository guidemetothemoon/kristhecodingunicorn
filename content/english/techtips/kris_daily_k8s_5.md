+++
author = "Kristina D."
title = "Kris's Quick Cup of (A)K8S #5 - Housekeeping for Kubernetes Contexts"
date = "2022-11-22"
description = "In this tech tip we look at what Kubernetes context is and how we can clean up unused Kubernetes contexts."
draft = false
tags = [
    "techtips",
    "aks",
    "kubernetes",
    "gitops"
]
+++

Let's start today's tech tip by identifying what a Kubernetes Context is. Kubernetes Context, which is also known as kubectl context, represents a Kubernetes cluster that kubectl command-line tool is currently targeting. You decide which Kubernetes cluster to set as active by modifying currently active context with ```kubectl config use-context <cluster_name>``` command.

All the configured and available Kubernetes contexts are stored in a kubeconfig file. **Kubeconfig file** contains a collection of properties for every Kubernetes cluster that respective client is connected to - properties such as Kubernetes cluster name, authentication mechanisms, user/service account, etc. This information is used by kubectl command-line tool to connect to the API server of the respective cluster once it's set as the active Kubernetes context.

Once you set up a connection to a Kubernetes cluster, context information is automatically stored in a kubeconfig file locally.
But, did you know that **once a Kubernetes cluster is deleted and you've previously connected to it, it's context information will not be automatically removed from your kubeconfig file?**

If you've been working with Kubernetes for a while, you might've been through deletion of tens or even hundreds of clusters...and if you have never cleaned up your Kubernetes contexts, only imagination sets the limit for how large your kubeconfig file currently is. Now, let's give this kubeconfig file some love and do a little bit of housekeeping!😺

There are multiple ways you can clean up Kubernetes contexts.

The official way is to use ```kubectl config unset contexts.<context_name>``` .

An important note here is that **this command only removes the context section from the kubeconfig file but the cluster and user section for this context are kept unchanged**. Unless you're handcrafting your kubeconfig files for specific use cases, I would recommend you to clean up cluster and user information as well so that you don't keep orphaned, potentially sensitive information on the client longer than it's actually needed.

You can clean up cluster and user section with the same unset command:

``` bash
kubectl config unset clusters.<cluster_name>
kubectl config unset users.<user_name>
```

It can be quite a lot of manual work to run these commands manually if you have tens of Kubernetes clusters to clean up 😮‍💨 Fortunately we have automation and can script this! Since I'm working a lot with AKS clusters I have created a small script that cleans up AKS cluster contexts - it will check all the configured Kubernetes contexts towards all the existing AKS clusters in all Azure subscriptions that I have access to. After confirmation it will then clean up context data, including cluster and user sections (if enabled), for the non-existent AKS clusters.

This script is freely available on GitHub so you're welcome to check it out and customize to your needs: [guidemetothemoon - Cleanup-AKS-Contexts.ps1](https://github.com/guidemetothemoon/div-dev-resources/blob/main/scripts/kubernetes/aks-context-cleanup/Cleanup-AKS-Contexts.ps1)

Another way is to use open source tools like [kubectx](https://github.com/ahmetb/kubectx) to help you with this type of housekeeping, but do pay attention to which tool you choose. Some tools may have implemented cleanup logic in such a way that all the clusters that the tool isn't able to connect to will be cleaned up. If you're turning on/off some of the clusters for sustainability and cost optimization reasons for example, this tool will clean them up in case they are in the offline state at the point when the tool is executed. So it's worth having it in the back of your head.

You can read more about Kubernetes context and Kubernetes configuration file here: [Configure Access to Multiple Clusters](https://kubernetes.io/docs/tasks/access-application-cluster/configure-access-multiple-clusters/)

That\'s it for now - Thanks for reading and till next tech tip 😼
