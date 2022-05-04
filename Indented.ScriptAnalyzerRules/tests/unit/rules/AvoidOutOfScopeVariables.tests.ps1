Describe AvoidOutOfScopeVariables {
    BeforeAll {
        $ruleName = @{ RuleName = 'AvoidOutOfScopeVariables' }
    }

    It 'Triggers when a script uses a variable from a parent scope "<Script>"' -TestCases @(
        @{
            Script = {
                function name {
                    if ($variable) { }
                }
            }
        }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -Not -BeNullOrEmpty
    }

    It 'Does not trigger when <Why> is used in "<Script>"' -TestCases @(
        @{
            Why    = 'the variable is assigned prior to use'
            Script = {
                function name {
                    $variable = $true
                    if ($variable) { }
                }
            }
        }
        @{
            Why    = 'a built-in variable'
            Script = {
                function name {
                    if ($PSVersionTable.PSVersion) { }
                }
            }
        }
        @{
            Why    = 'an explicit variable scope'
            Script = {
                function name {
                    if ($Script:variable) { }
                }
            }
        }
        @{
            Why    = 'a loop variable is used'
            Script = {
                function name {
                    $array = 1..5
                    foreach ($value in $array) {

                    }
                }
            }
        }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
    }
}
