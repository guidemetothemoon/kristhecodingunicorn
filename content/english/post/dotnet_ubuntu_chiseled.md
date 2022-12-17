+++
author = "Kristina D."
title = "[.NET Advent Calendar] Strengthening security posture of containerized .NET applications with Chiseled Ubuntu Containers"
date = "2022-12-19"
description = "This blog post explains how you can run containerized .NET applications in a more secure manner with Chiseled Ubuntu Containers"
draft = true
tags = [
    "dotnet",
    "microservices",
    "containers",
    "ubuntu",
    "kubernetes"
]
+++

![Article banner for containerizing .NET applications with Chiseled Ubuntu Containers](../../images/dotnet_chiseled/dotnet_chiseled_banner.png)

{{< table_of_contents >}}

🎄***This blog post is also a contribution to .NET Advent Calendar where during December, experts from the tech community share their knowledge through contributions of a specific technology in the .NET domain. You're welcome to check out all the contributions here:*** [.NET Advent Calendar 2022](https://dotnet.christmas/)

## Introduction

In the modern world of cloud native application development more and more organizations are moving away from classic bare metal deployments and are adopting technologies like containerization and orchestration for a more efficient and sustainable way to deploy applications at scale on different types of infrastructure.

Even though the way we're packaging and deploying applications is changing the importance of continuously ensuring and strengthening security posture of our systems is still extremely crucial. With containers and container orchestrators like Kubernetes, security controls must be implemented at multiple levels and it's important to understand what those levels are once you start containerizing your applications. 🔑

In this blog post I would like to talk about how you can minimize the attack surface of the containerized .NET applications with Ubuntu Chiseled Containers which have recently introduced support for .NET 6 and now .NET 7 applications targeting Linux operating system.

## Container Security - pitfalls and must do's

Before we dive into Chiseled Ubuntu Containers let's set the baseline by looking at some pitfalls when it comes to container security and what are the must do's in order to protect containers against those.

### Containers and root user

One of the most important security improvements that you can have in place for containers is to configure them to run with a non-root user. You can also consider using rootless containers or rootless mode if it's possible and is supported, for additional container hardening.

#### Running containers as unprivileged user

By default if you don't provide a user that container should run with, root user will be used. Unless you're using rootless containers, which we will talk about shortly. The big security risk here is that container has access to the host system (a server, a VM an application container is running on, a Node in Kubernetes) and can access and modify content on the host as a root user, with the same level of permissions! If there's a vulnerability in the application running in a container that attacker gets ahold of or a container is misconfigured, a malicious actor may be able to exploit it and get access to the host as root! Just imagine how harmful this can be - I wouldn't wish anyone to experience that🙀

