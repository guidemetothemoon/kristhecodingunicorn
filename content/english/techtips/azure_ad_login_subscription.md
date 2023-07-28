+++
author = "Kristina D."
title = "Log in to Microsoft Entra ID without active subscription from Azure CLI"
date = "2022-07-15"
description = "In this post we take a look at how you can log in to an Microsoft Entra ID without active subscription from Azure CLI."
draft = false
tags = [
    "techtips",
    "azure",
    "azure-cli",
    "azure-ad"
]
+++

{{< table_of_contents >}}

In some cases you may have an Microsoft Entra ID tenant that doesn't have an active subscription connected to it but you would nevertheless want to log in to it from a command line for instance, with Azure CLI. You may want to perform actions like creating a Microsoft Entra ID Application for example. In this case you need to be cautious about the login command you're running so that you don't waste a lot of time on debugging an error you could have avoided in the first place (like someone did 😁)!

If you attempt to log in to an Microsoft Entra ID tenant like this:  ```az login --tenant [your_azure_ad_tenant_id]``` and you don't have an active subscription it will look like a login was successful: you will be redirected back from the Azure login window to the command line, but you may see an error message in the output stating: ```No subscriptions found for testuser@mytest.onmicrosoft.com.``` (which is kind of expected).

If you then ignore this error message and attempt to create an Microsoft Entra ID Application in this tenant, you will get following behaviour:

``` cmd
PS C:\Playground> az ad app create --display-name testapplication --sign-in-audience AzureADMyOrg --web-redirect-uris https://testapplication.com/callback
ERROR: Directory permission is needed for the current user to register the application. For how to configure, please refer 'https://docs.microsoft.com/azure/azure-resource-manager/resource-group-create-service-principal-portal'. Original error: Insufficient privileges to complete the operation.
```

The error message doesn't necessarily tell you that you're still not properly logged in, and it may result in a lot of confusion when you know that your user or service principal has more than enough permissions to perform this operation.🙄

The clue here is to use ```--allow-no-subscriptions``` property which will allow you accessing tenants without active subscription from Azure CLI. So your login command will then look like this:

```az login --tenant [your_azure_ad_tenant_id] --allow-no-subscriptions```

Once the command has been executed you will be able to successfully create an application or perform other actions towards the respective Microsoft Entra ID tenant with Azure CLI.😺

You can read more about ```az login``` command here: [az login](https://docs.microsoft.com/en-us/cli/azure/reference-index?view=azure-cli-latest#az-login)

Thanks for reading and till next tech tip! 😻
