---
external help file: Indented.CodingConventions-help.xml
online version: 
schema: 2.0.0
---

# PSAvoidProcessWithoutPipeline

## SYNOPSIS
PSAvoidProcessWithoutPipeline

## SYNTAX

```
PSAvoidProcessWithoutPipeline [[-ast] <ScriptBlockAst>]
```

## DESCRIPTION
Functions and scripts should not declare process unless an input pipeline is supported.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Invoke-CodingConventionRule -ScriptBlock { function name { process { } } } -RuleName AvoidProcessWithoutPipeline
```

Execute the rule against a script block using Invoke-CodingConventionRule.

## PARAMETERS

### -ast
An AST node.

```yaml
Type: ScriptBlockAst
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

