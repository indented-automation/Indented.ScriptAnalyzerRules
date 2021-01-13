Describe AvoidParameterAttributeDefaultValues {
    BeforeAll {
        $ruleName = @{ RuleName = 'AvoidParameterAttributeDefaultValues' }
    }

    It 'Triggers when a default value is defined in a Parameter attribute in "<Script>"' -TestCases @(
        @{ Script = { param ( [Parameter(Mandatory = $false)]$Param ) } }
        @{ Script = { param ( [Parameter(Position = -2147483648)]$Param ) } }
        @{ Script = { param ( [Parameter(ParameterSetName = '__AllParameterSets')]$Param ) } }
        @{ Script = { param ( [Parameter(ValueFromPipeline = $false)]$Param ) } }
        @{ Script = { param ( [Parameter(ValueFromPipelineByPropertyName = $false)]$Param ) } }
        @{ Script = { param ( [Parameter(ValueFromRemainingArguments = $false)]$Param ) } }
        @{ Script = { param ( [Parameter(DontShow = $false)]$Param ) } }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -Not -BeNullOrEmpty
    }

    It 'Does not trigger a new value is defined in a Parameter attribute in "<Script>"' -TestCases @(
        @{ Script = { param ( [Parameter(Mandatory)]$Param ) } }
        @{ Script = { param ( [Parameter(Position = 0)]$Param ) } }
        @{ Script = { param ( [Parameter(ParameterSetName = 'SetName')]$Param ) } }
        @{ Script = { param ( [Parameter(ValueFromPipeline)]$Param ) } }
        @{ Script = { param ( [Parameter(ValueFromPipelineByPropertyName)]$Param ) } }
        @{ Script = { param ( [Parameter(ValueFromRemainingArguments)]$Param ) } }
        @{ Script = { param ( [Parameter(DontShow)]$Param ) } }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
    }
}
