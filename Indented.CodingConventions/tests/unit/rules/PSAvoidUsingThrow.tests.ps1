InModuleScope Indented.CodingConventions {
    Describe PSAvoidUsingThrow {
        BeforeAll {
            $ruleName = @{ RuleName = 'PSAvoidUsingThrow' }
        }

        Context 'Present' {
            It 'Throw present, outside try, returns record' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param ( )

                        throw 'message'
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }

            It 'Throw present, outside try, try present, returns record' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param ( )

                        throw 'message'
                        try {
                            'something else'
                        } catch {
                            Write-Verbose 'Error action'
                        }
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }

            It 'Throw present, mixed, returns record' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param ( )

                        throw 'message 1'
                        try {
                            throw 'message 2'
                        } catch {
                            Write-Verbose 'Error action'
                        }
                        throw 'message 3'
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 2
            }

            It 'Throw present, inside try, returns null' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param ( )
                        
                        try {
                            throw 'message'
                        } catch {
                            Write-Verbose 'Error action'
                        }
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }

            It 'Throw present, nested, inside try' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param ( )

                        try {
                            if ($someCondition) {
                                throw 'message'
                            }
                        } catch {
                            Write-Verbose 'Error action'
                        }
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }

        Context 'Absent' {
            It 'Throw absent, returns null' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param ( )

                        Write-Verbose 'script content'
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }
    }
}