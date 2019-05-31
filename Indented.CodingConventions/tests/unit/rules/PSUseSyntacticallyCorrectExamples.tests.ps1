InModuleScope Indented.CodingConventions {
    Describe PSUseSyntacticallyCorrectExamples {
        BeforeAll {
            $ruleName = @{ RuleName = 'PSUseSyntacticallyCorrectExamples' }
        }

        Context 'Present' {
            It 'Example present, invalid parameter, returns record' {
                $script = {
                    function name {
                        <#
                        .SYNOPSIS
                            name                        
                        .DESCRIPTION
                            name                        
                        .EXAMPLE
                            name -param2

                            An example of name.
                        #>
                        [CmdletBinding()]
                        param (
                            $param1
                        )
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
                $record.Message | Should -Match 'uses invalid parameter'
            }

            It 'Example present, valid parameter, invalid parameter set, returns record' {
                $script = {
                    function name {
                        <#
                        .SYNOPSIS
                            name                        
                        .DESCRIPTION
                            name                        
                        .EXAMPLE
                            name -param1 value -param2 value

                            An example of name.
                        #>
                        [CmdletBinding()]
                        param (
                            [Parameter(ParameterSetName = 'one')]
                            $param1,

                            [Parameter(ParameterSetName = 'two')]
                            $param2                            
                        )
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
                $record.Message | Should -Match 'Unable to determine parameter set'
            }

            It 'Example present, not advanced function, returns null' {
                $script = {
                    function name {
                        <#
                        .SYNOPSIS
                            name                        
                        .DESCRIPTION
                            name                        
                        .EXAMPLE
                            name -param1 value -param2 value

                            An example of name.
                        #>
                        param (
                            $param1
                        )
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }

            It 'Example present, valid parameters, no parameter set, returns null' {
                $script = {
                    function name {
                        <#
                        .SYNOPSIS
                            name                        
                        .DESCRIPTION
                            name                        
                        .EXAMPLE
                            name -param1 value

                            An example of name.
                        #>
                        [CmdletBinding()]
                        param (
                            $param1
                        )
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }

            It 'Example present, valid parameters, valid parameter set, returns null' {
                $script = {
                    function name {
                        <#
                        .SYNOPSIS
                            name                        
                        .DESCRIPTION
                            name                        
                        .EXAMPLE
                            name -param1 value

                            An example of name.
                        #>
                        [CmdletBinding()]
                        param (
                            [Parameter(ParameterSetName = 'one')]
                            $param1,

                            [Parameter(ParameterSetName = 'two')]
                            $param2
                        )
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }

            It 'Example present, valid parameters, valid parameter set, repeated "command" name, returns null' {
                $script = {
                    function name {
                        <#
                        .SYNOPSIS
                            name
                        .DESCRIPTION
                            name
                        .EXAMPLE
                            name -param1 value

                            name is used to do stuff.
                        #>
                        [CmdletBinding()]
                        param (
                            $param1
                        )
                    }
                }
                
                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }

        Context 'Absent' {
            It 'Write-Error absent, returns null' {
                $script = {
                    function name {
                        [CmdletBinding()]
                        param (
                            $param1
                        )
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }

            It 'parent is a class, returns null' {
                $script = {
                    class name {
                        [void] method () {

                        }
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }
    }
}
