Describe AvoidDashCharacters {
    BeforeDiscovery {
        $chars =  [char[]](8211, 8212, 8213)

        $allowedScripts = @(
            'Write-Host First {0} Second'
            'Write-Host "Text {0}"'
            '"Double {0} quoted"'
            "'Single {0} quote'"
            ('@"', 'Here{0}String', '"@' -join "`n")
            "@'`nHere{0}String`n'@"
        )
        $allowedCases = foreach ($char in $chars) {
            foreach ($script in $allowedScripts) {
                @{ Char = $char; Code = [int]$Char; String = $script -f $char }
            }
        }

        $disallowedScripts = @(
            '1 {0} 2'
            'Get-Command Get-Command {0}Syntax'
            'Get{0}Command'
            '1 {0}and 2'
            '5 {0}= 1'
        )
        $disallowedCases = foreach ($char in $chars) {
            foreach ($script in $disallowedScripts) {
                @{ Char = $char; Code = [int]$Char; String = $script -f $char }
            }
        }
    }

    BeforeAll {
        $ruleName = @{ RuleName = 'AvoidDashCharacters' }
    }

    It 'Allows <Char> (<Code>) inside a quoted string in script "<String>"' -TestCases $allowedCases {
        Invoke-CustomScriptAnalyzerRule -String $String @ruleName | Should -BeNullOrEmpty
    }

    It 'Does not allow <Char> (<Code>) outside a quoted string in script "<String>"' -TestCases $disallowedCases {
        Invoke-CustomScriptAnalyzerRule -String $String @ruleName | Should -Not -BeNullOrEmpty
    }
}
