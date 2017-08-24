---
external help file: Indented.CodingConventions-help.xml
online version: 
schema: 2.0.0
---

# PSAvoidWriteErrorStop

## SYNOPSIS
PSAvoidWriteErrorStop

## SYNTAX

```
PSAvoidWriteErrorStop [[-ast] <CommandAst>]
```

## DESCRIPTION
Functions and scripts should avoid using Write-Error Stop to terminate a running command or pipeline.
The context of the thrown error is Write-Error.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Invoke-CodingConventionRule -ScriptBlock { Write-Error 'message' -ErrorAction Stop } -RuleName AvoidWriteErrorStop
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

