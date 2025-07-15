---
author: "Kristina Devochko"
title: "Reusable ValidateSets in PowerShell"
date: "2025-07-15"
draft: false
tags: [
    "techtips",
    "powershell",
    "devops",
    "ci-cd"
]
slug: "powershell-reusable-validatesets"
---

When you're creating scripts, in some cases, you may want to limit what values a consumer is allowed to provide for a specific parameter. In PowerShell a regular way to do that is with [ValidateSet](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/validateset-attribute-declaration?view=powershell-7.5). ValidateSet is an attribute that you can define on a parameter together with a set of values that are allowed to be provided for the parameter. For example, let's say you want to only allow to specify `Development`, `Staging` or `Production` as a value for the `$DeploymentEnvironment` parameter in your PowerShell script, with help of `ValidateSet`. It can look something like this:

``` powershell
# Test-ValidateSet.ps1

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("Development", "Staging", "Production")]
    $DeploymentEnvironment
)

Write-Host $DeploymentEnvironment

```

If I attempt to call `Test-ValidateSet.ps1` like `Test-ValidateSet.ps1 -DeploymentEnvironment "Random"` I will get an error message stating that the value "Random" doesn't belong to the set specified by the ValidateSet.

So far so good. But let's say I have many functions or scripts where I would like to limit parameter options to the same set of values - shall I then hard-code this ValidateSet for every parameter?

I could, but it's not optimal. It increases duplication and reduces maintainability - if I need to update values of the ValidateSet I would need to do it in every single place where it's defined and that means ***"Hello potential human errors"*** 🎃

A better alternative would be to create a common file that would contain all the ValidateSets that I plan to use across scripts and functions so that I have a single place to extend and maintain those. This is more compliant with DRY (Don't Repeat Yourself) principle and is in general a cleaner approach. IMHO😇

So, how can you do that? An option that has worked really well in my experience is to define a PowerShell module that defines all the ValidateSets as [PowerShell classes](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_classes?view=powershell-7.5) that inherit from the [IValidateSetValuesGenerator](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.ivalidatesetvaluesgenerator?view=powershellsdk-7.4.0) interface.

- Create a PowerShell module (`.psm1`) file (and `.psd1` file, though it's optional). This module must use `System.Management.Automation` namespace. ValidateSet classes must inherit from `IValidateSetValuesGenerator` interface and implement a `GetValidValues()` method that will define the respective values for the respective ValidateSet PowerShell class.
- In every PowerShell script where you would like to utilize reusable ValidateSets you **must** load the module on line 1 by dot-sourcing to the respective `.psm1` file so that PowerShell has information about ValidateSets available during runtime, which is needed for the ValidateSets for the parameters to work correctly: `using module .\<module-path>`, for example `using module ./modules/common/CommonValidateSetsClass.psm1`
- `.psm1` module should also be loaded into the PowerShell session with `Import-Module` - either in the start of the script or beforehand, before calling the respective script. For example, `Import-Module ./modules/common/Common.psd1 -Force`

If we use above example again, our code can look something like this:

``` powershell
# CommonValidateSetsClass.psm1
using namespace System.Management.Automation

class ValidDeploymentEnvironments : IValidateSetValuesGenerator
{
    [string[]] GetValidValues()
    {
        $values = @(
            'Development',
            'Staging',
            'Production'
        )

        return $values
    }
}

# MORE CLASSES CAN BE ADDED HERE

```

``` powershell
# Test-ValidateSet.ps1
using module ./modules/common/CommonValidateSetsClass.psm1

param(
    [Parameter(Mandatory = $true)]
    [ValidateSet([ValidDeploymentEnvironments], ErrorMessage = "Provided value '{0}' is not part of the supported values in the set: '{1}'", IgnoreCase = $false)]
    $DeploymentEnvironment
)

Import-Module ./modules/common/Common.psd1 -Force
Write-Host $DeploymentEnvironment
```

The script will behave in the same way as before and will still fail if I provide an invalid value for the `DeploymentEnvironment` parameter, but in this case we minimized hard-coding and can re-use ValidateSet in other scripts, as well as extend the collection of reusable ValidateSets in a single place.
The same approach works both with consumer PowerShell scripts (`.ps1`) and modules (`.psm1`).

Fully testable example can be found in my GitHub repository: [guidemetothemoon/tech-utils](https://github.com/guidemetothemoon/tech-utils/tree/main/scripts/powershell/reusable-validateset).

If you're using Pester tests for unit testing you can even create a unit test that validates that this functionality behaves as expected when an invalid value is provided for a paramete.
Or you can also validate naming convention for the ValidateSets that are defined in the common module so that those follow the same established standard.

That's it from me this time, thanks for checking in!

Stay secure, stay safe.
Till we connect again!😼