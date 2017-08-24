using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language

filter PSAvoidEmptyNamedBlocks {
    <#
    .SYNOPSIS
        PSAvoidEmptyNamedBlocks
    .DESCRIPTION
        Functions and scripts should not contain empty begin, process, end, or dynamicparam declarations.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { process { } } -RuleName AvoidEmptyNamedBlocks

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [NamedBlockAst]$ast
    )

    if ($ast.Statements.Count -eq 0) {
        [DiagnosticRecord]@{
            Message  = 'Empty {0} block.' -f $ast.BlockKind
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}