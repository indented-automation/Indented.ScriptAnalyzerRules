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

    $ast.FindAll( {
        param (
            $ast
        )

        if ($ast -is [System.Management.Automation.Language.FunctionDefinitionAst]) {
            [Boolean]$isAdvanced = $ast.Find( {
                param ( $ast )

                $ast -is [System.Management.Automation.Language.AttributeAst] -and 
                $ast.TypeName.Name -in 'CmdletBinding', 'Parameter'
            }, $true )

            if ($isAdvanced) {
                [Array]$throwStatements = $ast.Find( {
                    param ( $ast )

                    $ast -is [System.Management.Automation.Language.ThrowStatementAst]
                }, $true )
                if ($throwStatements) {
                    [Array]$tryStatements = $ast.Find( {
                        param ( $ast )

                        $ast -is [System.Management.Automation.Language.TryStatementAst]
                    }, $true )

                    if (-not $tryStatements) {
                        $ast
                    } elseif ($tryStatements) {
                        $isWithinExtentOfTry = $false
                        foreach ($throwStatement in $throwStatements) {
                            foreach ($tryStatement in $tryStatements) {
                                if ($throwStatement.Extent.StartOffset -gt $tryStatement.Extent.StartOffset -and 
                                        $throwStatement.Extent.EndOffset -lt $tryStatement.Extent.EndOffset) {

                                    $isWithinExtentOfTry = $true
                                }
                            }
                        }
                        if (-not $isWithinExtentOfTry) {
                            $ast
                        }
                    }
                }
            }
        }
    }, $true ) | ForEach-Object {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'throw is used to terminate a function outside of try in the function {0}.' -f $_.name
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}