InModuleScope CodingConventions {
    Describe AvoidUsingNewObjectToCreatePSObject {
        BeforeAll {
            $ruleName = @{ RuleName = 'AvoidUsingNewObjectToCreatePSObject' }
        }

        Context 'Present' {
            It 'New-Object present, with Property, returns record' {
                $script = {
                    New-Object PSObject -Property @{
                        One = 1
                    }
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }

            It 'New-Object present, without Property, returns null' {
                $script = {
                    New-Object PSObject
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }

        Context 'Absent' {
            It 'New-Object absent, returns null' {
                $script = {
                    Write-Verbose 'script content'
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }
    }
}