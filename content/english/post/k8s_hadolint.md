+++
author = "Kristina D."
title = "Applying Dockerfile best practices with Hadolint"
date = "2022-11-10"
description = "In this blog post we'll look into how we can ensure that Dockerfiles we create are following best practices with Hadolint tool."
draft = true
tags = [
    "kubernetes",
    "aks",
    "k8s",
    "azure"
]
+++

![Article banner for applying Dockerfile best practices with Hadolint](../../images/k8s_an/k8s_hadolint_banner.png)

{{< table_of_contents >}}

In this blog post I would like to take a look at how we can ensure that Dockerfiles we create are of high quality and are following best practices in the industry. Tools like Hadolint make it very easy for us to do that and can automate the verification process.

If you're working with containerized applications or are planning on containerizing an application you will most likely be working with Dockerfile. Dockerfile is a variation of a text file (without file extension though) where you define a set of instructions for assembling, configuring and starting up your application container image. Those instructions are then compiled during the build process (for example, with ```docker build``` command) and are packaged into an artifact known as a container image, which may then be pushed to a container registry like Docker Hub or Azure Container Registry. 

You can read more about it in official Docker documentation: [Dockerfile reference](https://docs.docker.com/engine/reference/builder)

## Hadolint - Introduction and benefits

Code linters help a lot with ensuring that the code you're writing is following quality guidelines and a set of established best practices, both in the industry and in your organization (which you can define through custom rules if the tool supports it).

Dockerfile is not an exception. Tools like Hadolint can help you keep Dockerfile instructions clean, avoid unnecessary instructions and optimize existing ones. What I also like a lot about Hadolint is that it integrates with ShellCheck which is an open source tool that is used for static analysis of shell scripts, for example written in Bash. This integration allows Hadolint to not only flag issues in the Dockerfile instructions, but it will also flag issues with shell commands that are a part of the same Dockerfile (for instance, commands that are executed as part of the ```RUN``` instruction).

Now let's see how Hadolint can be installed and used for Dockerfile linting.

## Installation and execution options for Hadolint

Hadolint can be installed from pre-built binaries, source code or as a Docker image. You can find more information about it in the official documentation which is linked in the Additional resources section below. If you're using Visual Studio Code then you can also install Hadolint as a VSCode extension for local development and linting. When it comes to CI/CD integration I could only find officially provided support for GitHub Actions: [Hadolint Action](https://github.com/hadolint/hadolint-action). When it comes to Azure DevOps for example, there is no official extension for the same but below I will show you how it can be implemented.

A few configuration options that are worth mentioning:

* ```--config [path_to_config_yaml]``` can be used to provide a path to a configuration file that can be used by Hadolint for customizing execution to your needs. Configuration can also be provided as command input but I prefer using a configuration file to keep it cleaner and better structured. All of the below properties can also be defined in the configuration file;
* ```--failure-threshold [rule_severity]``` can be used to define when Hadolint should fail execution. For example, if you want it to fail in case any warnings and/or errors are detected, you can define it like ```--failure-threshold warning``` - in this case, all rules with severity warning or higher will cause Hadolint to fail.
* ```--trusted-registry [registry]``` is a very nice configuration option as well - it can be used to define which container registries are allowed to be used as part of the FROM instruction. This is a good policy from the security perspective because it allows you to whitelist only a set of trusted container registries and prohibit importing base images from any other container registries. So if you would only whitelist your private Azure Container Registry you could define it like ```--trusted-registry kristhecodingunicorn.azurecr.io```.
* ```--format``` can be used to specify which format you would like Hadolint to produce result report in. For Azure DevOps it may be worth considering using ```--format sarif``` for example, because you could integrate the output of Hadolint to a dedicate tab in the build pipeline overview - I will show how it looks like in a jiff😊

Now, let's see Hadolint in action!

### CI/CD (Azure DevOps and GitHub Actions)

``` yaml
# azure-pipeline.yaml

- job: Build
  steps:
  - task: Bash@3
    displayName: Lint Dockerfile with Hadolint for best practice compliance
    inputs:
      targetType: 'inline'
      script: |
        sudo apt-get update
        echo 'Downloading Hadolint to lint Dockerfile...'
        wget https://github.com/hadolint/hadolint/releases/download/v2.10.0/hadolint-Linux-x86_64
        chmod +x hadolint-Linux-x86_64
        mv hadolint-Linux-x86_64 hadolint
                
        echo 'Start Dockerfile lint...'
        ./hadolint --config hadolint.yaml docker/Dockerfile
``` 

Below you can see an example of Hadolint output:
![Screenshot of Hadolint tool output](../../images/k8s_hadolint/k8s_hadolint_output.png)


``` yaml
# hadolint.yaml: 
failure-threshold: error
ignored:
  - DL3009 # false positive, apt-get lists are deleted on line 13
  - DL4006 # false positive, -o pipefail is set via explicit RUN statements on line 12 and 31
``` 

### Local development (VSCode Extension)





## Additional resources

* Hadolint VSCode extension: [hadolint](https://marketplace.visualstudio.com/items?itemName=exiasr.hadolint)
* Hadolint source code on GitHub: [Haskell Dockerfile Linter](https://github.com/hadolint/hadolint)
* ShellCheck documentation: [ShellCheck Wiki](https://www.shellcheck.net/wiki/Home)
* Docker provides some of the best practices for writing Dockerfiles in their official documentation: [Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices)

That\'s it from me this time, thanks for checking in! 

If this article was helpful, I\'d love to hear about it! You can reach out to me on LinkedIn, Twitter, GitHub or by using the contact form on this page 😺

Stay secure, stay safe.

Till we connect again!😻