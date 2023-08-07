+++
author = "Kristina D."
title = "Kubernetes port forwarding: cleaning up orphaned ports"
date = "2023-08-10"
description = "In this blog post we'll look into how we can clean up port reservations that got stuck after a completed port forwarding command in a Kubernetes cluster."
draft = true
tags = [
    "kubernetes",
    "aks",
    "k8s",
    "cloudops",
    "devops"
]
+++

{{< table_of_contents >}}

When working with Kubernetes there may be cases where you may need to use port forwarding to get access to an application running inside the cluster. Some of the use cases may be to access information in internal applications that are not meant to be exposed for public access, verifying that the application works as expected prior to exposing it for public access or troubleshooting purposes.

Port forwarding is a functionality that is available via ```kubectl port-forward``` command and it creates a direct connection between the caller (typically a client machine) and the Pod where application is running inside the cluster. You can either target a specific Pod or any Pod fronted by Kubernetes resources like Service or Deployment. You can read more about the command in official documentation: [port-forward](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#port-forward).

Normally, once you stop/cancel port forwarding the port that was reserved on the caller or client side should be cleaned up and made available for other processes to consume. If this doesn't happen instantly it should happen upon the connection reaches the timeout defined by the system. But sometimes this doesn't happen and the port ends up being orphaned, i.e. there isn't any process using the port anymore, or the process that was using the port has finalized the related operation and doesn't need it anymore, but the system still counts it as an in-use port. In this case, if you attempt to use the same port again by for example re-running the port forwarding command, you may end up seeing an error message saying something like ```Unable to listen on port <PORT>: Listeners failed to create with the following errors: [unable to create listener: Error listen tcp4 <IP>:<PORT>: bind: address already in use unable to create listener: Error listen tcp6 [::1]:<PORT>: bind: address already in use]```, as shown in the screenshot below:

![Screenshot of the error message being displayed during kubectl port-forward command for an orphaned port](../../images/k8s_port_forward/k8s_orphaned_port_error.webp)

**Is there a way to free up the port in this case?**

There is indeed! We just need to dig into the TCP/IP basics to get this done 😊

**Linux.** In Linux-based systems like Ubuntu there are multiple ways you can locate and kill a process holding an orphaned port, but I will show a combination of ```ps``` and ```kill``` commands. First, we will need to locate the processes related to port forwarding in the list of the current processes which we can retrieve with help of this command: ```ps -ef | grep port-forward```

```-e``` parameter retrieves all processes and ```--f``` handles output format to be full-format listing. The output of the ```ps``` command is piped to extract only the entries that include ```port-forward``` keyword.

![Screenshot of the ps command output that lists currently active processes that contain port-forward keyword](../../images/k8s_port_forward/k8s_port_forward_ps.webp)

As you can see, the first entry in the above screenshot represents the port forwarding process that was terminated earlier but is still blocking the port. We can free up the port by killing the blocking process immediately with following command: ```kill -9 20876```

 ```-9``` sends a ```SIGKILL``` signal to terminate the process with ID (PID) ```20876```, which is the value of the second column of the marked entry from the ```ps``` command output. Once this command is executed we can re-run the ```ps``` command to verify that the process holding the port is not in the list anymore. Now the port can be re-used.

![Screenshot of the kill command output that terminated the process holding an orphaned port from being cleaned up](../../images/k8s_port_forward/k8s_orphaned_port_kill.webp)

**Windows.**

That's it from me this time, thanks for checking in!💖

If this article was helpful, I'd love to hear about it! You can reach out to me on LinkedIn, Twitter, GitHub or by using the contact form on this page.😺

Stay secure, stay safe.

Till we connect again!😻
