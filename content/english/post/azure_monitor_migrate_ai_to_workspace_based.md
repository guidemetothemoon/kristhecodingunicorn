+++
author = "Kristina D."
title = "How to automate migration of classic Application Insights instances to workspace-based"
date = "2024-03-01"
description = "In this blog post we will explore how you can easily automate migration of classic Application Insights instances to workspace-based instances at scale"
draft = false
tags = [
    "azure",
    "devops",
    "azure-monitor",
    "application-insights"
]
slug = "migrate-application-insights-to-workspace-based"
+++

{{< table_of_contents >}}

Following the retirement of classic Application Insights in February 2024 I think that it's a great opportunity to share a quick tip on how you can easily automate migration of all of your classic instances to workspace-based Application Insights.

There's a pretty detailed article available as part of Microsoft documentation that walks you through the advantages of workspace-based Application Insights, differences with the classic type and how the table structure differs between those two types. I will not cover it in much detail in this blog post, but I would encourage you to check out the article for more information on the topic: [Migrate to workspace-based Application Insights resources](https://learn.microsoft.com/en-us/azure/azure-monitor/app/convert-classic-resource).

All in all the main difference is that the workspace-based Application Insights stores all the data in the dedicated Log Analytics workspace compared to the classic instances that store data elsewhere. The migration process itself doesn't cause downtime or change in crucial Application Insights settings, like instrumentation key and connection string, which is a big plus. In addition it's a good practice to use a common Log Analytics workspace whenever it's possible, for cost optimization and ease of maintenance - it's possible to do with workspace-based Application Insights where multiple instances can target the same Log Analytics workspace.

Final note before we take a look at automating the migration process is that once all the Application Insights instances are migrated to workspace-based type you can still access the data that was ingested while classic type was used, at least until it reaches the end of its configured retention period. You can query data from both the classic and workspace-based Application Insights in a single view by going to **Application Insights instance page -> Monitoring -> Logs**, as shown in the screenshot below.

![Screenshot of Logs section in Application Insights instance page in Azure portal](../../images/azure_monitor/application-insights-logs-pane.webp)

In order to migrate multiple Application Insights instances from classic to workspace-based type you can use a small PowerShell script below. Here I'm defining a common Log Analytics workspace for all of the migrated Application Insights instances to target, but there's nothing stopping you from using multiple workspaces by modifying this script as you see fit😊

``` powershell

$logAnalyticsWorkspaceResourceId = "/subscriptions/SUBSCRIPTION_ID/resourceGroups/RESOURCE_GROUP_NAME/providers/Microsoft.OperationalInsights/workspaces/LOG_ANALYTICS_WORKSPACE_NAME"

$appInsightsInstances = (az monitor app-insights component show | ConvertFrom-Json) | Where-Object {$_.ingestionMode -ne "LogAnalytics"}

foreach($aii in $appInsightsInstances)
{
    Write-Output "Migrating $($aii.name) to workspace-based mode..."
    az monitor app-insights component update --app $($aii.name) -g $($aii.resourceGroup) --workspace $logAnalyticsWorkspaceResourceId
}

Write-Output "Migration completed!"
```

**What if I provisioned Application Insights instances through Infrastructure-as-Code?**

https://learn.microsoft.com/en-us/azure/azure-monitor/app/convert-classic-resource#how-do-i-ensure-a-successful-migration-of-my-app-insights-resource-using-terraform

That's it from me this time, thanks for checking in!💖

If this article was helpful, I'd love to hear about it! You can reach out to me on LinkedIn, X, GitHub or by using the contact form on this page.😺

Stay secure, stay safe.

Till we connect again!😻
