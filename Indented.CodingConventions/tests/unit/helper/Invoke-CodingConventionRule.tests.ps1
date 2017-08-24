InModuleScope Indented.CodingConventions {
    Describe Invoke-CodingConventionRule {
        BeforeAll {
            function CCTestRule {
                param (
                    [System.Management.Automation.Language.ScriptBlockAst]$ast
                )

                'RuleOutput'
            }
        }

        Context 'FromPath' {
            BeforeAll {
                '"Hello world"' | Out-File 'TestDrive:\script.ps1'

                $params = @{
                    Path     = 'TestDrive:\script.ps1'
                    RuleName = 'CCTestRule'
                }
            }

            It 'Executes a rule for a script' {
                Invoke-CodingConventionRule @params | Should -Be 'RuleOutput'
            }
        }

        Context 'FromCommandName' {
            BeforeAll {
                function CCCommandName {

                }

                $params = @{
                    CommandName = 'CCCommandName'
                    RuleName    = 'CCTestRule'
                }
            }

            It 'Executes a rule for a script' {
                Invoke-CodingConventionRule @params | Should -Be 'RuleOutput'
            }
        }

        Context 'FromScriptBlock' {
            BeforeAll {
                $params = @{
                    ScriptBlock = { 'Hello world' }
                    RuleName    = 'CCTestRule'
                }
            }

            It 'Executes a rule for a script block' {
                Invoke-CodingConventionRule @params | Should -Be 'RuleOutput'
            }
        }

        Context 'Error handling' {
            It 'Error, Terminating, when the rule does not exist' {
                $params = @{
                    ScriptBlock = { 'Hello world' }
                    RuleName    = 'CCInvalidTestRule'
                }

                { Invoke-CodingConventionRule @params } | Should -Throw -ErrorId 'InvalidRuleName'
            }

            It 'Error, Terminating, when attempting to run using a compiled command' {
                $params = @{
                    CommandName = 'Get-Process'
                    RuleName    = 'CCTestRule'
                }

                { Invoke-CodingConventionRule @params } | Should -Throw -ErrorId 'InvalidCommand'
            }
        }
    }
}