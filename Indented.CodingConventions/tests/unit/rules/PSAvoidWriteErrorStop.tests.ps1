InModuleScope Indented.CodingConventions {
    Describe PSAvoidWriteErrorStop {
        BeforeAll {
            $ruleName = @{ RuleName = 'PSAvoidWriteErrorStop' }
        }

        Context 'Present' {
            It 'Write-Error, with ErrorAction Stop present, returns record' {
                $script = {
                    Write-Error -Message 'message' -ErrorAction Stop
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }

            It 'Write-Error present, with ErrorAction 1, returns record' {
                $script = {
                    Write-Error -Message 'message' -ErrorAction 1
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }

            It 'Write-Error present, with EA Stop, returns record' {
                $script = {
                    Write-Error -Message 'message' -EA Stop
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }

            It 'Write-Error present, with EA 1, returns record' {
                $script = {
                    Write-Error -Message 'message' -EA 1
                }

                $record = Invoke-CodingConventionRule -ScriptBlock $script @ruleName
                $record | Should -Not -BeNullOrEmpty
                @($record).Count | Should -Be 1
            }

            It 'Write-Error present, without ErrorAction Stop, returns null' {
                $script = {
                    Write-Error -Message 'message'
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }

        Context 'Absent' {
            It 'Write-Error absent, returns null' {
                $script = {
                    Write-Verbose 'script content'
                }

                Invoke-CodingConventionRule -ScriptBlock $script @ruleName | Should -BeNullOrEmpty
            }
        }
    }
}