using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language

filter PSAvoidUsingRedirection {
    <#
    .SYNOPSIS
        PSAvoidUsingRedirection
    .DESCRIPTION
        Avoid using redirection to write to files.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { 'string' > 'file.txt' } -RuleName PSAvoidUsingRedirection

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [Parameter(ValueFromPipeline)]
        [FileRedirectionAst]$ast
    )

    [DiagnosticRecord]@{
        Message  = 'File redirection is being used to write file content in {0}.' -f $ast.Extent.File
        Extent   = $ast.Extent
        RuleName = $myinvocation.MyCommand.Name
        Severity = 'Warning'
    }
}