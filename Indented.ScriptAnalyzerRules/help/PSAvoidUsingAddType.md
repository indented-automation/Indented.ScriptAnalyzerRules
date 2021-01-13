---
external help file: Indented.CodingConventions-help.xml
online version: 
schema: 2.0.0
---

# PSAvoidUsingAddType

## SYNOPSIS
PSAvoidUsingAddType

## SYNTAX

```
PSAvoidUsingAddType [[-ast] <CommandAst>]
```

## DESCRIPTION
Functions and scripts should not call Add-Type to load assemblies.
Assemblies should be required in the module manifest.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Invoke-CodingConventionRule -ScriptBlock { Add-Type -AssemblyName System.Web } -RuleName AvoidUsingAddType
```

Execute the rule against a script block using Invoke-CodingConventionRule.

## PARAMETERS

### -ast
An AST node.

```yaml
Type: CommandAst
Parameter Sets: (All)
Aliases: 

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord

## NOTES

## RELATED LINKS

