using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language

function AvoidNestedFunctions {
    <#
    .SYNOPSIS
        AvoidNestedFunctions

    .DESCRIPTION
        Functions should not contain nested functions.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
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
