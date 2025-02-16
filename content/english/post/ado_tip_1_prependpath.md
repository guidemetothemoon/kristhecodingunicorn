---
author: "Kristina Devochko"
title: "Azure DevOps Bits and Bobs: #1 - How to update PATH environment variable"
date: "2025-02-16"
description: "In this blog post we will explore the proper way of updating PATH environment variable on Azure Pipelines build agents and what other logging commands are available in Azure DevOps."
draft: false
tags: [
    "azure",
    "devops",
    "azure-devops",
    "azure-devops-tips"
]
slug: "azure-devops-prepend-path"
---

This is the first post of a blog post series which I have proclaimed as **Azure DevOps Bits and Bobs**, where I will share randomly chosen but still useful and good-to-know functions in Azure DevOps. Today we will take a look at the best way to update `PATH` environment variable on a build agent, as well as get an overview of other logging commands are available to us in Azure DevOps.

Sometimes, as part of the CI/CD process you may need to install a tool explicitly, for example because an out-of-the-box build task is not available for this tool or the task has limitations and you would like to customize the tool more granularly upon installation. In that case, if you are running all or parts of CI/CD on Windows build agents you will most likely need to update the well-known `PATH` environment variable on the build agent after the tool has been installed. This update is needed so that subsequent tool commands and subsequent build tasks calling the tool are able to find the tool binary to execute the requested command.

You could of course write up some PowerShell code to update the `PATH` variable, but you would also need to ensure that you have additional code in place to start a new process so that the modified `PATH` value is available. That introduces overhead, but fortunately there's a simple, native way to achieve the same goal!🥳

In Azure DevOps, specifically in Azure Pipelines, there exists a bunch of logging commands which are basically special commands that can be called by a script build task (Bash or PowerShell) to do a specific action on the build agent. An action may be to upload a log file to a specific build folder, update build number or define a variable that can even be shared across build stages.

There are different types of commands that serve different purposes:

- **Formatting commands**: meant for the log formatter that is used to log build task execution and provide instructions on what message type should be used for a specific text/logging statement (f.ex. warning, error or debug).
- **Task commands**: meant for performing a set of varying actions/tasks as part of the build execution like defining a variable, registering job secret or adding custom Markdown file to the build summary.
- **Artifact commands**: meant for actions related to build artifacts like upload to a specific directory.
- **Build commands**: meant specifically for updating something within current build like updating the build number or adding a custom build tag.
- **Release commands**: meant specifically for updating something within current release like updating the release name.

For our use case we will refer a command in the Task category which is called `PrependPath` - this command can be used to specify which path must be added to the `PATH` environment variable and all the subsequent build tasks will refer to the updated value of the variable.

For example, if I were to explicitly customize and install a tool like Trivy for security scanning purposes I would use `PrependPath` to add Trivy's binary path after it's been installed like this:

``` yaml
- pwsh: |
    Write-Host "##vso[task.prependpath]$(System.DefaultWorkingDirectory)/trivy"
  name: 'UpdatePath'
  displayName: 'Add Trivy binary path to PATH'
```

All the build tasks that will call Trivy tool after the above task will be able to locate its binary as expected so my work here is done!😎

Overview of all the logging commands in different categories is available here: [Logging commands](https://learn.microsoft.com/en-us/azure/devops/pipelines/scripts/logging-commands)

That's it from me this time, thanks for checking in!
If this article was helpful, I'd love to hear about it! You can reach out to me on LinkedIn, GitHub or BlueSky 😊

Stay secure, stay safe.
Till we connect again!😼
