Describe AvoidThrowOutsideOfTry {
    BeforeAll {
        $ruleName = @{ RuleName = 'AvoidThrowOutsideOfTry' }
    }

    It 'Triggers when throw is used outside of a try block in "<Script>"' -TestCases @(
        @{
            Script = {
                function name {
                    [CmdletBinding()]
                    param ( )

                    throw 'message'
                }
            }
        }
        @{
            Script = {
                function name {
                    [CmdletBinding()]
                    param ( )

                    try {
                        function nested {
                            throw 'message'
                        }
                    } catch {

                    }
                }
            }
        }
        @{
            Script = {
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
        }
        @{
            Script = {
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
        }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -Not -BeNullOrEmpty
    }

    It 'Does not trigger when used inside of a try block in "<Script>"' -TestCases @(
        @{
            Script = {
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
        }
        @{
            Script = {
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
        }
        @{
            Script = {
                function name {
                    [CmdletBinding()]
                    param ( )

                    try {
                        # Any other code
                    } catch {
                        Write-Verbose 'Error action'
                    }
                }
            }
        }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
    }
}
