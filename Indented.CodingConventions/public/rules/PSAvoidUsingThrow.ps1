using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language

filter PSAvoidUsingThrow {
    <#
    .SYNOPSIS
        PSAvoidUsingThrow
    .DESCRIPTION
        Advanced functions and scripts should not use throw, except within a try / catch block. Throw is affected by ErrorAction.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { function name { [CmdletBinding()]param ( ); throw 'message' } } -RuleName AvoidUsingThrow

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [FunctionDefinitionAst]$ast
    )

    $isAdvanced = $null -ne $ast.Find( {
        param ( $ast )

        $ast -is [AttributeAst] -and 
        $ast.TypeName.Name -in 'CmdletBinding', 'Parameter'
    }, $true )

    if (-not $isAdvanced) {
        return
    }

    [Array]$throwStatements = $ast.FindAll( {
        param ( $ast )

        $ast -is [ThrowStatementAst]
    }, $true )

    if (-not $throwStatements) {
        return
    }

    [Array]$tryStatements = $ast.FindAll( {
        param ( $ast )

        $ast -is [TryStatementAst]
    }, $true )

    foreach ($throwStatement in $throwStatements) {
        $isWithinExtentOfTry = $false

        foreach ($tryStatement in $tryStatements) {
            if ($throwStatement.Extent.StartOffset -gt $tryStatement.Extent.StartOffset -and 
                    $throwStatement.Extent.EndOffset -lt $tryStatement.Extent.EndOffset) {

                $isWithinExtentOfTry = $true
            }
        }
        if (-not $isWithinExtentOfTry) {
            [DiagnosticRecord]@{
                Message  = 'throw is used to terminate a function outside of try in the function {0}.' -f $ast.name
                Extent   = $throwStatement.Extent
                RuleName = $myinvocation.MyCommand.Name
                Severity = 'Warning'
            }
        }
    }
}