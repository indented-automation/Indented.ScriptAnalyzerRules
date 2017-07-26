filter AvoidUsingAddType {
    <#
    .SYNOPSIS
        AvoidUsingAddType
    .DESCRIPTION
        Functions and scripts should not call Add-Type to load assemblies. Assemblies should be required in the module manifest.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { Add-Type -AssemblyName System.Web } -RuleName AvoidUsingAddType

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
        $ast.GetCommandName() -eq 'Add-Type') {

        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'Add-Type is used to load an assembly.'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}