Describe UseExpressionlessArgumentsInTheParameterAttribute {
    BeforeAll {
        $ruleName = @{ RuleName = 'UseExpressionlessArgumentsInTheParameterAttribute' }
    }

    It 'Triggers when an argument is prvodied for a boolean Parameter attribute value in "<Script>"' -TestCases @(
        @{ Script = { param ( [Parameter(Mandatory = $true)]$Param ) } }
        @{ Script = { param ( [Parameter(ValueFromPipeline = $true)]$Param ) } }
        @{ Script = { param ( [Parameter(ValueFromPipelineByPropertyName = $true)]$Param ) } }
        @{ Script = { param ( [Parameter(ValueFromRemainingArguments = $true)]$Param ) } }
        @{ Script = { param ( [Parameter(DontShow = $true)]$Param ) } }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -Not -BeNullOrEmpty
    }

    It 'Does not trigger a value is expressionless, or a non-boolean value is required in "<Script>"' -TestCases @(
        @{ Script = { param ( [Parameter(Mandatory)]$Param ) } }
        @{ Script = { param ( [Parameter(ValueFromPipeline)]$Param ) } }
        @{ Script = { param ( [Parameter(ValueFromPipelineByPropertyName)]$Param ) } }
        @{ Script = { param ( [Parameter(ValueFromRemainingArguments)]$Param ) } }
        @{ Script = { param ( [Parameter(DontShow)]$Param ) } }
        @{ Script = { param ( [Parameter(Position = 0)]$Param ) } }
        @{ Script = { param ( [Parameter(ParameterSetName = 'SomeName')]$Param ) } }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
    }
}
