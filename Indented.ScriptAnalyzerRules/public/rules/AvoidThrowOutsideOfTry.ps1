using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language

function AvoidThrowOutsideOfTry {
    <#
    .SYNOPSIS
        AvoidThrowOutsideOfTry

    .DESCRIPTION
        Advanced functions and scripts should not use throw, except within a try / catch block. Throw is affected by ErrorAction.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [FunctionDefinitionAst]$ast
    )

    $isAdvanced = $null -ne $ast.Find(
        {
            param ( $ast )

            $ast -is [AttributeAst] -and
            $ast.TypeName.Name -in 'CmdletBinding', 'Parameter'
        },
        $true
    )

    if (-not $isAdvanced) {
        return
    }

    $throwStatements = $ast.FindAll(
        {
            param ( $ast )

            $ast -is [ThrowStatementAst]
        },
        $true
    )

    if (-not $throwStatements) {
        return
    }

    $tryStatements = $ast.FindAll(
        {
            param ( $ast )

            $ast -is [TryStatementAst]
        },
        $true
    )

    foreach ($throwStatement in $throwStatements) {
        $isWithinExtentOfTry = $false

        foreach ($tryStatement in $tryStatements) {
            $isStatementWithinExtentOfTry = (
                $throwStatement.Extent.StartOffset -gt $tryStatement.Extent.StartOffset -and
                $throwStatement.Extent.EndOffset -lt $tryStatement.Extent.EndOffset
            )

            if ($isStatementWithinExtentOfTry) {
                $isWithinExtentOfTry = $true
            }
        }
        if (-not $isWithinExtentOfTry) {
            [DiagnosticRecord]@{
                Message  = 'throw is used to terminate a function outside of try in the function {0}.' -f $ast.name
                Extent   = $throwStatement.Extent
                RuleName = $myinvocation.MyCommand.Name
                Severity = 'Error'
            }
        }
    }
}
