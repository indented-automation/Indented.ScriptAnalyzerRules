InModuleScope CodingConventions {
    Describe AvoidProcessWithoutPipeline {
        BeforeAll {
            $ruleName = @{ RuleName = 'AvoidProcessWithoutPipeline' }
        }

        Context 'Present' {
            It 'Process present, no input pipeline, returns record' {
                $script = {
                    process {
                        Write-Verbose 'process'
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName                
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }

            It 'Process present, param present, no input pipeline, returns record' {
                $script = {
                    param (
                        [String]$param
                    )
                    
                    process {
                        Write-Verbose 'process'
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName                
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }

            It 'Process present, param present, no input pipeline, returns record' {
                $script = {
                    param (
                        [Parameter(ValueFromPipeline = $false)]
                        [String]$param
                    )
                    
                    process {
                        Write-Verbose 'process'
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName                
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }

            It 'Process present, param present, input pipeline (explicit, ByVal), returns null' {
                $script = {
                    param (
                        [Parameter(ValueFromPipeline = $true)]
                        [String]$param
                    )

                    process {
                        Write-Verbose 'process'
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }

            It 'Process present, param present, input pipeline (implicit, ByVal), returns null' {
                $script = {
                    param (
                        [Parameter(ValueFromPipeline)]
                        [String]$param
                    )

                    process {
                        Write-Verbose 'process'
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }

            It 'Process present, param present, input pipeline (explicit, ByPropertyName), returns null' {
                $script = {
                    param (
                        [Parameter(ValueFromPipelineByPropertyName = $true)]
                        [String]$param
                    )

                    process {
                        Write-Verbose 'process'
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }

            It 'Process present, param present, input pipeline (implicit, ByPropertyName), returns null' {
                $script = {
                    param (
                        [Parameter(ValueFromPipelineByPropertyName)]
                        [String]$param
                    )

                    process {
                        Write-Verbose 'process'
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }

        Context 'Absent' {
            It 'Process absent, returns null' {
                $script = {
                    Write-Verbose 'body'
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }
    }
}