Describe AvoidHelpMessage {
    BeforeAll {
        $ruleName = @{ RuleName = 'AvoidHelpMessage' }
    }

    It 'Triggers when a HelpMessage is defined in a Parameter attribute in "<Script>"' -TestCases @(
        @{ Script = { param ( [Parameter(HelpMessage = 'Some help message')]$Param ) } }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -Not -BeNullOrEmpty
    }

    It 'Does not trigger when HelpMessage is absent in "<Script>"' -TestCases @(
        @{ Script = { param ( [Parameter()]$Param ) } }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
    }
}
