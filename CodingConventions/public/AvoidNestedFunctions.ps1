filter AvoidNestedFunctions {
    <#
    .SYNOPSIS
        AvoidNestedFunctions
    .DESCRIPTION
        Functions should not contain nested functions.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [System.Management.Automation.Language.FunctionDefinitionAst]
        $ast
    )

    $ast.Body.FindAll( {
        param (
            $ast
        )

        $ast -is [System.Management.Automation.Language.FunctionDefinitionAst]
    }, $true ) | ForEach-Object {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'The function {0} in {1} contains the nested function {2}.' -f $ast.Name, $ast.Extent.File, $_.name
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}