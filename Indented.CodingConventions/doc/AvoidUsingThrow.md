---
external help file: CodingConventions-help.xml
online version: 
schema: 2.0.0
---

# AvoidUsingThrow

## SYNOPSIS
AvoidUsingThrow

## SYNTAX

```
AvoidUsingThrow [[-ast] <FunctionDefinitionAst>]
```

## DESCRIPTION
Advanced functions and scripts should not use throw, except within a try / catch block.
Throw is affected by ErrorAction.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Invoke-CodingConventionRule -ScriptBlock { function name { [CmdletBinding()]param ( ); throw 'message' } } -RuleName AvoidUsingThrow
```

Execute the rule against a script block using Invoke-CodingConventionRule.

## PARAMETERS

### -ast
An AST node.

```yaml
Type: FunctionDefinitionAst
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

