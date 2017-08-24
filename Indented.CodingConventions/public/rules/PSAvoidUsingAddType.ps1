using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language

filter PSAvoidUsingAddType {
    <#
    .SYNOPSIS
        PSAvoidUsingAddType
    .DESCRIPTION
        Functions and scripts should not call Add-Type to load assemblies. Assemblies should be required in the module manifest.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { Add-Type -AssemblyName System.Web } -RuleName AvoidUsingAddType

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [CommandAst]$ast
    )

    if ($ast -is [CommandAst] -and
        $ast.GetCommandName() -eq 'Add-Type') {

        [DiagnosticRecord]@{
            Message  = 'Add-Type is used to load an assembly.'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}