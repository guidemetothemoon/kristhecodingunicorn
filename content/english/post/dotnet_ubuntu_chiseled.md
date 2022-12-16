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

Before we dive into Chiseled Ubuntu Containers let's set the baseline by looking at common pitfalls when it comes to container security and what are the must do's in order to protect containers against those.

### Containers and root user

One of the most important security improvements that you can have in place for containers is to configure them to run with a non-root user, and to use rootless containers or rootless mode where it's possible and is supported.

When it comes to container security and root user, there are two pieces of the puzzle which is important to know about:

**Running processes inside container as root vs. running processes inside container as unprivileged user.** 

By default if you don't provide a user that processes inside container should run with, root user will be used. Unless you're using rootless containers, which we will talk about in the next item. For example, a process in a container can be an ASP.NET application. The big security risk here is that the process inside the container, an ASP.NET application for instance, still has access to the host system (a server, a VM an application container is running on, a Node in Kubernetes) and can access and modify content on the host as a root user, with the same level of permissions! If there's a vulnerability in the application running in a container that attacker gets ahold of, he/she might be able to escape the container and get access to the host as root! Just imagine how harmful this can be - I wouldn't wish anyone to experience that🙀

Unfortunately quite many third-party images use root user by default, even though recently more and more serious third-party projects at least are either using an unpriveleged user by default in their container images or are offering an alternative image which is unpriveleged. A good example here is NGINX: they offer both a regular image which uses root user by default and an unpriveleged image which uses a user with minimal privileges to run NGINX applcation in a container: [nginxinc/nginx-unprivileged](https://hub.docker.com/r/nginxinc/nginx-unprivileged).

When a third-party image doesn't provide an unprivileged alternative, it may be possible to create a custom image based on the original image where you can create an unprivileged user and override which user is being used to run a container. But there are cases where this is not that easy to do: for example, default ASP.NET image doesn't let you off that easily: [Unable to start Kestrel. System.Net.Sockets.SocketException (13): Permission denied while running alpine as non root user](https://github.com/dotnet/aspnetcore/issues/4699). Often the reason is the default port that container is binded to - there is a restriction in Linux OS which requires a root user if you're using port that is lower than 1024. Often port 80 is used by default which falls under this limitation. Now, Chiseled Ubuntu Containers have come to the rescue though!😺

In case of third-party images it's important that you do your research in order to understand if it uses root user by default or not, and use the options that the creators provide in order to configure the image in the most secure way. In case of creating your own container images, do ensure that you're not using a root user unless it's absolutely necessary. It's also a good idea to implement automatic validation for this, for example through Azure Policy. Automatic policies can detect such misconfigurations and alert in case a fix is required.

Running process inside container as root is the part that is possible to fix quite easily in many cases:
- Define an unprivileged user to run the application in a container;
- Bind to ports higher than 1024;
- Be conscious when choosing third-party images: choose unprivileged image or build an unprivileged custom image on top of the original image;
- In Kubernetes, use PodSecurityContext as additional security layer;
- Implement policies to detect and alert on this type of misconfiguration, for example with Azure Policy;


**Running containers as root vs. rootless containers.**

### Supply chain and third-party dependencies

In most cases, when packaging your applications in a container you will need to use a third-party base image that is built upon an operating system of your choice and has necessary frameworks and tools installed that your application may need in order to run successfully. For example, if you want to run an ASP.NET 6 application on Linux, you would need a base image that includes a Linux distribution of your choice and has ASP.NET 6 installed. In many cases though third-party images may contain lots of unnecessary tools and libraries that your application doesn't need. Having lots of unnecessary components installed results in a broader attack surface for malicious actors to explore. In addition, the more components you have the more security vulnerabilities you may need to handle.

In order to mitigate this you should use minimal container images that include only those tools and utilities that are absolutely necessary. You can then granularly define which additional libraries and tools to include on top of the minimal configuration. Minimal container images come both with security benefits but may also significantly reduce the total container image size which results in faster image download and startup time. 

Now, let's take a look at what Ubuntu Chiseled Containers are and how they can make it easier for us to secure containerized .NET applications.😼

## Chiseled Ubuntu Containers && .NET


## Example: Porting CatEncyclopedia app to .NET 7 and Chiseled Ubuntu Containers and deploying on AKS

``` bash
# Dockerfile
FROM mcr.microsoft.com/dotnet/nightly/aspnet:6.0-jammy-chiseled
COPY CatEncyclopedia/src App/
WORKDIR /App
ENV PORT 8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "CatEncyclopedia.dll"]
```
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
        containerPort: 8080
        protocol: TCP

# REST OF THE CODE IS OMITTED
```

``` yaml
# values.yaml

# REST OF THE CODE IS OMITTED

service:
  type: ClusterIP
  port: 8080

# REST OF THE CODE IS OMITTED
```


## Additional resources

Below you may find a few resources to learn more about Chiseled Ubuntu Containers for .NET applications and securing containerized applications in general:

- Official announcement on .NET Blog about support for using .NET in Chiseled Ubuntu Containers starting with .NET 6: [.NET 6 is now in Ubuntu 22.04](https://devblogs.microsoft.com/dotnet/dotnet-6-is-now-in-ubuntu-2204/)
- Great list from OWASP of common security mistakes and good practices that will help you secure your Docker containers: [Docker Security Cheat Sheet¶](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- GitHub repo where you can find source code for the demo app used in this blog post, including Dockerfile and Helm chart: [guidemetothemoon](https://github.com/guidemetothemoon/speaker-demos/tree/main/aks-ado-environments)

That\'s it from me this time, thanks for checking in!💖

If this article was helpful, I\'d love to hear about it! You can reach out to me on LinkedIn, Twitter, GitHub or by using the contact form on this page.😺

Stay secure, stay safe.

Till we connect again!😻