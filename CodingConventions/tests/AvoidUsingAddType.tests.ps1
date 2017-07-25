InModuleScope CodingConventions {
    Describe AvoidUsingAddType {
        Context 'Present' {
            It 'Add-Type present, Returns record' {
                $script = {
                    Add-Type -AssemblyName 'SomeAssemblyName'
                }

                Invoke-CodingConventionRule -ScriptBlock $script 'AvoidUsingAddType' | Should -Not -BeNullOrEmpty
            }
        }

        Context 'Absent' {
            It 'Add-Type absent, Returns null' {
                $script = {
                    Write-Verbose 'script content'
                }

                Invoke-CodingConventionRule -ScriptBlock $script 'AvoidUsingAddType' | Should -BeNullOrEmpty
            }
        }
    }
}