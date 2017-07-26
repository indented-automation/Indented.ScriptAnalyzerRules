filter AvoidUsingNewObjectToCreatePSObject {
    <#
    .SYNOPSIS
        AvoidUsingNewObjectToCreatePSObject
    .DESCRIPTION
        Functions and scripts should use [PSCustomObject] to create PSObject instances with named properties.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { New-Object PSObject -Property @{} } -RuleName AvoidUsingNewObjectToCreatePSObject

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [System.Management.Automation.Language.CommandAst]
        $ast
    )

    if ($ast -is [System.Management.Automation.Language.CommandAst] -and
        $ast.GetCommandName() -eq 'New-Object' -and
        $ast.CommandElements.Where{ $_.ParameterName -like 'Prop*' }) {

        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'New-Object is used to create an object. [PSCustomObject] should be used instead.'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}