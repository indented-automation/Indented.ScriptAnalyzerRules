filter AvoidUsingAddType {
    <#
    .SYNOPSIS
        AvoidUsingAddType
    .DESCRIPTION
        Functions and scripts should not call Add-Type to load assemblies. Assemblies should be required in the module manifest.
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
        $ast.GetCommandName() -eq 'Add-Type'
    }, $true ) | ForEach-Object {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'Add-Type is used to load an assembly.'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}