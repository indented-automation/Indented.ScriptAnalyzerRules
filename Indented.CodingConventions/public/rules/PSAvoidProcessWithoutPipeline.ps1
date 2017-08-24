using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language

filter PSAvoidProcessWithoutPipeline {
    <#
    .SYNOPSIS
        PSAvoidProcessWithoutPipeline
    .DESCRIPTION
        Functions and scripts should not declare process unless an input pipeline is supported.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { function name { process { } } } -RuleName AvoidProcessWithoutPipeline

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [ScriptBlockAst]$ast
    )

    if ($null -ne $ast.ProcessBlock -and $ast.ParamBlock) {
        $attributeAst = $ast.ParamBlock.Find( {
            param ( $ast )

            $ast -is [AttributeAst] -and 
            $ast.TypeName.Name -eq 'Parameter' -and
            $ast.NamedArguments.Where{
                $_.ArgumentName -in 'ValueFromPipeline', 'ValueFromPipelineByPropertyName' -and
                $_.Argument.SafeGetValue() -eq $true
            }
        }, $false )

        if (-not $attributeAst) {
            [DiagnosticRecord]@{
                Message  = 'Process declared without an input pipeline'
                Extent   = $ast.ProcessBlock.Extent
                RuleName = $myinvocation.MyCommand.Name
                Severity = 'Warning'
            }
        }
    }
}