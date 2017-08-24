InModuleScope Indented.CodingConventions {
    Describe PSAvoidNestedFunctions {
        BeforeAll {
            $ruleName = @{ RuleName = 'PSAvoidNestedFunctions' }
        }

        Context 'Present, single result' {
            BeforeAll {
                $script = {
                    function outer {
                        function inner {
                            Write-Verbose 'body'
                        }
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName
            }

            It 'Nested function present, returns record' {
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }

            It 'Record description, contains the name of the parent function' {
                $record.Message | Should -match 'outer'
            }
        }

        Context 'Present, multiple results' {
            BeforeAll {
                $script = {
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
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName
            }

            It 'Nested functions present, returns 2 records' {
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 2
            }

            It 'Record descriptions, contain the name of the parent function' {
                $record[0].Message | Should -Match 'outer1'
                $record[0].Message | Should -Match 'inner1'
                $record[1].Message | Should -Match 'outer2'
                $record[1].Message | Should -Match 'inner2'
            } 
        }

        Context 'Absent' {
            It 'Nested function absent, returns null' {
                $script = {
                    function outer {
                        Write-Verbose 'body'
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }
    }
}