+++
author = "Kristina D."
title = " Detect and avoid this certificate validation trap in .NET!"
date = "2022-07-18"
description = "In this post we take a look at how to use ServerCertificateValidationCallback cautiously in .NET without creating security vulnerability in the code."
draft = false
tags = [
    "techtips",
    "dotnet",
    "cybersecurity-corner"
]
+++

{{< table_of_contents >}}

There is one scary property in .NET which, if misused or forgotten, can make your security champions tremble at night...🙀🙀🙀 As scary as it sounds, the risk of forgetting or misusing the property is pretty serious and I\'ve seen it multiple times sneaking into the source code as part of the pull request. And I keep seeing it still. Therefore this tech tip gets to see the world.☀️

The property I\'m talking about is ```ServicePointManager.ServerCertificateValidationCallback``` that is part of a ```System.Net``` library. This property can be used for custom certificate validation in case you\'re using a non-trusted certificate authority. One of the scenarios when you can end up using this property is when you\'re developing and testing new functionality and you\'re using a self-signed TLS certificate on the server instead of production-level certificates. If this property is not set and you\'re using a non-trusted certificate, you may get errors like: ```The underlying connection was closed: Could not establish trust relationship for the SSL/TLS secure channel.```

The danger of it is though that once you\'re done with testing you may forget to clean it up in the source code, and it silently paves it\'s way out to production... What it results into is that **all TLS certificates will be accepted and all HTTPS traffic will be allowed, even the malicious one!** This can be extremely destructive from the security perspective and can open up for the man-in-the-middle vulnerability for instance.🔥

So, whenever you see a variation of this piece of code: ```ServicePointManager.ServerCertificateValidationCallback += (sender, cert, chain, error) => true;```

**Stall the change immediately** and take your time to ensure that you or the one who has added this piece of code know what you\'re doing and understand the consequences of enabling this property!⛔️

A good thing is that if you\'re using a Static Application Security Testing (SAST) tool like NDepend, you will get alerted in case anyone attempts enabling this property as part of the PR since a validation like this is typically a part of the security rules collection of the SAST tool.

**An important note on alternative implementation in .NET Core and .NET:** though ```ServicePointManager.ServerCertificateValidationCallback``` is supported both in .NET Framework, in .NET Core and .NET I would recommend to consider an alternative implementation. In .NET a new ```HttpClientHandler``` property - ```HttpClientHandler.DangerousAcceptAnyServerCertificateValidator``` - makes deactivation of certificate validation for development purposes more secure and scoped to development environment only. For instance, in ```Startup.cs``` of your ASP.NET Core Web application you can enable it for development purposes like this:

``` csharp
if ( env.IsDevelopment() )
{
    httpClientHandler.ServerCertificateCustomValidationCallback = HttpClientHandler.DangerousAcceptAnyServerCertificateValidator;
}
```

You can read more about this property here: [HttpClientHandler.DangerousAcceptAnyServerCertificateValidator Property](https://docs.microsoft.com/en-us/dotnet/api/system.net.http.httpclienthandler.dangerousacceptanyservercertificatevalidator?view=net-6.0)

If you would like to learn more about ```ServerCertificateValidationCallback``` property, you can check this link: [ServicePointManager.ServerCertificateValidationCallback Property](https://docs.microsoft.com/en-us/dotnet/api/system.net.servicepointmanager.servercertificatevalidationcallback?view=net-6.0)

And here you can check one of the Microsoft quality rules which also is about cautious usage of ```ServerCertificateValidationCallback``` property: [CA5359: Do not disable certificate validation](https://docs.microsoft.com/en-us/dotnet/fundamentals/code-analysis/quality-rules/ca5359)

Stay secure, stay safe!

Thanks for reading and till next tech tip! 😻
