# Coding conventions

This module hosts rules designed to test that code conforms to organisation specific conventions and practices. The goal of such testing is to aim for a common look and feel across a code base.

## Installing the module

WIP

## Using the module with PSScriptAnalyzer

Each of the rules is written to be used by PSScriptAnalyzer. Script analyzer must be set to use a custom rule path, this can be either the path to the module manifest, or the root module.
```powershell
Invoke-ScriptAnalyzer -Path C:\Path\To\File\file.ps1 -CustomRulePath (Get-CodingConventionModulePath)
```
## Using the module with Pester

Individual rules can be invoked independently, for example within Pester. Two options are available:

### Invoke-CodingConventionRule

Invoke-CodingConventionRule is a helper which simulates the behaviour of Invoke-ScriptAnalyzer.

```powershell
It 'Does not use nested functions' {
    Invoke-CodingConventionRule -Command TestSubjectName -RuleName AvoidNestedFunctions | Should -BeNullOrEmpty
}
```
