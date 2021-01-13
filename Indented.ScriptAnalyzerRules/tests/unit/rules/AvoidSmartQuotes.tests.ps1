Describe AvoidSmartQuotes {
    BeforeDiscovery {
        $quoteStyles = @(
            @{ OuterQuotes = '"'; InnerQuotes = [char]8216 }
            @{ OuterQuotes = '"'; InnerQuotes = [char]8217 }
            @{ OuterQuotes = "'"; InnerQuotes = [char]8220 }
            @{ OuterQuotes = "'"; InnerQuotes = [char]8221 }
        )

        $allowedScripts = @(
            '{0}{1}quoted string{1}{0}'
            ('@{0}', '{1}Here-String{1}', '{0}@' -join "`n")
        )
        $allowedCases = foreach ($quoteStyle in $quoteStyles) {
            foreach ($script in $allowedScripts) {
                @{
                    Char   = $quoteStyle['InnerQuotes']
                    Code   = [int]$quoteStyle['InnerQuotes']
                    String = $script -f $quoteStyle['OuterQuotes'], $quoteStyle['InnerQuotes']
                }
            }
        }

        $disallowedScripts = @(
            '{0}string{0}'
            ('@{0}', 'Here-String', '{0}@' -join "`n")
        )
        $disallowedCases = foreach ($quoteStyle in $quoteStyles) {
            foreach ($script in $disallowedScripts) {
                @{
                    Char   = $quoteStyle['InnerQuotes']
                    Code   = [int]$quoteStyle['InnerQuotes']
                    String = $script -f $quoteStyle['InnerQuotes']
                }
            }
        }
    }

    BeforeAll {
        $ruleName = @{ RuleName = 'AvoidSmartQuotes' }
    }

    It 'Allows <Char> (<Code>) in a quoted string in script "<String>"' -TestCases $allowedCases {
        Invoke-CustomScriptAnalyzerRule -String $String @ruleName | Should -BeNullOrEmpty
    }

    It 'Does not allow <Char> (<Code>) outside a quoted string in script "<String>"' -TestCases $disallowedCases {
        Invoke-CustomScriptAnalyzerRule -String $String @ruleName | Should -Not -BeNullOrEmpty
    }
}
