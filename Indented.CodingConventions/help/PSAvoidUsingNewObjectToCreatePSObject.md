---
external help file: Indented.CodingConventions-help.xml
online version: 
schema: 2.0.0
---

# PSAvoidUsingNewObjectToCreatePSObject

## SYNOPSIS
PSAvoidUsingNewObjectToCreatePSObject

## SYNTAX

```
PSAvoidUsingNewObjectToCreatePSObject [[-ast] <CommandAst>]
```

## DESCRIPTION
Functions and scripts should use \[PSCustomObject\] to create PSObject instances with named properties.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Invoke-CodingConventionRule -ScriptBlock { New-Object PSObject -Property @{} } -RuleName AvoidUsingNewObjectToCreatePSObject
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

