Describe AvoidProcessWithoutPipeline {
    BeforeAll {
        $ruleName = @{ RuleName = 'AvoidProcessWithoutPipeline' }
    }

    It 'Triggers when process is used but no parameters accept pipeline input in "<Script>"' -TestCases @(
        @{
            Script = {
                param (
                    $param
                )

                process {
                    Write-Verbose 'process'
                }
            }
        }
        @{
            Script = {
                param (
                    [Parameter(ValueFromPipeline = $false)]
                    $param
                )

                process {
                    Write-Verbose 'process'
                }
            }
        }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $Script @ruleName | Should -Not -BeNullOrEmpty
    }

    It 'Does not trigger when process is used and one or more parameters accept pipeline input in "<Script>"' -TestCases @(
        @{
            Script = {
                param (
                    [Parameter(ValueFromPipeline)]
                    $param
                )

                process {
                    Write-Verbose 'process'
                }
            }
        }
        @{
            Script = {
                param (
                    [Parameter(ValueFromPipelineByPropertyName)]
                    $param
                )

                process {
                    Write-Verbose 'process'
                }
            }
        }
        @{
            Script = {
                param (
                    [Parameter(ValueFromPipelineByPropertyName)]
                    $param1,

                    [Parameter(ValueFromPipelineByPropertyName)]
                    $param2
                )

                process {
                    Write-Verbose 'process'
                }
            }
        }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $Script @ruleName | Should -BeNullOrEmpty
    }
}