Unfortunately quite many third-party images use root user by default, even though recently more and more serious third-party projects at least are either using an unpriveleged user by default in their container images or are offering an alternative image which is unpriveleged. A good example here is NGINX: they offer both a regular image which uses root user by default and an unpriveleged image which uses a user with minimal privileges to run NGINX applcation in a container: [nginxinc/nginx-unprivileged](https://hub.docker.com/r/nginxinc/nginx-unprivileged).

When a third-party image doesn't provide an unprivileged alternative, it may be possible to create a custom image based on the original image where you can create an unprivileged user and override which user is being used to run a container. But there are cases where this is not that easy to do: for example, default ASP.NET image doesn't let you off that easily: [Unable to start Kestrel. System.Net.Sockets.SocketException (13): Permission denied while running alpine as non root user](https://github.com/dotnet/aspnetcore/issues/4699). Often the reason is the default port that container is binded to - there is a restriction in Linux OS which requires a root user if you're using a port that is lower than 1024. Port 80 is often used by default which falls under this limitation. Now, Chiseled Ubuntu Containers have come to the rescue though!😺

In case of third-party images it's important that you do your research in order to understand if it uses root user by default or not, and use the options that the creators provide in order to configure the image in the most secure way. In case of creating your own container images, do ensure that you're not using a root user unless it's absolutely necessary. It's also a good idea to implement automatic validation for this, for example through Azure Policy. Automatic policies can detect such misconfigurations and alert in case a fix is required.

#### Rootless Containers

For additional security and isolation you can consider adopting rootless containers, if it's supported for your use case. Rootless containers fully eliminate access to the root user on the host system that a container runs on. Even if you forget to specify a non-root user to run containers with, or you may need a root user to perform specific operations inside the container, outside of the container you will not have root user privileges, i.e. you will not be able to access the host system as root. If your container is compromised in this case and an attacker will be able to get access to the host system, he/she will not be able to perform any actions with root privileges. Container engines like Podman have been offering rootless containers for a while now. It was harder to offer support for this by container engines which required a daemon in order to create and manage containers - for example, Docker is one of the container engines that didn't support it until 2020. With Docker version 20.10.0 support for rootless mode has been officially released in GA. You can read more about rootless mode in Docker here: [Run the Docker daemon as a non-root user (Rootless mode)](https://docs.docker.com/engine/security/rootless)

Rootless containers/rootkess mode is a great security enhancement in the containerization world, but it has quite a few limitations which at this point narrows down the use cases where you will be able to adopt it. One of the important limitations is related to support for rootless containers in Kubernetes - not many Kubernetes distributions support it and some distributions support it with limitations. You can learn more about it here: [Running Kubernetes Node Components as a Non-root User](https://kubernetes.io/docs/tasks/administer-cluster/kubelet-in-userns/)

#### Running containers with unprivileged user in Kubernetes

If you're planning on running containers in Kubernetes, in addition to defining an unprivileged user when building a container image you should also use Security Context to define privileges and access control settings for your container when it's running inside a Pod in a Kubernetes cluster, and the Pod itself which can have multiple containers running inside of it. With Security Context you can not only define which user to run the container/Pod with but also if it can be run in privileged mode, gain more privileges than it's parent process, etc.

Using Security Context will ensure that not only the container is built with the correct default user with minimal privileges, but also that the user is correctly set when the container is run as part of a Kubernetes cluster, in a Pod.

You can read more about Security Context in Kubernetes here: [Configure a Security Context for a Pod or Container](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)

### Supply chain and third-party dependencies

In most cases, when packaging your applications in a container you will need to use a third-party base image that is built upon an operating system of your choice and has necessary frameworks and tools installed that your application may need in order to run successfully. For example, if you want to run an ASP.NET 6 application on Linux, you would need a base image that includes a Linux distribution of your choice and has ASP.NET 6 installed. In many cases though third-party images may contain lots of unnecessary tools and libraries that your application doesn't need. Having lots of unnecessary components installed results in a broader attack surface for malicious actors to explore. In addition, the more components you have the more security vulnerabilities you may need to handle.

In order to mitigate this you should use minimal container images that include only those tools and utilities that are absolutely necessary. You can then granularly define which additional libraries and tools to include on top of the minimal configuration. Minimal container images come both with security benefits but may also significantly reduce the total container image size which results in faster image download and startup time. 

### Summary on mitigating common container security pitfalls

To sum it up, in order to strengthen container security and mitigate common pitfalls you should:
- Define a default unprivileged user that container will run with;
- Bind to ports higher than 1024 - if a lower port is required, a proxy can be used;
- Be conscious when choosing third-party images: choose unprivileged image or build an unprivileged custom image on top of the original image;
- Build and use minimal images - install only what's needed in order to successfully run your application in a container;
- In Kubernetes, use SecurityContext to ensure that application containers inside a Pod are using unprivileged user;
- Implement policies to detect and alert on this type of misconfiguration, for example with Azure Policy;

Now, let's take a look at what Ubuntu Chiseled Containers are and how they can make it easier for us to secure containerized .NET applications.😼

## Chiseled Ubuntu Containers && .NET

In August 2022 built-in support for .NET 6 in Ubuntu was officially announced. Built-in support in this case means that you can now install .NET 6 and newer on Ubuntu 22.04 and newer with ```apt install dotnet6```! This is quite cool in itself😺 In addition support for .NET with Chiseled Ubuntu Containers was officially released which is what we're going to look into now.

> ***Please note that at the point of writing this blog post .NET with Chiseled Ubuntu Containers is still in preview and should not be used in production environments. This blog post will be updated once the functionality reaches GA.***

**What are Ubuntu Chiseled Ubuntu Containers?** 

Chiseled Ubuntu Containers are a minimal version of Ubuntu image with enhanced security: 

* There is no shell or package manager installed;
* Only needed libraries and utilities are installed;
* Using unprivileged user by default;

Chiseled Ubuntu Containers (CUC) are available from Ubuntu version 22.04 (Jammy) and are built upon the original Ubuntu operating system but are fully stripped down to include only what's necessary and are extra hardened in terms of security, thereby embracing least privilege principle. An advantage of CUC is that it significantly reduces the attack surface and total amount of security vulnerabilities that you may need to handle.

// not much documentation yet, privileged operations like port binding, new mindset when working with minimal images


Now, let's see Chiseled Ubuntu Containers in action!😼

## Example: Porting Cat Encyclopedia app to .NET 7 and Chiseled Ubuntu Containers and deploying on AKS

If you've seen some of my talks you have probably seen my demo application that spreads lots of love for cats - Cat Encyclopedia😁 This is a simple ASP.NET web application that initially was using Ubuntu Jammy (22.04) base image. Now, let's port it to ASP.NET 6 Ubuntu Chiseled Container image and finally upgrade to ASP.NET 7.

You can find the source code for CatEncyclopedia app in this GitHub repo: []()

The process is pretty straightforward and as creators state themselves, shouldn't require any modifications for most of the applications.
First of all we will need to update the base image in ```Dockerfile``` from ```mcr.microsoft.com/dotnet/aspnet:6.0-jammy``` to ```mcr.microsoft.com/dotnet/nightly/aspnet:6.0-jammy-chiseled```. Also, we must ensure that we're binding our container to a non-privileged port, i.e. a port that is higher than ```1024```. By default Chiseled Ubuntu Containers use port ```8080``` so that's the one we will use as well.

``` bash

# Dockerfile
FROM mcr.microsoft.com/dotnet/nightly/aspnet:6.0-jammy-chiseled

COPY CatEncyclopedia/src App/
WORKDIR /App

ENV PORT 8080
EXPOSE 8080

ENTRYPOINT ["dotnet", "CatEncyclopedia.dll"]

```

Now, in order to deploy the new container image to AKS, we will need to update the container port in the Deployment specification and the port in the Service specification of Cat Encyclopedia Helm chart, and we're all set!🤩

> ***Please note that Chiseled Ubuntu Containers are supported on AKS version 1.25 or newer since it requires Ubuntu 22.04.***

``` yaml
# deployment.yaml

# REST OF THE CODE IS OMITTED

containers:
- name: {{ .Chart.Name }}
    securityContext:
    {{- toYaml .Values.securityContext | nindent 12 }}
    image: "{{ .Values.image.repository }}:{{ .Values.image.tag | default .Chart.AppVersion }}"
    imagePullPolicy: {{ .Values.image.pullPolicy }}
    ports:
    - name: http
        containerPort: 8080 # <- Update container port on which to expose application container in a Pod
        protocol: TCP

# REST OF THE CODE IS OMITTED
```

``` yaml
# values.yaml

# REST OF THE CODE IS OMITTED

service:
  type: ClusterIP
  port: 8080 # <- Update port of the Service that's created for Cat Encyclopedia Pods

# REST OF THE CODE IS OMITTED
```

Now, once we build new container image and Helm chart we can deploy it to AKS and it still works as expected!

![Screenshot of a working ASP.NET Cat Encyclopedia application on Chiseled Ubuntu Containers](../../images/dotnet_chiseled/cat_encyclopedia_chiseled.png)

If we want to upgrade it to ASP.NET 7 we will only need to update application source code to target .NET 7 and update the base image in the Dockerfile to ```mcr.microsoft.com/dotnet/nightly/aspnet:7.0-jammy-chiseled```.

We can compare the size of the image before and after we started using Ubuntu Chiseled Containers with ```docker images``` command - as you can see in the screenshot below the latter is 100MB+ smaller, just as stated in the release announcement😁

![Screenshot image size comparison for ASP.NET Cat Encyclopedia application before and after Chiseled Ubuntu Containers](../../images/dotnet_chiseled/dotnet_docker_images.png)

Let's run a security scan for both of the images and see how many vulnerabilities will be detected in each case. For this purpose I have used a tool called [Trivy](https://github.com/aquasecurity/trivy). For the Cat Encyclopedia image built upon ASP.NET 6 Ubuntu Jammy base image Trivy detected 16 security vulnerabilities related to the operating system:

![Screenshot for Trivy security scan of the Cat Encyclopedia image built upon regular ASP.NET 6 Ubuntu Jammy base image](../../images/dotnet_chiseled/dotnet_jammy_trivy.png)

Whilst for the Cat Encyclopedia image built upon ASP.NET 6 Chiseled Ubuntu base image Trivy detected .... 0 security vulnerabilities!🙀

![Screenshot for Trivy security scan of the Cat Encyclopedia image built upon ASP.NET 6 Chiseled Ubuntu base image](../../images/dotnet_chiseled/dotnet_chiseled_trivy.png)

This is a pretty impressive result in my opinion, what do you think?😺

Finally, let's give it a test and try to start a shell inside a container or run some shell commands like for example to check what packages are installed - as you can see in the screenshot below, we're not able to do that and it makes sense since Chiseled Ubuntu Containers don't have any shell installed. But, we can run dotnet commands since .NET CLI is needed for the ASP.NET container and is therefore pre-installed as part of the image.

![Screenshot where I attempt to run some shell commands towards runnign ASP.NET 6 Chiseled Ubuntu image](../../images/dotnet_chiseled/dotnet_chiseled_shell.png)

## Additional resources

Below you may find a few resources to learn more about Chiseled Ubuntu Containers for .NET applications and securing containerized applications in general:

- Official announcement on .NET Blog about support for using .NET in Chiseled Ubuntu Containers starting with .NET 6: [.NET 6 is now in Ubuntu 22.04](https://devblogs.microsoft.com/dotnet/dotnet-6-is-now-in-ubuntu-2204/)
- Great list from OWASP of common security mistakes and good practices that will help you secure your Docker containers: [Docker Security Cheat Sheet¶](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- GitHub repo where you can find source code for the demo app used in this blog post, including Dockerfile and Helm chart: [guidemetothemoon](https://github.com/guidemetothemoon/speaker-demos/tree/main/aks-ado-environments)

That\'s it from me this time, thanks for checking in!💖

If this article was helpful, I\'d love to hear about it! You can reach out to me on LinkedIn, Twitter, GitHub or by using the contact form on this page.😺

Stay secure, stay safe.

Till we connect again!😻