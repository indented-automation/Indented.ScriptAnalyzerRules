---
external help file: Indented.CodingConventions-help.xml
online version: 
schema: 2.0.0
---

# PSDoNotCreateObjectsFromAnEmptyString

## SYNOPSIS
PSDoNotCreateObjectsFromAnEmptyString

## SYNTAX

```
PSDoNotCreateObjectsFromAnEmptyString [[-ast] <PipelineAst>]
```

## DESCRIPTION
Objects should not be created by piping an empty string to Select-Object.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Invoke-CodingConventionRule -ScriptBlock { '' | Select-Object Property1, Property2 } -RuleName PSDoNotCreateObjectsFromAnEmptyString
```

Execute the rule against a script block using Invoke-CodingConventionRule.

## PARAMETERS

### -ast
{{Fill ast Description}}

```yaml
Type: PipelineAst
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

