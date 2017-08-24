InModuleScope Indented.CodingConventions {
    # TODO
    
    Describe 'PSScriptAnalyzer: AvoidNestedFunctions' {
        BeforeAll {
            $rulePath = @{
                CustomRulePath = (Get-Module CodingConventions).Path -replace 'm1$', 'd1'
            }
        }

        Context 'Present, Single result' {
            It 'Nested function present, returns record' {
                $script = "
                    function outer {
                        function inner {
                            Write-Verbose 'body'
                        }
                    }
                "

                $record = Invoke-ScriptAnalyzer -ScriptDefinition $script @rulePath
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }
        }

        Context 'Present, Multiple results' {
            It 'Nested functions present, returns 2 records' {
                $script = "
                    function outer1 {
                        function inner1 {
                            Write-Verbose 'body'
                        }
                    }

                    function outer2 {
                        function inner2 {
                            Write-Verbose 'body'
                        }
                    }
                "

                $record = Invoke-ScriptAnalyzer -ScriptDefinition $script @rulePath
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 2
            }
        }

        Context 'Absent' {
            It 'Nested function absent, returns null' {
                $script = "
                    function outer {
                        Write-Verbose 'body'
                    }
                "

                Invoke-ScriptAnalyzer -ScriptDefinition $script @rulePath | Should -BeNullOrEmpty
            }
        }
    }
}