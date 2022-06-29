Describe UseSyntacticallyCorrectExamples {
    BeforeAll {
        $ruleName = @{ RuleName = 'UseSyntacticallyCorrectExamples' }
    }

    Context 'Present' {
        It 'Example present, invalid parameter, returns record' {
            $script = {
                function testFunction {
                    <#
                    .SYNOPSIS
                        testFunction
                    .DESCRIPTION
                        testFunction
                    .EXAMPLE
                        testFunction -param2

                        An example of testFunction.
                    #>
                    [CmdletBinding()]
                    param (
                        $param1
                    )
                    $param1
                }
            }

            $record = Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName
            $record | Should -Not -BeNullOrEmpty
            @($record).Count | Should -Be 1
            $record.Message | Should -Match 'uses invalid parameter'
        }

        It 'Example present, valid parameter, invalid parameter set, returns record' {
            $script = {
                function testFunction {
                    <#
                    .SYNOPSIS
                        testFunction
                    .DESCRIPTION
                        testFunction
                    .EXAMPLE
                        testFunction -param1 value -param2 value

                        An example of testFunction.
                    #>
                    [CmdletBinding()]
                    param (
                        [Parameter(ParameterSetName = 'one')]
                        $param1,

                        [Parameter(ParameterSetName = 'two')]
                        $param2
                    )
                    $param1
                    $param2
                }
            }

            $record = Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName
            $record | Should -Not -BeNullOrEmpty
            @($record).Count | Should -Be 1
            $record.Message | Should -Match 'Unable to determine parameter set'
        }

        It 'Example present, not advanced function, returns null' {
            $script = {
                function testFunction {
                    <#
                    .SYNOPSIS
                        testFunction
                    .DESCRIPTION
                        testFunction
                    .EXAMPLE
                        testFunction -param1 value -param2 value

                        An example of testFunction.
                    #>
                    param (
                        $param1
                    )
                    $param1
                }
            }

            Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
        }

        It 'Example present, valid parameters, no parameter set, returns null' {
            $script = {
                function testFunction {
                    <#
                    .SYNOPSIS
                        testFunction
                    .DESCRIPTION
                        testFunction
                    .EXAMPLE
                        testFunction -param1 value

                        An example of testFunction.
                    #>
                    [CmdletBinding()]
                    param (
                        $param1
                    )
                    $param1
                }
            }

            Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
        }

        It 'Example present, valid parameters, valid parameter set, returns null' {
            $script = {
                function testFunction {
                    <#
                    .SYNOPSIS
                        testFunction
                    .DESCRIPTION
                        testFunction
                    .EXAMPLE
                        testFunction -param1 value

                        An example of testFunction.
                    #>
                    [CmdletBinding()]
                    param (
                        [Parameter(ParameterSetName = 'one')]
                        $param1,

                        [Parameter(ParameterSetName = 'two')]
                        $param2
                    )
                    $param1
                    $param2
                }
            }

            Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
        }

        It 'Example present, valid parameters, valid parameter set, repeated "command" name, returns null' {
            $script = {
                function testFunction {
                    <#
                    .SYNOPSIS
                        testFunction
                    .DESCRIPTION
                        testFunction
                    .EXAMPLE
                        testFunction -param1 value

                        testFunction is used to do stuff.
                    #>
                    [CmdletBinding()]
                    param (
                        $param1
                    )
                    $param1
                }
            }

            Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
        }
    }

    Context 'Absent' {
        It 'Write-Error absent, returns null' {
            $script = {
                function testFunction {
                    [CmdletBinding()]
                    param (
                        $param1
                    )
                    $param1
                }
            }

            Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
        }
    }
}
