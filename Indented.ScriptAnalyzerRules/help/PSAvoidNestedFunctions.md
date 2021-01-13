---
external help file: Indented.CodingConventions-help.xml
online version: 
schema: 2.0.0
---

# PSAvoidNestedFunctions

## SYNOPSIS
PSAvoidNestedFunctions

## SYNTAX

```
PSAvoidNestedFunctions [[-ast] <FunctionDefinitionAst>]
```

## DESCRIPTION
Functions should not contain nested functions.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Invoke-CodingConventionRule -ScriptBlock { function outer { function inner { } } } -RuleName AvoidNestedFunctions
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

### Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord

## NOTES

## RELATED LINKS

