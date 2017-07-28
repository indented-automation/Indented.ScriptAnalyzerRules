using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language

filter AvoidEmptyNamedBlocks {
    <#
    .SYNOPSIS
        AvoidEmptyNamedBlocks
    .DESCRIPTION
        Functions and scripts should not contain empty begin, process, end, or dynamicparam declarations.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { process { } } -RuleName AvoidEmptyNamedBlocks

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [ScriptBlockAst]
        $ast
    )

    $ast.FindAll( {
        param ( $ast )

        $ast -is [NamedBlockAst] -and
        $ast.Statements.Count -eq 0
    }, $true ) | ForEach-Object {
        [DiagnosticRecord]@{
            Message  = 'Empty {0} block.' -f $_.BlockKind
            Extent   = $_.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}