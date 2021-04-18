Describe AvoidFilter {
    BeforeAll {
        $ruleName = @{ RuleName = 'AvoidFilter' }
    }

    It 'Triggers when filter is used instead of function in "<Script>"' -TestCases @(
        @{ Script = { filter name { 'Hello world' } } }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -Not -BeNullOrEmpty
    }
}
