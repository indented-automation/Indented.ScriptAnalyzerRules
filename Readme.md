[![Build status](https://ci.appveyor.com/api/projects/status/x6tsc69bea8nun4h?svg=true)](https://ci.appveyor.com/project/indented-automation/indented-scriptanalyzerrules)

# Indented.ScriptAnalyzerRules

Script based custom rules for PSScriptAnalyzer.

## Installing the module

```powershell
Install-Module Indented.ScriptAnalyzerRules
```

## Using the module with PSScriptAnalyzer

Each of the rules is written to be used by PSScriptAnalyzer. Script analyzer must be set to use a custom rule path, the path can either be used on the command line or added to a PSScriptAnalyzerSettings.psd1 file.

```powershell
$params = @{
    Path           = 'C:\Path\To\File\file.ps1'
    CustomRulePath = '~\Documents\PowerShell\Modules\Indented.ScriptAnalyzerRules'
}
Invoke-ScriptAnalyzer @params
```

## Rules

|Rule Name|Description|
|---|---|
|AvoidCreatingObjectsFromAnEmptyString|Objects should not be created by piping an empty string to Select-Object.|
|AvoidDashCharacters|Avoid en-dash, em-dash, and horizontal bar outside of strings.|
|AvoidEmptyNamedBlocks|Functions and scripts should not contain empty begin, process, end, or dynamicparam declarations.|
|AvoidFilter|Avoid the Filter keyword when creating a function|
|AvoidHelpMessage|Avoid arguments for boolean values in the parameter attribute.|
|AvoidNestedFunctions|Functions should not contain nested functions.|
|AvoidNewObjectToCreatePSObject|Functions and scripts should use [PSCustomObject] to create PSObject instances with named properties.|
|AvoidParameterAttributeDefaultValues|Avoid including default values in the Parameter attribute.|
|AvoidProcessWithoutPipeline|Functions and scripts should not declare process unless an input pipeline is supported.|
|AvoidReturnAtEndOfNamedBlock|Avoid using return at the end of a named block, when it is the only return statement in a named block.|
|AvoidSmartQuotes|Avoid smart quotes.|
|AvoidThrowOutsideOfTry|Advanced functions and scripts should not use throw, except within a try / catch block. Throw is affected by ErrorAction.|
|AvoidWriteErrorStop|Functions and scripts should avoid using Write-Error Stop to terminate a running command or pipeline. The context of the thrown error is Write-Error.|
|AvoidWriteOutput|Write-Output does not add significant value to a command.|
|UseExpressionlessArgumentsInTheParameterAttribute|Use expressionless arguments for boolean values in the parameter attribute.|
|UseSyntacticallyCorrectExamples|Examples should use parameters described by the function correctly.|
