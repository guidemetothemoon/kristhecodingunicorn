+++
author = "Kristina D."
title = "Kris's Quick Cup of (A)K8S #5 - Housekeeping for Kubernetes Contexts"
date = "2022-11-21"
description = "In this tech tip we look at what Kubernetes context is and how we can clean up unused Kubernetes contexts."
draft = true
tags = [
    "techtips",
    "aks",
    "kubernetes",
    "gitops"
]
+++

![Article banner for Kris's quick cup of K8s number 5](../../images/tech_tips/techtip_15.png)

Let's start today's tech tip by identifying what a Kubernetes Context is. Kubernetes Context, which is also known as kubectl context, represents a Kubernetes cluster that kubectl command-line tool currently communicates with and executes commands against. You decide which Kubernetes cluster to set as active by modifying currently active context with commands like ```kubectl config use-context <cluster_name>```. All the configured and available Kubernetes contexts are stored in a kubeconfig files which contains a collection of parameters about a specific Kubernetes cluster like it's name, authentication mechanisms and users, etc. This information is used by kubectl command-line tool to connect to the API server of the respective cluster once the active Kubernetes context is set.

Once you set up a connection to a Kubernetes cluster, context information is automatically stored in a kubeconfig file locally.
But, did you know that once a Kubernetes cluster is deleted and you've previously connected to it, it's context information will not be automatically removed from your kubeconfig file?

If you've been working with Kubernetes for a while, you might've been through deletion of tens or even hundreds of clusters...and if you have never cleaned up your Kubernetes contexts, only imagination sets the limit for how large your kubeconfig file currently is. Now, let's give this kubeconfig file some love and do a little bit of housekeeping!


That\'s it for now - Thanks for reading and till next tech tip 😼