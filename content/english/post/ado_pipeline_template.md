+++
author = "Kristina D."
title = "Creating reusable build tasks in Azure DevOps pipelines with templates"
date = "2022-06-24"
description = "In this post we take a look at how to implement reusable build tasks in Azure DevOps pipelines with templates."
draft = false
tags = [
    "techtips",
    "azure-devops",
    "devops"
]
slug = "azure-devops-pipeline-templates-for-reusable tasks"
aliases = ["/techtips/ado_pipeline_template"]
+++

{{< table_of_contents >}}

## Use case for pipeline templates

In the world of complex enterprise applications and distributed systems you may have a need to perform many more actions and validations as part of a build pipeline than before:

- build an application,
- execute multiple types of tests like unit tests and API tests,
- perform security validations like SCA, SAST, container image scanning and scanning of third-party dependencies,
- perform application packaging and deployment,
etc.

That\'s when it\'s worth considering to implement a multi-staged pipeline where you can run several jobs in parallel and control application flow with stages. Each stage may then have it\'s own set of checks and validations. You may even have multiple applications which have similar build tasks as part of the build pipeline - for instance, if you have multiple .NET Web API applications, it\'s very likely that build pipelines for those will be similar to some extent.

**So, instead of duplicating build tasks in every build stage or in every build pipeline, can you optimize this somehow?** Yes, you can! By introducing re-usability with build templates. 😺

A template in this case is a collection of tasks that can be re-used across build pipelines and build stages. With parameters and build conditions you can dynamically adjust configuration for the template depending on the stage or pipeline where the template is being integrated.

So, let\'s take a look at some examples!😼

## Example 1: re-use template in multiple build pipelines

Let\'s say you have a collection of build tasks that you need to add to several build pipelines in your project. For example, build tasks that download some build artifacts, install some tools and run some common scripts. What you can do then is to make these tasks reusable by creating a YAML template and storing it in a common repo that can be referenced from all the respective pipelines. Here\'s an example of such a template YAML that is stored in a repo called ```common-templates```:

```yaml
# prep-env-template.yaml

- task: UseDotNet@2
  inputs:
    packageType: 'sdk'
    version: '6.x'

- task: DownloadPipelineArtifact@2
  displayName: 'Download Build Artifacts - File Viewer'
  inputs:
    buildType: 'specific'
    project: '3c8d4d22-f3d0-11ec-b939-0242ac120002'
    definition: '007'
    buildVersionToDownload: 'latestFromBranch'
    branchName: 'refs/heads/master'
    artifactName: 'my-artifact'
    targetPath: '$(Build.SourcesDirectory)/temp/my-artifact'

- task: PowerShell@2
  displayName: 'Update service data'
  inputs:
    filePath: 'build-scripts/Update-Service.ps1'
    
```

As you can see, this template installs latest version of .NET 6 SDK on the build agent, downloads artifact from another repo\'s build and executes a PowerShell script to update some data for the service. Now, in every build pipeline where we want to execute these tasks we can check out the ```common-templates``` repo and integrate template with a ```template``` build task, like this:

```yaml
# azure-pipeline.yaml

... 

- job: prepare_environment
  timeoutInMinutes: 60
  pool:
    vmImage : 'ubuntu-latest'

  steps:
  - checkout: common-templates # integrate another repo into current pipeline
  - template: prep-env-template.yaml # load and execute build tasks from provided template

...

```

And you\'re all set! 🤟

## Example 2: re-use parameterized template in multiple build stages

In this example we have a multi-staged build pipeline for an application where one stage builds the app, executes tests, packages and publishes the application while another stage performs security validations. Both stages need to build an app while only build stage needs to run the tests and publish an app - that\'s when we can dynamically adjust which template tasks should be executed for which stage based on parameterization and task conditions. So in this case we store our template YAML in the same repo as the application, in a ```pipeline-templates``` folder:

```yaml
# build-app-template.yaml

parameters:  
  build: true
  test: true
  publish: false

steps:

- task: DotNetCoreCLI@2
  displayName: 'Build solution'
  inputs:
    command: 'build'
    projects: 'source/My.TestApp.sln'
    configuration: '$(buildConfiguration)' # here we refer a variable defined in main build pipeline definition
    arguments: '-f net6.0'
  condition: and(succeeded(),eq('${{ parameters.build }}', true))

- task: DotNetCoreCLI@2
  displayName: 'Execute unit tests'
  inputs:
    command: 'test'
    arguments: '--no-build /p:CollectCoverage=true /p:CoverletOutputFormat=opencover /p:CoverletOutput=./CodeCoverage/my-testapp/'
    publishTestResults: true
    projects: 'source/My.TestApp.sln'
  condition: and(succeeded(),eq('${{ parameters.test }}', true))

- task: DotNetCoreCLI@2
  displayName: 'Publish application'
  inputs:
    command: publish
    publishWebProjects: false
    arguments: '--configuration $(buildConfiguration) --output $(Build.ArtifactStagingDirectory)/pub-output'
    projects: 'source/My.TestApp/My.TestApp.csproj'
    zipAfterPublish: false
  condition: and(succeeded(),eq('${{ parameters.publish }}', true))

```

As you can see, in the top of the template we have ```parameters``` section where we define which parameters that can be sent to the template and what the default values for those parameters should be. With ```condition``` property on every build task we can refer to respective parameters and activate the task based on the provided value of the parameter.

Now, in every stage of our main build pipeline we can dynamically adjust how the template should be executed, also by using ```parameters``` property:

```yaml
# azure-pipeline.yaml

...
stages:
- stage: Build
  jobs:
  - job: BuildApplication
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    
    ...
    
    - template:  pipeline-templates/build-app-template.yaml
      parameters:
        build: true
        publish: true
        test: true
    
    ...

- stage: Security
  jobs:
  - job: SecurityChecks
    pool:
      vmImage: 'ubuntu-latest'
    steps:
    
    ...
    
    - template:  pipeline-templates/build-app-template.yaml
      parameters:
        build: true
        publish: false # no need to publish app in this stage -you can also skip providing this parameter - then default value will be used which is also 'false'
        test: false # no need to run tests in this stage
    
    ...

```

And we\'re good to go!😸

Build templates can really help you make your pipeline code more reusable and keep the build pipeline definition cleaner and smaller since you don\'t need to duplicate the same build tasks every single time, which is always nice. 💖

You can learn more about templates here: [Template types & usage](https://docs.microsoft.com/en-us/azure/devops/pipelines/process/templates?view=azure-devops)

Thanks for reading and till next tech tip! 😻
