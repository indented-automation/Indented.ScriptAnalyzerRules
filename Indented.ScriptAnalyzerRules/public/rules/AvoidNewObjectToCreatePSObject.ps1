using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language

function AvoidNewObjectToCreatePSObject {
    <#
    .SYNOPSIS
        AvoidNewObjectToCreatePSObject

    .DESCRIPTION
        Functions and scripts should use [PSCustomObject] to create PSObject instances with named properties.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [CommandAst]$ast
    )

    if ($ast -is [CommandAst] -and
        $ast.GetCommandName() -eq 'New-Object' -and
        $ast.CommandElements.Where{ $_.ParameterName -like 'Prop*' }) {

        [DiagnosticRecord]@{
            Message  = 'New-Object is used to create a custom object. [PSCustomObject] should be used instead.'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}
