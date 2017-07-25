InModuleScope CodingConventions {
    Describe AvoidNestedFunctions {
        Context 'Present, Single result' {
            BeforeAll {
                $script = {
                    function outer {
                        function inner {
                            Write-Verbose 'body'
                        }
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script 'AvoidNestedFunctions'
            }

            It 'Nested function present, Returns record' {
                $record | Should -Not -BeNullOrEmpty
            }

            It 'Record description, contains the name of the parent function' {
                $record.Message | Should -match 'outer'
            }
        }

        Context 'Present, Multiple results' {
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

                $record = Invoke-CodingConventionRule -ScriptBlock $script 'AvoidNestedFunctions'
            }

            It 'Nested functions present, Returns 2 records' {
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
            It 'Nested function absent, Returns null' {
                $script = {
                    function outer {
                        Write-Verbose 'body'
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script 'AvoidNestedFunctions' | Should -BeNullOrEmpty
            }
        }
    }
}