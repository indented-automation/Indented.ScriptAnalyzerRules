InModuleScope Indented.CodingConventions {
    Describe PSAvoidEmptyNamedBlocks {
        BeforeAll {
            $ruleName = @{ RuleName = 'PSAvoidEmptyNamedBlocks' }
        }

        Context 'Present' {
            It 'Empty Begin present, returns record' {
                $script = {
                    begin {

                    }

                    process {
                        Write-Verbose 'process'
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName                
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
                $record.Message | Should -Match 'begin'
            }

            It 'Empty Begin and End present, returns 2 records' {
                $script = {
                    begin {

                    }

                    process {
                        Write-Verbose 'process'
                    }

                    end {

                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName                
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 2
                $record[0].Message | Should -Match 'begin'
                $record[1].Message | Should -Match 'end'
            }

            It 'Empty DynamicParam and Process present, returns 2 records' {
                $script = {
                    dynamicparam {

                    }

                    process {

                    }

                    end {
                        Write-Verbose 'end'
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName                
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 2
                $record[0].Message | Should -Match 'dynamicparam'
                $record[1].Message | Should -Match 'process'
            }

            It 'Empty Begin, with comments, returns 1 record' {
                $script = {
                    begin {
                        # Comments
                    }

                    end {
                        Write-Verbose 'end'
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName                
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
                $record.Message | Should -Match 'begin'
            }
        }

        Context 'Absent' {
            It 'Named blocks absent, returns null' {
                $script = {
                    Write-Verbose 'body'
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }
    }
}