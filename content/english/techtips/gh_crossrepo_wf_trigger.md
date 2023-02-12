+++
author = "Kristina D."
title = "How to trigger subsequent GitHub workflow in a different repository"
date = "2023-02-12"
description = "In this tech tip we take a look at how you can trigger a GitHub workflow residing in a different repository, based on a specific condition."
draft = false
tags = [
    "techtips",
    "github",
    "devops"
]
+++

![Article banner for triggering subsequent GitHub workflow in different repo](../../images/tech_tips/techtip_19.png)

I was recently working on automating some manual actions related to my tech blog and discovered an interesting use case that I thought was worth sharing with the community 😊

**Did you know that it is possible to trigger a GitHub workflow that resides in a different repository?** Let me show you how!😼
There are multiple approaches to how you can implement this but I have found following approach to be most preferrable. Let's say that you have repository A and repository B, and you want to trigger a GitHub workflow in repository B once workflow in repository A succeeds.

1. **Create a GitHub Personal Access Token (PAT) that will be added both to repository A and B.** I recommend to follow the least privilege principle and create a fine-grained personal access token that is scoped only to the repositories A and B. When it comes to configuring PAT permissions you will need to see what's applicable to your use case. For instance, if you're using GitHub Pages or not. Relevant sections to configure permissions for are ```Actions```, ```Deployments``` and ```Pages```. In my example I have configured ```Read``` access on ```Deployments``` to be able to check deployment status and ```Read/Write``` access on ```Actions``` to be able to check and trigger workflows. You can read here about how to create a fine-grained GitHub PAT: [Creating a fine-grained personal access token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token#creating-a-fine-grained-personal-access-token)

2. **Add created GitHub PAT as a repository secret for repository A and B, with the name of your choosing.** You can read here how to add a repository secret: [Creating encrypted secrets for a repository](https://docs.github.com/en/actions/security-guides/encrypted-secrets#creating-encrypted-secrets-for-a-repository)

3. **Add GitHub Action to the repository that will be triggering GitHub workflow in another repository.** In my case I want repository A to trigger workflow in repository B once workflow in repository A succeeds, therefore I need to create a GitHub Action in repository A in order to achieve that. One option is to create a new GitHub workflow with an action that will act as a trigger - this would be a solution when repository A is being built and deployed through GitHub Pages for example, and doesn't have an existing GitHub workflow that can be used. Another option is to add a trigger action as part of the existing workflow - you can add it as an additional job/step with the condition that you want the trigger to be executed for.

In my case repository A only has a GitHub Pages workflow which I don't maintain, therefore I will create a new GitHub workflow by creating ```trigger-repob-workflow.yml``` in ```.github/workflows``` folder in the root of repo A. Also, I want to trigger repo B workflow **only** when all the jobs of repo A's workflow have succeeded and the whole workflow has completed. In this case I will use a ```workflow_run``` event of type ```completed``` which will trigger ```repob-workflow``` once current (repo A) workflow run is marked as ```completed```. I also want to ensure that triggering not only happens when the workflow completes but also only when it succeeds, therefore I will add an ```if```-condition that will check that ```github.event.workflow_run.conclusion``` property is equal to ```success```, otherwise the workflow will run regardless of the conclusion state, which can also be failure.

You can read more about different event types that can be used to trigger workflows here: [Events that trigger workflows](https://docs.github.com/en/actions/using-workflows/events-that-trigger-workflows)


```yml
   # trigger-repob-workflow.yml
    name: Trigger Repo B GitHub workflow
    on:
    workflow_run:
        workflows: [repob-workflow] # Name of GitHub workflow to trigger in target repository
        types:
        - completed
    jobs:
    trigger-repob-workflow:
        if: github.event.workflow_run.conclusion == 'success' # Run only when workflow run has succeeded, i.e. all jobs have succeeded
        runs-on: ubuntu-latest
        steps:
        - uses: actions/github-script@v6
        with:
            github-token: ${{ secrets.PAT }} # Fine-grained GitHub PAT that was saved as repository secret
            script: |
            await github.rest.actions.createworkflowDispatch({
                owner: 'guidemetothemoon',
                repo: 'repoB',
                workflow_id: 'repob-workflow.yml',
                ref: 'main'
            })
```

As you can see from the example above, we're using ```createworkflowDispatch``` event in order to perform the actual triggering. You will need to provide following parameters for the event to run properly:

- ```owner```: repository owner;
- ```repo```: name of the repository where to trigger the workflow;
- ```workflow_id```: full name of the GitHub workflow YAML file that must be triggered;
- ```ref```: branch name to trigger the workflow from;

You can read more about this functionality here: [GitHub Actions: Use the GITHUB_TOKEN with workflow_dispatch and repository_dispatch](https://github.blog/changelog/2022-09-08-github-actions-use-github_token-with-workflow_dispatch-and-repository_dispatch/)

A few more examples for conditions/execution triggers you could use:

* If you want triggering to happen instantly, for example when pushing new changes to the repository, independent of any other workflows that may be running in parallel in the repository, you can remove an ```if```-condition from the example above and update ```on```-clause to be ```on: [push]```.

* If you want triggering to happen once a deployment in the workflow succeeds, you can update ```on```-clause to be ```on: deployment_status``` and update ```if```-condition to be ```if: github.event.deployment_status.state == 'success'```. Please note that in this case, if you have deployments running in parallel, triggering will happen for every succeded deployment,- and for every new trigger, previous run will be cancelled if it's still in progress.

That\'s it for now - Thanks for reading and till next tech tip 😼