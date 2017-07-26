filter AvoidNestedFunctions {
    <#
    .SYNOPSIS
        AvoidNestedFunctions
    .DESCRIPTION
        Functions should not contain nested functions.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { function outer { function inner { } } } -RuleName AvoidNestedFunctions

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param (
        # An AST node.
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
            Extent   = $_.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}