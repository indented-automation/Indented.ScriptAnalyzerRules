InModuleScope CodingConventions {
    Describe AvoidUsingThrow {
        Context 'Present' {
            It 'Throw present, outside try, Returns record' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param ( )

                        throw 'some message'
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script 'AvoidUsingThrow' | Should -Not -BeNullOrEmpty
            }

            It 'Throw present, outside try, try present, Returns record' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param ( )

                        throw 'some message'
                        try {
                            'something else'
                        } catch {
                            Write-Verbose 'Error action'
                        }
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script 'AvoidUsingThrow' | Should -Not -BeNullOrEmpty
            }

            It 'Throw present, inside try, Returns null' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param ( )
                        
                        try {
                            throw 'some message'
                        } catch {
                            Write-Verbose 'Error action'
                        }
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script 'AvoidUsingThrow' | Should -BeNullOrEmpty
            }

            It 'Throw present, nested, inside try' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param ( )

                        try {
                            if ($someCondition) {
                                throw 'some message'
                            }
                        } catch {
                            Write-Verbose 'Error action'
                        }
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script 'AvoidUsingThrow' | Should -BeNullOrEmpty
            }
        }

        Context 'Absent' {
            It 'Throw absent, Returns null' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param ( )

                        Write-Verbose 'script content'
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script 'AvoidUsingThrow' | Should -BeNullOrEmpty
            }
        }
    }
}