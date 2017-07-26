filter AvoidEmptyNamedBlocks {
    <#
    .SYNOPSIS
        AvoidEmptyNamedBlocks
    .DESCRIPTION
        Functions and scripts should not contain empty begin, process, end, or dynamicparam declarations.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ast
    )

    $ast.FindAll( {
        param ( $ast )

        $ast -is [System.Management.Automation.Language.NamedBlockAst] -and
        $ast.Statements.Count -eq 0
    }, $true ) | ForEach-Object {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'Empty {0} block.' -f $_.BlockKind
            Extent   = $_.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}