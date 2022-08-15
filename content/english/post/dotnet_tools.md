+++
author = "Kristina D."
title = "How to distribute console applications easily with .NET tools"
date = "2021-06-06"
description = "This blog post explains how packaging console apps as .NET tools will make it possible to distribute them in a faster and easier manner."
draft = false
tags = [
    "dotnet",
    "tooling"
]
+++

![Article banner for dotnet custom templates](../../images/dotnet_tools/dotnet_tools_banner.png)

{{< table_of_contents >}}

There are probably no developers out there (or at least very few) who have never created a console application - use cases where such apps are a first choice are hundreds, if not thousands. In my team we have several administrative tools that are being distributed as console apps in addition to the main application. Multiple stakeholders are using these apps in order to easily perform administrative tasks, make changes to application\'s metadata, interact with the database, integrate customizations into standard application functionality, etc. 

Initially, the tools were distributed as part of the main application\'s setup which proved to be **not** a very scalable approach: 
- tools didn\'t follow the release cycle of the main application and sometimes were changed more frequently, therefore it was more time-consuming and challenging to distribute the new version of the tools to all the stakeholders;
- in order to get access to the tool you either needed to have access to the application server where the setup package is located or you needed to have access to the internal portal from where the setup package could be downloaded;
- you could also download the tool from the build pipeline but finding the correct pipeline and downloading the stable version of the tool may be frustrating, especially when you don\'t know where to look.

In order to make this process more user-friendly we have decided to package all our admin tools as .NET tools and make them available to all the relevant stakeholders in the private NuGet feed. I\'ll now describe in more detail how this can be done.


## What is a .NET Tool and how do I create one?

.NET tool is basically a way to package your application as a NuGet package that can be made easily available for relevant audience on the NuGet feed of your choice - be it a global NuGet feed or a private one. What I think is a huge benefit of distributing console apps as .NET tools is that it provides an easy and smooth way to keep your utilities up-to-date and make the latest version easily available at all times for everyone who requires to use it. Installation process will also be much easier - no need to search for a specific build with stable build artifacts, correct setup package, etc..You can install a .NET tool by simply running a single command in the command line, and you\'re good to go.

***It\'s important to mention that until .NET 5 it was also possible to distribute WinForms and WPF applications as .NET tools but from .NET 5 it is not supported anymore. It might be supported in .NET 6 but there is no guarantee - you can follow this***  [GitHub issue](https://github.com/dotnet/sdk/issues/16361) for more updates on the topic.

Let\'s look at the whole flow from creating a .NET tool to installing/uninstalling it. I have created a console app that will make it easier to perform some administrative tasks for my application like turning on/off feature toggles, adding or modifying settings, etc. Target framework for my app is .NET 5.0.

In order to convert my app to a .NET tool I will need to add following 3 properties to the .csproj file:

{{< highlight xml >}}
<PackAsTool>true</PackAsTool>
<ToolCommandName>admincli</ToolCommandName>
<PackageOutputPath>./nupkg</PackageOutputPath>
{{< /highlight >}}

And my console app is now a .NET Tool! Well, that was not that hard, was it? :) 

First property defines that current tool will be packaged as a .NET tool. Second property is optional and defines the command you will need to use in order to start the tool after it has been installed. And lastly, third property, which is also optional, defines where the NuGet package will be generated. .NET CLI will be using the NuGet package in order to install the tool.

Now my admin tool is ready to be uploaded to a NuGet feed so that others can install and start using it - since I\'m using Azure Pipelines to continuously build it, I will be adding some new build tasks to pack and push the newly created Admin CLI tool to the private NuGet feed.

{{< highlight yaml >}}
- task: DotNetCoreCLI@2
  displayName: 'dotnet pack Admin.CLI'
  inputs:
    command: pack
    packagesToPack: '**/Admin.CLI.csproj'
    packDirectory: '$(Build.ArtifactStagingDirectory)/nuget-packages'
    versioningScheme: byEnvVar # for centralized versioning of the tool with semantic versioning
    versionEnvVar: GitVersion.NuGetVersion
    arguments: '--configuration $(BuildConfiguration)'

