Describe Get-FunctionInfo {
    Context 'From file' {
        It 'Generates FunctionInfo from a script in a file' {
            "function Get-Something { }" | Out-File TestDrive:\script.ps1

            $functionInfo = Get-FunctionInfo -Path TestDrive:\script.ps1
            $functionInfo | Should -Not -BeNullOrEmpty
            $functionInfo | Should -BeOfType [System.Management.Automation.FunctionInfo]
            $functionInfo.Name | Should -Be 'Get-Something'
        }

        It 'Ignores nested functions by default' {
            "function Get-Something { function Set-Something { } }" | Out-File TestDrive:\script.ps1

            $functionInfo = Get-FunctionInfo -Path TestDrive:\script.ps1
            $functionInfo | Should -Not -BeNullOrEmpty
            @($functionInfo).Count | Should -Be 1
        }

        It 'Finds nested functions when requested' {
            "function Get-Something { function Set-Something { } }" | Out-File TestDrive:\script.ps1

            $functionInfo = Get-FunctionInfo -Path TestDrive:\script.ps1 -IncludeNested
            $functionInfo | Should -Not -BeNullOrEmpty
            @($functionInfo).Count | Should -Be 2
        }

        It 'Error, non-terminating, when the file content is not valid' {
            "function Get-Something" | Out-File TestDrive:\script.ps1

            { Get-FunctionInfo -Path TestDrive:\script.ps1 -ErrorAction Stop } | Should -Throw
            { Get-FunctionInfo -Path TestDrive:\script.ps1 -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }

    Context 'From script block' {
        It 'Generates FunctionInfo from a script in a file' {
            $script = {
                function Get-Something { }
            }

            $functionInfo = Get-FunctionInfo -ScriptBlock $script
            $functionInfo | Should -Not -BeNullOrEmpty
            $functionInfo | Should -BeOfType [System.Management.Automation.FunctionInfo]
            $functionInfo.Name | Should -Be 'Get-Something'
        }

        It 'Ignores nested functions by default' {
            $script = {
                function Get-Something {
                    function Set-Something { }
                }
            }

            $functionInfo = Get-FunctionInfo -ScriptBlock $script
            $functionInfo | Should -Not -BeNullOrEmpty
            @($functionInfo).Count | Should -Be 1
        }

        It 'Finds nested functions when requested' {
            $script = {
                function Get-Something {
                    function Set-Something { }
                }
            }

            $functionInfo = Get-FunctionInfo -ScriptBlock $script -IncludeNested
            $functionInfo | Should -Not -BeNullOrEmpty
            @($functionInfo).Count | Should -Be 2
        }
    }
}
