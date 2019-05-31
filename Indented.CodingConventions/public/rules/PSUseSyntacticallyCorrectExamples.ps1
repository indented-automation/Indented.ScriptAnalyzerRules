using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language

filter PSUseSyntacticallyCorrectExamples {
    <#
    .SYNOPSIS
        PSUseSyntacticallyCorrectExamples
    .DESCRIPTION
        Examples should use parameters described by the function correctly.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock {
            function name {
                # .SYNOPSIS
                #   name
                # .DESCRIPTION
                #   description
                # .EXAMPLE
                #   name -param3 value

                [CmdletBinding()]
                param (
                    [String]$param1,

                    [String]$param2
                )
            }
        } -RuleName UseSyntacticallyCorrectExamples

        Execute the rule against a script block using Invoke-CodingConventionRule.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock {
            function name {
                # .SYNOPSIS
                #   name
                # .DESCRIPTION
                #   description
                # .EXAMPLE
                #   name -param1 value -param2 value

                [CmdletBinding()]
                param (
                    [Parameter(ParameterSetName = 'one')]
                    [String]$param1,

                    [Parameter(ParameterSetName = 'two')]
                    [String]$param2
                )
            }
        } -RuleName UseSyntacticallyCorrectExamples

        Execute the rule against a script block using Invoke-CodingConventionRule.        
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'hasTriggered')]
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [FunctionDefinitionAst]$ast
    )

    if ($ast.Parent.Parent.IsClass) {
        return
    }
    
    $definition = [ScriptBlock]::Create($ast.Extent.ToString())
    $functionInfo = Get-FunctionInfo -ScriptBlock $definition

    if ($functionInfo.CmdletBinding) {
        $helpContent = $ast.GetHelpContent()

        for ($i = 0; $i -lt $helpContent.Examples.Count; $i++) {
            $example = $helpContent.Examples[$i]
            $exampleNumber = $i + 1

            $exampleAst = [Parser]::ParseInput(
                $example,
                [Ref]$null,
                [Ref]$null
            )

            $exampleAst.FindAll( {
                param ( $ast )

                $ast -is [CommandAst]
            }, $false ) | Where-Object {
                $_.GetCommandName() -eq $ast.Name
            } | ForEach-Object {
                $hasTriggered = $false

                # Non-existant parameters
                $_.CommandElements | Where-Object {
                    $_ -is [CommandParameterAst] -and $_.ParameterName -notin $functionInfo.Parameters.Keys
                } | ForEach-Object {
                    $hasTriggered = $true

                    [DiagnosticRecord]@{
                        Message  = 'Example {0} in function {1} uses invalid parameter {2}.' -f
                            $exampleNumber,
                            $ast.Name,
                            $_.ParameterName
                        Extent   = $ast.Extent
                        RuleName = $myinvocation.MyCommand.Name
                        Severity = 'Warning'
                    }
                }

                # Only trigger this test if the command includes valid parameters.
                if (-not $hasTriggered) {
                    # Ambiguous parameter set use
                    try {
                        $parameterName = $_.CommandElements | Where-Object { $_ -is [CommandParameterAst] } | ForEach-Object { $_.ParameterName }
                        $null = Resolve-ParameterSet -CommandInfo $functionInfo -ParameterName $parameterName -ErrorAction Stop
                    } catch {
                        Write-Debug $_.Exception.Message

                        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                            Message  = 'Unable to determine parameter set used by example {0} for the function {1}' -f
                                $exampleNumber,
                                $ast.Name
                            Extent   = $ast.Extent
                            RuleName = $myinvocation.MyCommand.Name
                            Severity = 'Warning'
                        }
                    }
                }
            }
        }
    }
}