- task: NuGetCommand@2
  displayName: 'NuGet push Admin.CLI'
  inputs:
    command: 'push'
    packagesToPush: '$(Build.ArtifactStagingDirectory)/nuget-packages/*.nupkg'
    nuGetFeedType: 'internal'
    publishVstsFeed: '<My-Private-NuGet-Feed-ID>'
    allowPackageConflicts: false
  condition: and(succeeded(),ne(variables['Build.Reason'], 'PullRequest'),and(eq(variables['Build.SourceBranch'], 'refs/heads/master')))
  continueOnError: false
{{< /highlight >}}

And the tool is now ready for others to use! 

## How to install, use and uninstall a .NET Tool?

A .NET tool can be installed as a global or a local tool. When a .NET tool is installed as a global tool, it\'s binaries will be installed to a default directory of your OS (for example, **%USERPROFILE%\\.dotnet\tools** in Windows) and the path to it will be made available as a part of the **PATH** environment variable. You can also provide a custom directory to install the tool to by providing the **--tool-path** option to **dotnet tool install** command, but in that case you will need to:
* invoke the tool from the directory where it was installed **or**
* provide the full path to the tool upon invoke **or**
* add the tool path to the PATH environment variable manually. 

When a .NET Tool is installed as a local tool, it can be accessed only from the current directory or it\'s subdirectories. In this case you will also need to add the tool to the manifest file which is being used by the .NET CLI to track what tools are installed as local tools to a directory. I will not go into much detail about this installation type but you can read more about it here: [Install a local tool](https://docs.microsoft.com/en-us/dotnet/core/tools/global-tools#install-a-local-tool).

**Security tip: .NET tool runs in full trust, always validate the source and the author of the tool before installing it!**

Before we install the Admin CLI tool that we created in the previous section, we\'ll need to ensure that we have a .NET 5.0 runtime installed since that\'s the framework version that my console app was targeting. Since I have uploaded the tool to the private NuGet feed and not the public one, I will need to be authenticated in order to access any of the packages from that feed - for this I have created a "nuget.config" file where I have provided a personal access token (PAT) that will be used for accessing the NuGet feed. I will be using this file as an input to **--configfile** argument in the install command. You can also register any private NuGet feed on your machine by providing credentials interactively with [dotnet nuget add source](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-nuget-add-source) command.

Now we can install the Admin CLI .NET tool as a global tool by executing following command:

```dotnet tool install --global Admin.CLI --configfile ".\nuget.config"```

It is always a good idea to test that the tool works as expected before pushing it to the NuGet feed - you can do it locally by generating a NuGet package for your console application and installing it as a .NET tool from a generated .nupkg file (please ensure that you\'re running install command from the application directory):

```
dotnet pack Admin.CLI.csproj
dotnet tool install --global --add-source ./nupkg Admin.CLI
```

After the tool is installed, you will get information in the command line output about how you can invoke it. Since I have provided a custom tool command name in the project file definition, I can start the tool by executing **\"admincli\"** command.

{{< highlight txt >}}

You can invoke the tool using the following command: admincli
Tool 'Admin.CLI' (version '1.0.0') was successfully installed.

{{< /highlight >}}

And that\'s it, the tool starts as expected and you\'re ready to use it!

If you\'re dealing with a tool that can be invoked as part of the build pipeline, you can easily install and start it with help of a build task like this:

{{< highlight yaml >}}
- script: |
    dotnet tool install -g Admin.CLI
    admincli --generate-install-scripts 
    exit 0
  displayName: 'Install Admin CLI and generate installation scripts'
  continueOnError: false
{{< /highlight >}}

It\'s a good practice to regularly update the tools you\'re using to the latest version. You can easily update .NET tools by executing following command:

```dotnet tool update -g Admin.CLI```

If you want to uninstall the tool, you can do it by executing following command:

```dotnet tool uninstall -g Admin.CLI```

## Additional resources

You can read more about .NET Tools in Microsoft\'s official documentation: 
- [How to manage .NET tools](https://docs.microsoft.com/en-us/dotnet/core/tools/global-tools)
- [Create tools for the .NET CLI](https://docs.microsoft.com/en-us/dotnet/core/tools/global-tools-how-to-create)
- [dotnet tool commands](https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-tool-install)

That\'s it from me this time, thanks for checking in! 
If this article was helpful, I\'d love to hear about it! You can reach out to me on LinkedIn, GitHub or by using the contact form on this page :)

Stay secure, stay safe.

Till we connect again!
