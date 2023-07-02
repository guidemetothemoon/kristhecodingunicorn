+++
author = "Kristina D."
title = "How to modify Azure Arc (or any) Service Principal scope after creation"
date = "2023-01-04"
description = "In this tech tip we take a look at how you can easily update the scope of an Azure Arc Service Principal or any other Service Principal after it has been created."
draft = false
tags = [
    "techtips",
    "azure",
    "azure-arc",
    "devops"
]
+++

A thought struck me one day when I was working with onboarding machines to Azure Arc. If you want to onboard multiple servers at scale to Azure Arc, you would need a Service Principal with ```Azure Connected Machine Onboarding``` role in the respective subscription or resource group where you want to create Azure Arc-enabled servers. An interesting thing here is: what if you would like to re-use the same service principal in order to onboard more Azure Arc resources but to another subscription and/or another resource group? 

**Is there a way you can modify the scope of the Azure Arc Service Principal, or any regular Service Principal for that matter, after it's been created?** 🧐

If you have wondered about the same thing at some point then I have an answer to you and it's...**AFFIRMATIVE**! 😸

Service principal is basically an identity that can be used to access Azure resources, which means that the scope, where it has specific permissions, can be altered with help of Azure role-based access control (RBAC).

You can change it both in the Azure portal and with Azure CLI.

In Azure portal you can navigate to Access Control section of the respective Azure resource, for example Subscription or Resource Group in case of Azure Arc Service Principal, and add a role assignment of your choice to the Service Principal of your choice:

![Screenshot of adding resource group role assignment to Azure Arc Service Principal](../../images/tech_tips/azure_arc_sp_portal.png)

> Please note that you will need to provide full name of the Service Principal in the members search field in order for Azure to make it available for role assignment choice.

In Azure CLI you can create a role assignment either by providing a ```--resource-group``` argument if you want to assign a role on the resource group level, or a ```--scope``` argument if you want to assign a role on the Azure resource level. ```--scope``` value is a resource ID in Azure so if I were to assign a role on the subscription level I would use ```--scope "/subscriptions/<subscription_id>"```. 

```az role assignment create --assignee-object-id <service_principal_id> --role <role_name> --resource-group <resource_group_name> --assignee-principal-type ServicePrincipal```

You can retrieve Service Principal ID that you can use for ```--assignee-object-id``` with this command: ```az ad sp list --display-name <service_principal_name>```

For example:

``` bash
kris@kris-Latitude-7410:~$ az ad sp list --display-name sp-azure-arc-servers | grep id

"id": "a6be4614-ef7e-44af-bc7a-47bc0df0ec96",

```

> Please note that you should provide both ```--assignee-principal-type``` and ```--assignee-object-id``` in order to avoid unplanned conflicts or mismatches in the role assignment.

So, if we use the same example as we used with Azure portal above, and assign ```Azure Connected Machine Onboarding```  role to ```sp-azure-arc-servers``` Azure Arc Service Principal in ```chamber-of-secrets-rg``` with Azure CLI:

![Screenshot of adding resource group role assignment to Azure Arc Service Principal with Azure CLI](../../images/tech_tips/azure_arc_sp_cli.png)

Once we run this command, in the Azure portal, in service Principals section of Azure Arc, we can see that existing Service Principal has now two different scopes for different resource groups:

![Screenshot of Azure Arc Service Principal with multiple scopes in Azure Portal](../../images/tech_tips/azure_arc_sp_scope_portal.png)

You can read more about Azure Service Principals here: [Service principal object](https://learn.microsoft.com/en-us/azure/active-directory/develop/app-objects-and-service-principals#service-principal-object)

That\'s it for now - Thanks for reading and till next tech tip 😼