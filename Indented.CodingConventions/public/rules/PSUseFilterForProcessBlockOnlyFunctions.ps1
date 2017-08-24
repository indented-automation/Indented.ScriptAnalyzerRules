using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language

filter PSUseFilterForProcessBlockOnlyFunctions {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [FunctionDefinitionAst]$ast
    )

    if ($ast.IsFilter -eq $false -and $null -eq $ast.Body.BeginBlock -and $null -eq $ast.Body.EndBlock) {
        $attributeAst = $ast.Body.ParamBlock.Find( {
            param ( $ast )

            $ast -is [AttributeAst] -and 
            $ast.TypeName.Name -eq 'Parameter' -and
            $ast.NamedArguments.Where{
                $_.ArgumentName -in 'ValueFromPipeline', 'ValueFromPipelineByPropertyName' -and
                $_.Argument.SafeGetValue() -eq $true
            }
        }, $false )

        if ($attributeAst) {
            [DiagnosticRecord]@{
                Message  = 'Functions which accept pipeline input and only use a process block should be created using "filter"'
                Extent   = $ast.Extent
                RuleName = $myinvocation.MyCommand.Name
                Severity = 'Warning'
            }
        }
    }
}