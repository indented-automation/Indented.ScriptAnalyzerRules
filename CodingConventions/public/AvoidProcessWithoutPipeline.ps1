filter AvoidProcessWithoutPipeline {
    <#
    .SYNOPSIS
        AvoidProcessWithoutPipeline
    .DESCRIPTION
        Functions and scripts should not declare process unless an input pipeline is supported.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { function name { process { } } } -RuleName AvoidProcessWithoutPipeline

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [System.Management.Automation.Language.ScriptBlockAst]
        $ast
    )

    if ($ast.ProcessBlock -ne $null) {
        [Boolean]$acceptsPipelineInput = if ($ast.ParamBlock) {
            $ast.ParamBlock.Find( {
                param ( $ast )

                $ast -is [System.Management.Automation.Language.AttributeAst] -and 
                $ast.TypeName.Name -eq 'Parameter' -and
                $ast.NamedArguments.Where{
                    $_.ArgumentName -in 'ValueFromPipeline', 'ValueFromPipelineByPropertyName' -and
                    $_.Argument.SafeGetValue() -eq $true
                }
            }, $false )
        }

        if (-not $acceptsPipelineInput) {
            [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                Message  = 'Process declared without an input pipeline'
                Extent   = $ast.ProcessBlock.Extent
                RuleName = $myinvocation.MyCommand.Name
                Severity = 'Warning'
            }
        }
    }
}