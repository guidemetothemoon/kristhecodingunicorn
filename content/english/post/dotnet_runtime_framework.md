+++
author = "Kristina D."
title = "How to override ASP.NET Core application runtime version"
date = "2022-07-23"
description = "In this post we take a look at how we can make an ASP.NET Core application use a different runtime version than the one it was compiled with."
draft = false
tags = [
    "techtips",
    "dotnet"
]
slug = "dotnet-override-app-runtime-version"
aliases = ["/techtips/dotnet_runtime_framework"]
+++

{{< table_of_contents >}}

With release of .NET and .NET Core one significant change you may have noticed is the new version support lifecycle. .NET Framework LTS (long-time support) versions are normally supported for 5+ years by Microsoft but support lifecycle for .NET and .NET Core LTS versions has decreased to 3 years. The main reasons for the shorter support lifecycle are the overall faster technology evolvement, but also more active framework development which requires frequent releases both from the functional and security perspective.

Upgrading framework version that the application is built on top of can be a challenging, time-consuming process, especially for large and complex enterprise applications. If you have hundreds of on-premises customers that are using your application in their own infrastructure this process becomes even harder.😵 In order to upgrade the application\'s framework you will typically need to update the version property, re-compile the app and publish a new release. In addition you will need to test the new version properly in order to ensure that porting your app to new framework version hasn\'t introduced any breaking changes. If it has, some amount of refactoring will be required in order to fix the errors that the new framework version is causing.

Doing this every three years may be hard and even unrealistic in some scenarios but still, you don\'t want to run with unsupported framework installed on your server, right?🙄 So, is there any temporary workaround that may buy you some time so that you can port your application to a newer framework version and at the same time only have a supported framework installed on the server where your application is hosted? Yes, there may be a way and I\'ll tell you all about it in a moment!😺

There is a configuration property that can let you override the runtime framework version that an ASP.NET Core application is using though the application is compiled with a different version of the framework. In order to do that you will need to locate a ```[application-name].runtimeconfig.json``` file that is published as part of the ASP.NET Core application. This file provides configuration properties that define .NET application\'s behaviour at run time. In ```[application-name].runtimeconfig.json``` file update ```runtimeOptions.framework.version``` property to the runtime framework version that you want your application to use. For example, if I have an ASP.NET Core 5.0 application and I want it to use ASP.NET Core 6.0 version, my JSON file will look like this:

``` bash
{
  "runtimeOptions": {
    "tfm": "net5.0",
    "framework": {
      "name": "Microsoft.AspNetCore.App",
      "version":  "6.0.0", # <- update this property to override runtime framework version!
      "rollForward":  "major"
    },
    "configProperties": {
      "System.GC.Server": true,
      "System.Runtime.Serialization.EnableUnsafeBinaryFormatterSerialization": false
    }
  }
}
```

Now, my ASP.NET Core application that was compiled with .NET 5.0 will use .NET 6.0 as a runtime framework which will let me uninstall .NET 5.0 and only install .NET 6.0 on the server where the application is running.

If you want to do it programmatically, you can call this PowerShell function and provide a path to the ```[application-name].runtimeconfig.json``` file as an argument to the function:

``` bash
function Edit-RuntimeConfig($jsonFilePath)
{
    $appRuntimeConfigJson = Get-Content $jsonFilePath -Encoding UTF8 | ConvertFrom-Json
    $appRuntimeConfigJson.runtimeOptions.framework.version = "6.0.0" # this property can be updated with any other runtime framework version you may want to use
    $appRuntimeConfigJson.runtimeOptions.framework | Add-Member -Name "rollForward" -Value "major" -MemberType NoteProperty -Force
    $appRuntimeConfigJson | ConvertTo-Json | Out-File $jsonFilePath -Encoding UTF8
}
```

> It\'s important to note that this change should be considered as a **temporary** workaround and the recommended approach is to lift your application to the newest supported ASP.NET version. It\'s also recommended to test that the application works as expected after this configuration change has been implemented, and before rolling out the change to production environment. This is important in order to ensure that there are no breaking changes in the new framework version that are affecting your application\'s functionality.

You can also read more about .NET Runtime configuration settings here: [.NET Runtime configuration settings](https://docs.microsoft.com/en-us/dotnet/core/runtime-config/) and about .NET and .NET Core support lifecycle here: [.NET and .NET Core Support Policy](https://dotnet.microsoft.com/en-us/platform/support/policy/dotnet-core).

Thanks for reading and till next tech tip! 😻
