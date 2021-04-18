Describe AvoidCreatingObjectsFromAnEmptyString {
    BeforeAll {
        $ruleName = @{ RuleName = 'AvoidCreatingObjectsFromAnEmptyString' }
    }

    It 'Triggers when Select-Object is used in "<Script>"' -TestCases @(
        @{ Script = { '' | Select-Object Property1, Property2 } }
        @{ Script = { ' ' | Select-Object Property1, Property2 } }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -Not -BeNullOrEmpty
    }

    It 'Does not trigger when Select-Object is used in "<Script>"' -TestCases @(
        @{ Script = { $value | Select-Object Property1, Property2 } }
        @{ Script = { Get-Process | Select-Object Property1, Property2 } }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
    }
}
