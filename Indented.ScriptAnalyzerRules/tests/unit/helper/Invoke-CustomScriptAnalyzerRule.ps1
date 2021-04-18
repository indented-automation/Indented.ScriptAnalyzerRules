Describe Invoke-CustomScriptAnalyzerRule {
    BeforeAll {
        function TestRule {
            [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
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
                RuleName = 'TestRule'
            }
        }

        It 'Executes a rule for a script' {
            Invoke-CustomScriptAnalyzerRule @params | Should -Be 'RuleOutput'
        }
    }

    Context 'FromCommandName' {
        BeforeAll {
            function CCCommandName {

            }

            $params = @{
                CommandName = 'CCCommandName'
                RuleName    = 'TestRule'
            }
        }

        It 'Executes a rule for a script' {
            Invoke-CustomScriptAnalyzerRule @params | Should -Be 'RuleOutput'
        }
    }

    Context 'FromScriptBlock' {
        BeforeAll {
            $params = @{
                ScriptBlock = { 'Hello world' }
                RuleName    = 'TestRule'
            }
        }

        It 'Executes a rule for a script block' {
            Invoke-CustomScriptAnalyzerRule @params | Should -Be 'RuleOutput'
        }
    }

    Context 'Error handling' {
        It 'Error, Terminating, when the rule does not exist' {
            $params = @{
                ScriptBlock = { 'Hello world' }
                RuleName    = 'CCInvalidTestRule'
            }

            { Invoke-CustomScriptAnalyzerRule @params } | Should -Throw -ErrorId 'InvalidRuleName'
        }

        It 'Error, Terminating, when attempting to run using a compiled command' {
            $params = @{
                CommandName = 'Get-Process'
                RuleName    = 'TestRule'
            }

            { Invoke-CustomScriptAnalyzerRule @params } | Should -Throw -ErrorId 'InvalidCommand'
        }
    }
}
