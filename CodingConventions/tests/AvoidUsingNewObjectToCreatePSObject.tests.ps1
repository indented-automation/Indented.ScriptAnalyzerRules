InModuleScope CodingConventions {
    Describe AvoidUsingNewObjectToCreatePSObject {
        Context 'Present' {
            It 'New-Object with Property present, Returns record' {
                $script = {
                    New-Object PSObject -Property @{
                        One = 1
                    }
                }

                Invoke-CodingConventionRule -ScriptBlock $script 'AvoidUsingNewObjectToCreatePSObject' | Should -Not -BeNullOrEmpty
            }

            It 'New-Object without Property present, Returns null' {
                $script = {
                    New-Object PSObject
                }

                Invoke-CodingConventionRule -ScriptBlock $script 'AvoidUsingNewObjectToCreatePSObject' | Should -BeNullOrEmpty
            }
        }

        Context 'Absent' {
            It 'New-Object absent, Returns null' {
                $script = {
                    Write-Verbose 'script content'
                }

                Invoke-CodingConventionRule -ScriptBlock $script 'AvoidUsingNewObjectToCreatePSObject' | Should -BeNullOrEmpty
            }
        }
    }
}