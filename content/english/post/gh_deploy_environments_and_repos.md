---
author: "Kristina Devochko"
title: "Tech Bits and Bobs #1 - Reference GitHub Repository and Deployment Environment Secrets and Variables in Reusable Workflows"
date: "2025-07-07"
description: "In this tech tip we take a look at how we can reference GitHub Deployment Environment and regular Repository Secrets and variables in a reusable workflow."
draft: false
tags: [
    "techtips",
    "github",
    "devops",
    "ci-cd"
]
slug: "github-secrets-and-vars-in-reusable-workflow"
---

In this edition of Tech Bits and Bobs I would like to give a quick overview of how to reference variables and secrets, that are defined in the repository variables and secrets and in a [GitHub Deployment Environment](https://docs.github.com/en/actions/how-tos/managing-workflow-runs-and-deployments/managing-deployments/managing-environments-for-deployment), in a reusable GitHub workflow. Disclaimer: there's a tiny nuance to be aware of when it comes to referencing secrets 😼

The good thing is that you can reference all the variables and secrets that are coming both from the [repository secrets and variables](https://docs.github.com/en/actions/how-tos/security-for-github-actions/security-guides/using-secrets-in-github-actions) and the deployment environments in a regular way, i.e. `${{ secrets.MY_SECRET_FROM_ANYWHERE }}` or `${{ vars.MY_VAR_FROM_ANYWHERE }}`. The only caveat here is that when you want to reference secrets in a reusable workflow, be it from the repo or a deployment environment, you need to provide `secrets: inherit` parameter in the parent workflow job that is calling upon a reusable workflow. This parameter allows reusable workflow to access the secrets that the parent workflow has access to.

The funny thing is that it seems like `secrets: inherit` didn't quite work initially when you needed to reference secrets from deployment environment in a reusable workflow and you had to explicitly declare all secret definitions in a reusable workflow and pass them as input from a parent workflow, but fortunately we don't need to do it anymore, phew!

Ok, back to the point. Let's say I have a GitHub deployment environment called `dev` where I have a secret called `MY_SECRETY_SECRET` with value `meowfoobar` and a non-sensitive variable `MY_VAR_TEST` with value `Meow!`. In the repository secrets and variable I have also declared a secret called `ME_REPO_SECRET` with value `bla` and a non-sensitive variable `MY_REPO_VAR_TEST` with value `Meow from Repo!`.

![Overview of defined Github repo and deployment environment variables and secrets](../../images/github/github_secrets_and_variables.webp)

In addition I have a `parent-workflow.yaml` with a deployment stage that calls `reusable-workflow.yaml` that will reference secrets and variables, both from the `dev` deployment environment and the repository itself.

To make this work I need to explicitly define secret inheritance as input to the reusable workflow from the parent workflow. I will also parameterize deployment environment name for reusability across deployment jobs:

``` yaml
# parent-workflow.yaml
name: Main workflow
on:
  workflow_dispatch:

jobs:
  regular-job:
    name: Regular build job
    runs-on: ubuntu-latest
    steps:
      - name: Run a build step
        run: echo "This is a regular job step...nothing to see here."

  deploy-dev:
    name: Deployment stage - Dev
    uses: ./.github/workflows/reusable-workflow.yaml
    with:
      deployment-environment: dev
    secrets: inherit # <- Pass secrets to reusable workflow
```

Once inheritance is defined reusable workflow can reference all variables and secrets just as you would do in a parent workflow - validation script that job steps are pointing to in this example to ensure that all values are set and have expected values is available here: [validate-input.sh](https://github.com/guidemetothemoon/cloudy-labs/blob/main/util-scripts/validate-input.sh).

``` yaml
# reusable-workflow.yaml
---
name: Reusable workflow - Validate deployment environment secret
on:
  workflow_call:
    inputs:
      deployment-environment:
        description: GitHub deployment environment
        required: true
        type: string
jobs:
  validate-secret:
    name: Validate deployment environment secret
    runs-on: ubuntu-latest
    environment: ${{ inputs.deployment-environment }}
    steps:
      - uses: actions/checkout@v4.2.2

      - name: Check if repo secret is set and has expected value
        run: bash ${GITHUB_WORKSPACE}/util-scripts/validate-input.sh "${{ secrets.MY_REPO_SECRET }}" "bla"
      
      - name: Validate repository and deployment environment variables
        shell: bash
        run: |
          echo "Deployment environment variable: ${{ vars.MY_VAR_TEST }}"
          echo "Repository variable: ${{ vars.MY_REPO_VAR_TEST }}"

      - name: Check if deployment environment secret is set and has expected value
        shell: bash
        run: bash ${GITHUB_WORKSPACE}/util-scripts/validate-input.sh "${{ secrets.MY_SECRETY_SECRET }}" "meowfoobar"
```

You can find a full example with step-by-step instructions on how to test it yourself in my GitHub repo: [guidemetothemoon/cloudy-labs](https://github.com/guidemetothemoon/cloudy-labs/tree/main/github-workflows/secrets-and-vars-in-reusable-workflow).

That's it from me this time, thanks for checking in!

Stay secure, stay safe.
Till we connect again!😼
