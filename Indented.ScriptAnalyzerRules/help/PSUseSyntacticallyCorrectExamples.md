---
external help file: Indented.CodingConventions-help.xml
online version: 
schema: 2.0.0
---

# PSUseSyntacticallyCorrectExamples

## SYNOPSIS
PSUseSyntacticallyCorrectExamples

## SYNTAX

```
PSUseSyntacticallyCorrectExamples [[-ast] <FunctionDefinitionAst>]
```

## DESCRIPTION
Examples should use parameters described by the function correctly.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Invoke-CodingConventionRule -ScriptBlock {
```

function name {
        # .SYNOPSIS
        #   name
        # .DESCRIPTION
        #   description
        # .EXAMPLE
        #   name -param3 value

        \[CmdletBinding()\]
        param (
            \[String\]$param1,

            \[String\]$param2
        )
    }
} -RuleName UseSyntacticallyCorrectExamples

Execute the rule against a script block using Invoke-CodingConventionRule.

### -------------------------- EXAMPLE 2 --------------------------
```
Invoke-CodingConventionRule -ScriptBlock {
```

function name {
        # .SYNOPSIS
        #   name
        # .DESCRIPTION
        #   description
        # .EXAMPLE
        #   name -param1 value -param2 value

        \[CmdletBinding()\]
        param (
            \[Parameter(ParameterSetName = 'one')\]
            \[String\]$param1,

            \[Parameter(ParameterSetName = 'two')\]
            \[String\]$param2
        )
    }
} -RuleName UseSyntacticallyCorrectExamples

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

