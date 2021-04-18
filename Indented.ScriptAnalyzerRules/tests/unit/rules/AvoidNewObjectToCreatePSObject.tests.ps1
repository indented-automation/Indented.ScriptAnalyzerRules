Describe AvoidNewObjectToCreatePSObject {
    BeforeAll {
        $ruleName = @{ RuleName = 'AvoidNewObjectToCreatePSObject' }
    }

    It 'Triggers when New-Object PSObject is used in "<Script>"' -TestCases @(
        @{ Script = { New-Object PSObject } }
        @{ Script = { New-Object PSObject -Property @{ One = 1 } } }
        @{ Script = { New-Object -TypeName PSObject -Property @{ One = 1 } } }
        @{ Script = { New-Object -Property @{ One = 1 } -TypeName PSObject } }
        @{ Script = { New-Object -Property @{ One = 1 } PSObject } }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -Not -BeNullOrEmpty
    }

    It 'Does not trigger when New-Object is used to create other object types' -TestCases @(
        @{ Script = { New-Object OtherObjectType } }
        @{ Script = { New-Object OtherObjectType -Property @{ One = 1 } } }
        @{ Script = { New-Object -Property @{ One = 1 } OtherObjectType } }
        @{ Script = { New-Object -TypeName OtherObjectType -Property @{ One = 1 } } }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
    }
}
