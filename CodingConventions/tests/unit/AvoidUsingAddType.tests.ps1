InModuleScope CodingConventions {
    Describe AvoidUsingAddType {
        BeforeAll {
            $ruleName = @{ RuleName = 'AvoidUsingAddType' }
        }

        Context 'Present' {
            It 'Add-Type present, returns record' {
                $script = {
                    Add-Type -AssemblyName 'SomeAssemblyName'
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }
        }

        Context 'Absent' {
            It 'Add-Type absent, returns null' {
                $script = {
                    Write-Verbose 'script content'
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }
    }
}