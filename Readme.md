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
