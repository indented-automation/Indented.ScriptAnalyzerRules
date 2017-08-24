using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language

filter PSAvoidNestedFunctions {
    <#
    .SYNOPSIS
        PSAvoidNestedFunctions
    .DESCRIPTION
        Functions should not contain nested functions.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { function outer { function inner { } } } -RuleName AvoidNestedFunctions

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [FunctionDefinitionAst]$ast
    )

    $ast.Body.FindAll( {
        param (
            $ast
        )

        $ast -is [FunctionDefinitionAst]
    }, $true ) | ForEach-Object {
        [DiagnosticRecord]@{
            Message  = 'The function {0} in {1} contains the nested function {2}.' -f $ast.Name, $ast.Extent.File, $_.name
            Extent   = $_.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}