Describe AvoidNestedFunctions {
    BeforeAll {
        $ruleName = @{ RuleName = 'AvoidNestedFunctions' }
    }

    It 'Triggers when nested within another function in "<Script>"' -TestCases @(
        @{
            Script = {
                function outer {
                    function inner {
                        Write-Verbose 'body'
                    }
                }
            }
        }
        @{
            Script = {
                function outer1 {
                    function inner1 {
                        Write-Verbose 'body'
                    }
                }

                function outer2 {
                    function inner2 {
                        Write-Verbose 'body'
                    }
                }
            }
        }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -Not -BeNullOrEmpty
    }

    It 'Does not trigger when a function does not contain another nested function' -TestCases @(
        @{
            Script = {
                function outer {
                    Write-Verbose 'body'
                }
            }
        }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
    }
}
