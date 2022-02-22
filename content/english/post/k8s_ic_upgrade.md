+++
author = "Kristina D."
title = "How to upgrade NGINX Ingress Controller with zero downtime in production"
date = "2022-01-14"
description = "This blog post explains how to perform maintenance and upgrade of NGINX Ingress Controller with zero downtime in production."
draft = false
tags = [
    "kubernetes",
    "aks",
    "k8s",
    "helm",
    "nginx",
    "ingress-controller"
]
+++

![Article banner for Ingress Controller upgrade](../../images/k8s_ic_upgrade/k8s_ic_upgrade_banner.png)

{{< table_of_contents >}}
## Introduction to the needs for upgrading Ingress Controller

In some scenarios you may need to perform maintenance work on the Ingress Controller which can potentially result in downtime - in my case the time has come to move away from NGINX Ingress Controller for Kubernetes Helm chart located in ```stable``` repo and fully embrace the new Helm chart located in ```ingress-nginx``` repository. The reason for that is related to higher maintenance costs for the Helm repositories\' maintainers which has become significantly more challenging with release of Helm 3. Therefore EOL timeline has been officially announced by CNCF and Helm back in 2020. You can read the official announcement as well as the reasoning behind deprecation of Helm repositories here: [Important Helm Repo Changes & v2 End of Support in November](https://www.cncf.io/blog/2020/10/07/important-reminder-for-all-helm-users-stable-incubator-repos-are-deprecated-and-all-images-are-changing-location/) .

There may, of course, be other reasons for why you would need to perform maintenance of the Ingress Controller and take it offline: for instance, you may want to spin up a totally different Ingress Controller or a different version of the Ingress Controller that is currently in use. And I love avoiding downtime when performing maintenance work and I guess that many of the readers of this blog post can relate to that ;)

Well, there is quite a neat and straightforward way to do that! To simplify the whole process for myself I\'ve created a PowerShell script that I\'ve re-used many times (since I had to perform the same work on multiple Kubernetes clusters, both in dev and production). And it saved me quite some time and manual work. You can find the complete version of the script in my GitHub repository: [guidemetothemoon - Upgrade NGINX Ingress Controller](https://github.com/guidemetothemoon/div-dev-resources/blob/main/scripts/kubernetes/ingress/Upgrade-Nginx-IC.ps1)

> **I have also created a fully automated version of the script where you don't need to run any blocks manually - this script expects that Azure DNS and AKS are being used - you can check the script in my GitHub repository:** [guidemetothemoon - Upgrade NGINX Ingress Controller - Automatic](https://github.com/guidemetothemoon/div-dev-resources/blob/main/scripts/kubernetes/ingress/Upgrade-Nginx-IC-Auto.ps1)

If you would like to learn more about debugging in Kubernetes, I\'ve also created a small cheatsheet that I\'ve been actively using and referencing when helping out Kubernetes beginners [guidemetothemoon - Kubernetes debugging quicknotes](https://github.com/guidemetothemoon/div-dev-resources/blob/main/help-material/kubernetes/k8s-debugging-quicknotes.md) :)


## Walkthrough of the process for upgrading NGINX Ingress Controller with zero downtime

I will now go through the script in more detail so that you can understand how zero downtime process actually works. In my scenario I will be using NGINX Ingress Controller, Azure Kubernetes Service and Azure DNS but this may be customized based on your infrastructure setup and your needs.
From now on I will also be using Ingress Controller and IC terms interchangeably but both actually mean the same thing :)

### Preparations

Firstly, we\'ll need to do some preparations that will make it easier for us to do the work later: 
- Set alias for kubectl command so that we don\'t need to refer the full command every single time
- Log into Azure and set active subscription to the one where your DNS Zones are created
- Set current Kubernetes context to the cluster where you will be performing the upgrade - mine is called TestKubeCluster

{{< highlight bash >}}
# 0 - Set alias for kubectl to not type the whole command every single time ;)
Set-Alias -Name k -Value kubectl

#Log in to Azure and set proper subscription active in order to be able to update DNS records (not applicable if you're using another DNS provider
az login
az account set --subscription mySubscription # Set active subscription to the one where your DNS zones are defined
k config use-context TestKubeCluster
{{< /highlight >}}

### Create temporary Ingress Controller

