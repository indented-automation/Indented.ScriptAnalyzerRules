Describe AvoidEmptyNamedBlocks {
    BeforeAll {
        $ruleName = @{ RuleName = 'AvoidEmptyNamedBlocks' }
    }

    It 'Triggers when <Count> empty block(s) are used in the script "<Script>"' -TestCases @(
        @{
            Script = {
                begin { }
                process { Write-Verbose 'process' }
            }
            Count  = 1
        }
        @{
            Script = {
                begin { }
                process { Write-Verbose 'process' }
                end { }
            }
            Count  = 2
        }
        @{
            Script = {
                begin {
                    # Comments
                }
                end { Write-Verbose 'end' }
            }
            Count  = 1
        }
        @{
            Script = {
                dynamicparam { }
                process { }
                end { Write-Verbose 'end' }
            }
            Count  = 2
        }
    ) {
        $records = Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName
        $records | Should -Not -BeNullOrEmpty
        $records.Count | Should -Be $Count
    }

    It 'Does not trigger when all blocks are in use in "<Script>"' -TestCases @(
        @{
            Script = {
                dynamicparam { Write-Verbose 'dynamicpaaram' }
                begin { Write-Verbose 'begin' }
                process { Write-Verbose 'process' }
                end { Write-Verbose 'end' }
            }
        }
    ) {
        Invoke-CustomScriptAnalyzerRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
    }
}
