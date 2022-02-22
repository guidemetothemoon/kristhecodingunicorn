+++
author = "Kristina D."
title = "Power of --query in Azure CLI"
date = "2022-02-13"
description = "Let's take a look at how helpful query parameter can be in Azure CLI."
draft = false
tags = [
    "techtips",
    "azure",
    "azure-cli"
]
+++

![Article banner for power of query in Azure CLI](../../images/tech_tips/techtip_1.png)

Have you ever heard of or used query parameter when running Azure CLI commands? If not, I do recommend you checking it out because this is a pretty powerful parameter that can help you with much faster and efficient data retrieval and filtering!
Let\'s use DNS records retrieval as an example: I need to update DNS records pointing to a specific IP, f.ex. ```192.0.2.146```. 

So, in order to retrieve all DNS records in respective DNS zone pointing to ```192.0.2.146``` with Azure CLI I could either:

1. Retrieve all records registered in respective DNS zone and save them to a variable from which I can filter out only those records pointing to my IP.
2. Use ```--query``` parameter to retrieve only the DNS records pointing to my IP instead of retrieving all of the records at once.

Let\'s see the execution time differences for both - I will use ```Measure-Command``` to measure the time it take to execute each of the approaches. The DNS zone I will be testing against has **64 713** records and I will be replacing real values with dummy ones in the test below since it\'s real name and IP are being used in production :)

{{< highlight bash >}}
# Approach 1
PS C:\Playground> Measure-Command {$dns_list = az network dns record-set a list -g test-rg -z dev.testzone.com; $dns_recs = $dns_list | ConvertFrom-Json -Depth 4 | Where-Object {$_.arecords.ipv4Address -eq "192.0.2.146"}}

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 8
Milliseconds      : 896
Ticks             : 88962891
TotalDays         : 0.000102966309027778
TotalHours        : 0.00247119141666667
TotalMinutes      : 0.148271485
TotalSeconds      : 8.8962891
TotalMilliseconds : 8896.2891

PS C:\Playground> $dns_recs.Count
16

# Approach 2
PS C:\Playground> Measure-Command {$dns_recs_to_update = az network dns record-set a list -g test-rg -z dev.testzone.com --query "[].{Name:name, FQDN:fqdn, IP:aRecords[].ipv4Address}[?contains(IP[],'192.0.2.146')]" | ConvertFrom-Json}

Days              : 0
Hours             : 0
Minutes           : 0
Seconds           : 5
Milliseconds      : 736
Ticks             : 57361877
TotalDays         : 6.63910613425926E-05
TotalHours        : 0.00159338547222222
TotalMinutes      : 0.0956031283333333
TotalSeconds      : 5.7361877
TotalMilliseconds : 5736.1877

PS C:\Playground> $dns_recs_to_update.Count
16

{{< /highlight >}}

As you can see, approach #2 is faster and the difference might not seem so significant here (3-4 seconds) but when you\'re creating a more advanced automation script where you might need to retrieve and refresh DNS records multiple times or when you need to perform maintenance on other types of Azure resources that have even more data to retrieve, the difference can get pretty significant. By utilizing the full potential of Azure CLI you can make your scripts more performant and optimized minimizing the footprint at the same time ;)

```--query``` syntax is based on a query language for JSON called JMESPath and you can familiarize yourself with it here: [JMESPath](https://jmespath.org/).

Check also this tutorial in Microsoft docs on how to write JMESPath-based queries as part of your Azure CLI command: [How to query Azure CLI command output using a JMESPath query](https://docs.microsoft.com/en-us/cli/azure/query-azure-cli).

Thanks for reading and till next tech tip ;)