Next step is to create a temporary Ingress Controller and I recommend to use the same configuration and resource definition as the existing Ingress Controller in production uses. Why? Well, it has been running in production for a while and you know that it works, therefore it\'s a safe choice to avoid any potential issues with temporary Ingress Controller while you\'re performing maintenance and upgrading the initial IC. 

Temporary Ingress Controller will naturally reside in a temporary namespace which we will create beforehand. Once we\'ve created a temporary namespace we can add Helm repositories where we can download both the Helm Chart for the original IC, as well as the repo where the Chart for the new IC resides.

Once that\'s done, we move to step 2 and deploy temporary Ingress Controller using the same configuration as the active IC uses. Once temporary IC is created we\'ll need to make a note of the External IP that both the original and temporary Ingress Controller use - we will need that during re-routing of the traffic.

Finally, once the temporary Ingress Controller is deployed and is up and running, we move on to step 3 and set up monitoring for both the original and the temporary IC - this will become very relevant once we need to re-route the traffic from the original Ingress Controller to the temporary one. We don\'t want any application becoming unavailable, right? ;) Re-routing traffic will mean updating DNS records and that type of update will take some time. Therefore monitoring traffic for both Ingress Controllers will help us identify when all the traffic is fully drained from the original IC and is actively hitting temporary IC instead.

{{< highlight bash >}}
# 1 - Prepare namespace and Helm charts before creating temp Ingress Controller

k create ns ingress-temp

# Add old and new Helm charts to ensure that the repo is up-to-date:
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo add stable https://charts.helm.sh/stable
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

# 2 - Create temp Ingress Controller based on the same Helm chart as the existing Ingress Controller that will be upgraded
helm upgrade nginx-ingress-temp stable/nginx-ingress --install --namespace ingress-temp --set controller.config.proxy-buffer-size="32k" --set controller.config.large-client-header-buffers="4 32k" --set controller.replicaCount=2 --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux --set controller.metrics.service.annotations."prometheus\.io/port"="10254" --set controller.metrics.service.annotations."prometheus\.io/scrape"="true" --set controller.metrics.enabled=true --version=1.41.2 

$original_ingress_ip = "10.10.10.10" # replace with the External IP of existing Ingress Controller

# Get external IP of the newly created Ingress Controller (service of type LoadBalancer in ingress-temp namespace)
$temp_ingress_ip = k get svc -n ingress-temp --output jsonpath='{.items[?(@.spec.type contains 'LoadBalancer')].status.loadBalancer.ingress[0].ip}' # get External IP of LoadBalancer service

# 3 - Monitor traffic in both Ingress Controllers to identify when the traffic is only routed to the temporary IC so that the original IC can be taken offline
kubectl logs -l component=controller -n ingress-basic -f # Monitor traffic in original IC
kubectl logs -l component=controller -n ingress-temp -f # Monitor traffic in temporary IC
{{< /highlight >}}

### Re-route traffic to temporary Ingress Controller

All right, now that we have the temporary Ingress Controller in place, we're ready to re-route all the traffic from original IC to the temporary one.
Here I would recommend doing some additional tests before updating DNS records in order to ensure that the temporary Ingress Controller is working as expected. For AKS following tutorial and test application from Microsoft came in really handy: [Create an ingress controller in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/ingress-basic). What I did is that I deployed the demo application as described in the tutorial and created a DNS record for this app which points to the External IP of the temporary Ingress Controller which we made a note of earlier. Now we can navigate to the DNS name we\'ve created (or to External IP of temporary IC) and we should be able to see the same application UI as shown in the tutorial.

Very nice! Now we\'ve confirmed that the temporary IC works as expected - we\'re ready for the next step.
First, we need to get all the DNS records from the DNS zone used by applications running in current Kubernetes cluster that point to the External IP of the original Ingress Controller - that\'s the ones we will need to update to point to the temporary IC instead. For this we can use quite powerful ```--query``` parameter to not retrieve all the DNS records but only those we actually need to update - you can read more about ```--query``` syntax here: [How to query Azure CLI command output using a JMESPath query](https://docs.microsoft.com/en-us/cli/azure/query-azure-cli).

