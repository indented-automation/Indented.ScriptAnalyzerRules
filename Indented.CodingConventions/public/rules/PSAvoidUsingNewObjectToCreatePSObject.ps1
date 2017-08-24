using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language

filter PSAvoidUsingNewObjectToCreatePSObject {
    <#
    .SYNOPSIS
        PSAvoidUsingNewObjectToCreatePSObject
    .DESCRIPTION
        Functions and scripts should use [PSCustomObject] to create PSObject instances with named properties.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { New-Object PSObject -Property @{} } -RuleName AvoidUsingNewObjectToCreatePSObject

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
        $ast.GetCommandName() -eq 'New-Object' -and
        $ast.CommandElements.Where{ $_.ParameterName -like 'Prop*' }) {

        [DiagnosticRecord]@{
            Message  = 'New-Object is used to create an object. [PSCustomObject] should be used instead.'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}