filter AvoidUsingNewObjectToCreatePSObject {
    <#
    .SYNOPSIS
        AvoidUsingNewObjectToCreatePSObject
    .DESCRIPTION
        Functions and scripts should use [PSCustomObject] to create PSObject instances with named properties.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [System.Management.Automation.Language.CommandAst]
        $ast
    )

    $ast.FindAll( {
        param (
            $ast
        )

        $ast -is [System.Management.Automation.Language.CommandAst] -and
        $ast.GetCommandName() -eq 'New-Object' -and
        $ast.CommandElements.Where{ $_.ParameterName -like 'Prop*' }
    }, $true ) | ForEach-Object {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'New-Object is used to create an object. [PSCustomObject] should be used instead.'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}