> **Tip:** Some Azure resources support ```--query-examples``` parameter which will return you examples on how you can filter the results that a specific command returns - check out Microsoft documentation related to Azure CLI commands related to the Azure resource you\'re working with and see if those provide query examples!

Once all the relevant DNS records have been retrieved we can start removing External IP of original Ingress Controller and add External IP of temporary IC - for that parallel execution in PowerShell came in very handy for me. Parallel execution (available from PowerShell 7.0, ref. [PowerShell ForEach-Object Parallel Feature](https://devblogs.microsoft.com/powershell/powershell-foreach-object-parallel-feature/)) will spin up several threads that will update DNS records in parallel - when you have tens or hundreds of DNS records, this could save quite some time. Important note here which is also mentioned in the script itself - I wouldn't recommend using more than 10-15 threads at a time since it may result in resource exhaustion of your system. Of course, if you have a really fancy quantum computer or something similar, you can try using a higher amount of threads as well ;)

**Please note:** for even further automation, the code that is used to retrieve, filter and update DNS records can be moved out to a separate function to avoid duplication. Since this blog post is aimed for educating purposes, I've consciously duplicated the same steps at a later step as well instead of creating a separate function. See a fully automated version of the script for this: [guidemetothemoon - Upgrade NGINX Ingress Controller - Automatic](https://github.com/guidemetothemoon/div-dev-resources/blob/main/scripts/kubernetes/ingress/Upgrade-Nginx-IC-Auto.ps1)

Once all DNS records are updated, let\'s ensure that we haven\'t missed out on any relevant DNS records. We repeat the same steps we did a few moments ago:
- Retrieve all the DNS records from the DNS zone used by applications running in current Kubernetes cluster
- Filter out only those DNS records pointing to the External IP of the original Ingress Controller
- If no records are returned, we did well and successfully re-routed traffic from the original Ingress Controller to the temporary IC! Of course, if you\'re using multiple DNS zones, you need to ensure that relevant DNS records in those DNS zones are updated as well.

Lastly, we wait. Update of DNS records takes time, sometimes up to an hour or two, depending on the amount of DNS records that were updated. We can periodically check if all DNS records were updated with help of ```Resolve-DnsName``` function.

{{< highlight bash >}}
# 4 - Update DNS records to route traffic to temp Ingress Controller
# Check in the DNS zone how many records are there that are connected to the original IC's IP
$cluster_dns_recs = az network dns record-set a list -g myresourcegroup -z mydnszone.com --query "[].{Name:name, FQDN:fqdn, IP:aRecords[].ipv4Address}[?contains(IP[],'$original_ingress_ip')]" | ConvertFrom-Json
$cluster_dns_recs.count

$cluster_dns_recs | ForEach-Object -Parallel {
	Write-Output "Updating $($_.Name) IP $($_.IP) with updated Ingress Controller External IP $using:temp_ingress_ip"
	az network dns record-set a add-record --resource-group myresourcegroup --zone-name mydnszone.com --record-set-name $_.Name --ipv4-address  $using:temp_ingress_ip
        az network dns record-set a remove-record --resource-group myresourcegroup --zone-name mydnszone.com --record-set-name $_.Name --ipv4-address $using:original_ingress_ip
} -ThrottleLimit 3 # here you can customize parallel threads count based on how many records you have but I wouldn't recommend to use more that 15 depending on how resourceful your system is

# Once you've updated DNS records you will need to load them again
# Verify that there are no more DNS records that are connected to the original IC's IP
$cluster_dns_recs = az network dns record-set a list -g myresourcegroup -z mydnszone.com --query "[].{Name:name, FQDN:fqdn, IP:aRecords[].ipv4Address}[?contains(IP[],'$original_ingress_ip')]" | ConvertFrom-Json
$cluster_dns_recs.count # Should be 0 by now

# Now wait for all traffic to be drained from original IC and moved to the temp IC
# You can check DNS resolution in the meantime to confirm that all DNS records are updated

# For few exisitng DNS records - check what those are resolved to
foreach($dnsrec in $cluster_dns_recs) {
	$res = Resolve-DnsName -Name $dnsrec.FQDN
	Write-Output $res
}
# For large amount of DNS records - Faster check if all the DNS records have been properly updated
$dns_recs = az network dns record-set a list -g myresourcegroup -z mydnszone.com --query "[].{Name:name, FQDN:fqdn, IP:aRecords[].ipv4Address}[?contains(IP[],'$temp_ingress_ip')]" | ConvertFrom-Json
$dns_resolv_Res = $dns_recs | Where-Object {(Resolve-DnsName -Name $_.FQDN).IPAddress -ne $temp_ingress_ip}

{{< /highlight >}}

### Upgrade original Ingress Controller and re-route traffic from temporary IC

Okay, we\'ve waited and monitored enough! We\'ve now confirmed that all DNS records were updated and all traffic was drained from original Ingress Controller and is now hitting temporary IC. This means that we\'re ready to upgrade or perform maintenance on the original Ingress Controller. And by upgrade, which we\'re performing in this scenario, I mean uninstalling the running deployment of original IC and installing a new and shiny NGINX Ingress Controller from the new and shiny ```ingress-nginx``` repository.

With help of ```helm uninstall``` and ```helm upgrade``` we\'ve now deployed a new version of NGINX Ingress Controller that we want to use in production. Since we\'ve uninstalled the original IC we\'ve also lost the live traffic monitoring that we\'ve set up for it earlier so we need to set up the traffic monitoring for the newly created Ingress Controller as well - we\'ll be re-routing traffic once again.

After logging is enabled, we will need to drain traffic from the temporary Ingress Controller and re-route it to the newly created IC. In order to do that we can follow the same steps we did in the previous section:
- (Optional) Create test application pointing to the new Ingress Controller to test that it functions as expected and is ready to accept traffic
- Make a note of External IP of the newly created Ingress Controller
- Update all the relevant DNS records in the respective DNS zones - now, we\'ll need to remove External IP of the temporary Ingress Controller and add External IP of the newly created IC
- Monitor and wait for the DNS records to be updated and traffic to be drained from temporary IC and re-routed to the newly created IC

{{< highlight bash >}}
# 5 - Once DNS records were updated and all traffic has been re-routed to temp IC, uninstall original Ingress Controller with Helm and install new Ingress Controller with Helm
# In this case new Ingress Controller is configured to use Public IP of Azure Load Balancer and not create a new IP
helm uninstall nginx-ingress -n ingress-basic
helm upgrade nginx-ingress ingress-nginx/ingress-nginx --install --create-namespace --namespace ingress-basic --set controller.config.proxy-buffer-size="32k" --set controller.config.large-client-header-buffers="4 32k" --set controller.replicaCount=2 --set controller.nodeSelector."kubernetes\.io/os"=linux --set defaultBackend.nodeSelector."kubernetes\.io/os"=linux --set-string controller.metrics.service.annotations."prometheus\.io/port"="10254" --set-string controller.metrics.service.annotations."prometheus\.io/scrape"="true" --set controller.metrics.enabled=true --set controller.service.loadBalancerIP="00.00.00.000" #remove loadBalancerIP if Ingress Controller will not use Azure Load Balancer's Public IP

# 6 - Monitor the newly created Ingress Controller since the initial one was removed in previous step - be aware that the Kubernetes label for in new NGINX Ingress Controller template has changed!
kubectl logs -l app.kubernetes.io/component=controller -n ingress-basic -f # New IC
kubectl logs -l component=controller -n ingress-temp -f # Temporary IC, should still be actively monitoring as per actions in step 3

# 7 - Redirect traffic back to newly created Ingress Controller and monitor traffic routing together with DNS resolution
# Repeat step 4, just like below:

$new_ingress_ip = "00.00.00.000" # Public IP of newly created Ingress Controller

#Update DNS records to route traffic to temp Ingress Controller
# Check in the DNS zone how many records are there that are connected to the temp IC's IP
$cluster_dns_recs = az network dns record-set a list -g myresourcegroup -z mydnszone.com --query "[].{Name:name, FQDN:fqdn, IP:aRecords[].ipv4Address}[?contains(IP[],'$temp_ingress_ip')]" | ConvertFrom-Json
$cluster_dns_recs.count

$cluster_dns_recs | ForEach-Object -Parallel {
	Write-Output "Updating $($_.Name) IP $($_.IP) with updated Ingress Controller External IP $using:new_ingress_ip"
	az network dns record-set a add-record --resource-group myresourcegroup --zone-name mydnszone.com --record-set-name $_.Name --ipv4-address  $using:new_ingress_ip
        az network dns record-set a remove-record --resource-group myresourcegroup --zone-name mydnszone.com --record-set-name $_.Name --ipv4-address $using:temp_ingress_ip
} -ThrottleLimit 3 # here you can customize parallel threads count based on how many records you have but I wouldn't recommend to use more that 15 depending on how resourceful your system is

# Once you've updated DNS records you will need to load them again
# Verify that there are no more DNS records that are connected to the temp IC's IP
$cluster_dns_recs = az network dns record-set a list -g myresourcegroup -z mydnszone.com --query "[].{Name:name, FQDN:fqdn, IP:aRecords[].ipv4Address}[?contains(IP[],'$temp_ingress_ip')]" | ConvertFrom-Json
$cluster_dns_recs.count # Should be 0 by now

# Now wait for all traffic to be drained from temp IC and moved to the new IC
# You can check DNS resolution in the meantime to confirm that all DNS records are updated

# For few exisitng DNS records - check what those are resolved to
foreach($dnsrec in $cluster_dns_recs) {
	$res = Resolve-DnsName -Name $dnsrec.FQDN
	Write-Output $res
}

# For large amount of DNS records - Faster check if all the DNS records have been properly updated
$dns_recs = az network dns record-set a list -g myresourcegroup -z mydnszone.com --query "[].{Name:name, FQDN:fqdn, IP:aRecords[].ipv4Address}[?contains(IP[],'$new_ingress_ip')]" | ConvertFrom-Json
$dns_resolv_Res = $dns_recs | Where-Object {(Resolve-DnsName -Name $_.FQDN).IPAddress -ne $new_ingress_ip}
{{< /highlight >}}

### Final test and cleanup

Aaaaaallright! We\'re almost there and it was worth the wait! Hopefully now you have all applications on the current Kubernetes cluster running nicely and being unaware of this amazing maintenance work we\'ve just performed in production :) But **remember: though it\'s very tempting to do this directly on a production cluster, one does not simply test in production!** I do encourage you to test this approach out in development first to get your hands dirty and ensure that no deviations in configuration or infrastructure set up cause errors during this type of maintenance.

Last but not least: we must clean up after ourselves and remove all the temporary resource we\'ve created along the way:
- Remove test application that was used for testing newly created Ingress Controllers and respective DNS records that were created to reach this test application
- Remove temporary Ingress Controller with ```helm uninstall```
- Remove temporary namespace where temp IC was residing

{{< highlight bash >}}
# 8 - Remove temp resources once traffic is drained from temporary IC and newly created IC is fully in use and successfully running in respective Kubernetes cluster
helm uninstall nginx-ingress-temp -n ingress-temp
k delete ns ingress-temp

# Final step, after all clusters are upgraded - remove DNS record for any test applications you might have created like the one from this Microsoft tutorial: https://docs.microsoft.com/en-us/azure/aks/ingress-basic

{{< /highlight >}}

**Lastly, take yourself a cup of tasty coffee or tea, sit down in a comfortable chair and enjoy all the traffic hitting the new and shiny Ingress Controller you\'ve created - you deserved it! ;)**

## Additional resources

A few resources that were really useful for me while doing this work which I hope may help you on your way as well:
- Microsoft tutorial on creation and testing of NGINX Ingress Controller in AKS (which I also used for testing new instances of ICs): [Create an ingress controller in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/ingress-basic)
- Recommendations for upgrading ingress-nginx installation: [Upgrading](https://kubernetes.github.io/ingress-nginx/deploy/upgrade/)
- New GitHub repository for NGINX Ingress Controller and it\'s Helm Chart: [ingress-nginx](https://github.com/kubernetes/ingress-nginx/blob/main/charts/ingress-nginx/README.md)
- Finally, I\'m continuously filling up my GitHub account with useful material, scripts and (soon) applications that cover different areas of product development and architecture - you\'re very much welcome to join me there! [guidemetothemoon/div-dev-resources](https://github.com/guidemetothemoon/div-dev-resources)  ^_^

That\'s it from me this time, thanks for checking in! 
If this article was helpful, I\'d love to hear about it! You can reach out to me on LinkedIn, GitHub or by using the contact form on this page :)

Stay secure, stay safe.

Till we connect again