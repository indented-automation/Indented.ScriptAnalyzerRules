InModuleScope Indented.CodingConventions {
    Describe PSUseFilterForProcessBlockOnlyFunctions {
        BeforeAll {
            $ruleName = @{ RuleName = 'PSUseFilterForProcessBlockOnlyFunctions' }
        }

        Context 'Present' {
            It 'Function using process block only present, returns record' {
                $script  = {
                    function name {
                        [CmdletBinding()]
                        param (
                            [Parameter(ValueFromPipeline = $true)]
                            $param
                        )

                        process {
                            'Hello world'
                        }
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }
        }

        Context 'Absent' {
            It 'Function present, begin present, returns null' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param (
                            [Parameter(ValueFromPipeline = $true)]
                            $param
                        )

                        begin {
                            'Hello'
                        }

                        process {
                            'World'
                        }
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }

            It 'Function present, end present, returns null' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param (
                            [Parameter(ValueFromPipeline = $true)]
                            $param
                        )

                        process {
                            'Hello'
                        }

                        end {
                            'World'
                        }
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }

            It 'Function present, no blocks, returns null' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param (
                            [Parameter(ValueFromPipeline = $true)]
                            $param
                        )

                        'Hello world'
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }

            It 'Function present, no pipeline parameters, returns null' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param (
                            $param
                        )

                        process {
                            'Hello world'
                        }
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }

            It 'Filter present, returns null' {
                $script  = {
                    filter name {
                        [CmdletBinding()]
                        param (
                            [Parameter(ValueFromPipeline = $true)]
                            $param
                        )

                        'Hello world'
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }
    }
}