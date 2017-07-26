filter AvoidUsingThrow {
    <#
    .SYNOPSIS
        AvoidUsingThrow
    .DESCRIPTION
        Advanced functions and scripts should not use throw, except within a try / catch block. Throw is affected by ErrorAction.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [System.Management.Automation.Language.FunctionDefinitionAst]
        $ast
    )

    [Boolean]$isAdvanced = $ast.Find( {
        param ( $ast )

        $ast -is [System.Management.Automation.Language.AttributeAst] -and 
        $ast.TypeName.Name -in 'CmdletBinding', 'Parameter'
    }, $true )

    if (-not $isAdvanced) {
        return
    }

    [Array]$throwStatements = $ast.FindAll( {
        param ( $ast )

        $ast -is [System.Management.Automation.Language.ThrowStatementAst]
    }, $true )

    if (-not $throwStatements) {
        return
    }

    [Array]$tryStatements = $ast.FindAll( {
        param ( $ast )

        $ast -is [System.Management.Automation.Language.TryStatementAst]
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
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                Message  = 'throw is used to terminate a function outside of try in the function {0}.' -f $ast.name
                Extent   = $throwStatement.Extent
                RuleName = $myinvocation.MyCommand.Name
                Severity = 'Warning'
            }
        }
    }
}