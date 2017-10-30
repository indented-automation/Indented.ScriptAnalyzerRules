InModuleScope Indented.CodingConventions {
    Describe PSDoNotCreateObjectsFromAnEmptyString {
        BeforeAll {
            $ruleName = @{ RuleName = 'PSDoNotCreateObjectsFromAnEmptyString' }
        }

        Context 'Present' {
            It 'Select-Object from empty string present, returns record' {
                $script = {
                    '' | Select-Object Property1, Property2
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName                
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }

            It 'Select-Object from a string containing spaces only, returns record' {
                $script = {
                    ' ' | Select-Object Property1, Property2
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName                
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }
        }

        Context 'Absent' {
            It 'Select-Object from a variable, returns null' {
                $script = {
                    $value | Select-Object Property1, Property2
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }

            It 'Select-Object from another command, returns null' {
                $script = {
                    Get-Process | Select-Object Property1, Property2
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }
    }
}