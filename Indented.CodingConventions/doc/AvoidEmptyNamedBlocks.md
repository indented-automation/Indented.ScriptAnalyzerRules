---
external help file: CodingConventions-help.xml
online version: 
schema: 2.0.0
---

# AvoidEmptyNamedBlocks

## SYNOPSIS
AvoidEmptyNamedBlocks

## SYNTAX

```
AvoidEmptyNamedBlocks [[-ast] <ScriptBlockAst>]
```

## DESCRIPTION
Functions and scripts should not contain empty begin, process, end, or dynamicparam declarations.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Invoke-CodingConventionRule -ScriptBlock { process { } } -RuleName AvoidEmptyNamedBlocks
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

### Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]

## NOTES

## RELATED LINKS

