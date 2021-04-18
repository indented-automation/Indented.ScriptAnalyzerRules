Describe Resolve-ParameterSet {
    AfterAll {
        Remove-Item Function:Global:TestFunction
    }

    Context 'ParameterName empty' {
        BeforeAll {
            $module = @{
                ModuleName = 'Indented.ScriptAnalyzerRules'
            }
            $params = @{
                CommandName = 'TestFunction'
            }
        }

        It 'Returns __AllParameterSets, when no parameters are defined' {
            function Global:TestFunction { }

            Resolve-ParameterSet @params | Should -Be '__AllParameterSets'
        }

        It 'Returns __AllParameterSets, when only non-mandatory parameters are defined' {
            function Global:TestFunction {
                param (
                    $param1,
                    $param2
                )
            }

            Resolve-ParameterSet @params | Should -Be '__AllParameterSets'
        }

        It 'Returns a declared default parameter set name, when only non-mandatory parameters are defined' {
            function Global:TestFunction {
                [CmdletBinding(DefaultParameterSetName = "Default")]
                param (
                    $param1,

                    $param2
                )
            }

            Resolve-ParameterSet @params | Should -Be 'Default'
        }

        It 'Error, non-terminating, when no parameter sets match' {
            function Global:TestFunction {
                [CmdletBinding(DefaultParameterSetName = "Default")]
                param (
                    [Parameter(Mandatory)]
                    $param1
                )
            }

            { Resolve-ParameterSet @params -ErrorAction Stop } | Should -Throw -ErrorId 'CouldNotResolveParameterSet,Resolve-ParameterSet'
            { Resolve-ParameterSet @params -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }

    Context 'One parameter name requested' {
        BeforeAll {
            $params = @{
                CommandName   = 'TestFunction'
                ParameterName = 'param1'
            }
        }

        It 'Returns __AllParameterSets, when a mandatory parameter is defined' {
            function Global:TestFunction {
                param (
                    [Parameter(Mandatory)]
                    $param1
                )
            }

            Resolve-ParameterSet @params | Should -Be '__AllParameterSets'
        }

        It 'Returns a declared default parameter set name, when a mandatory parameter is defined' {
            function Global:TestFunction {
                [CmdletBinding(DefaultParameterSetName = "Default")]
                param (
                    [Parameter(Mandatory)]
                    $param1
                )
            }

            Resolve-ParameterSet @params | Should -Be 'Default'
        }

        It 'Returns a named parameter set name, when a mandatory parameter is defined in a set' {
            function Global:TestFunction {
                param (
                    [Parameter(Mandatory, ParameterSetName = "Alternate")]
                    $param1
                )
            }

            Resolve-ParameterSet @params | Should -Be 'Alternate'
        }

        It 'Returns a named parameter set name, when a mandatory parameter is defined in more than one set' {
            function Global:TestFunction {
                [CmdletBinding(DefaultParameterSetName = "Default")]
                param (
                    [Parameter(Mandatory = $true, ParameterSetName = "Default")]
                    [Parameter(Mandatory = $true, ParameterSetName = "Alternate")]
                    $param1,

                    [Parameter(Mandatory = $true, ParameterSetName = "Default")]
                    $param2
                )
            }

            Resolve-ParameterSet @params | Should -Be 'Alternate'
        }

        It 'Error, Non-terminating, when the parameter is not listed' {
            function Global:TestFunction {
                [CmdletBinding(DefaultParameterSetName = "Default")]
                param (
                    $param2,

                    $param3
                )
            }

            { Resolve-ParameterSet @params -ErrorAction Stop } | Should -Throw -ErrorId 'CouldNotResolveParameterSet,Resolve-ParameterSet'
            { Resolve-ParameterSet @params -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }

    Context 'Two parameter names requested' {
        BeforeAll {
            $params = @{
                CommandName   = 'TestFunction'
                ParameterName = 'param1', 'param2'
            }
        }

        It 'Returns __AllParameterSets, when either parameter is mandatory' {
            function Global:TestFunction {
                param (
                    [Parameter(Mandatory)]
                    $param1,

                    $param2
                )
            }

            Resolve-ParameterSet @params | Should -Be '__AllParameterSets'

            function Global:TestFunction {
                param (
                    $param1,

                    [Parameter(Mandatory)]
                    $param2
                )
            }

            Resolve-ParameterSet @params | Should -Be '__AllParameterSets'
        }

        It 'Returns a declared default parameter set name, when a mandatory parameter is defined' {
            function Global:TestFunction {
                [CmdletBinding(DefaultParameterSetName = "Default")]
                param (
                    [Parameter(Mandatory)]
                    $param1,

                    $param2
                )
            }

            Resolve-ParameterSet @params | Should -Be 'Default'
        }

        It 'Returns a named parameter set name, when a mandatory parameter is defined in more than one set' {
            function Global:TestFunction {
                [CmdletBinding(DefaultParameterSetName = "Default")]
                param (
                    [Parameter(Mandatory, ParameterSetName = "Default")]
                    [Parameter(Mandatory, ParameterSetName = "Alternate")]
                    $param1,

                    [Parameter(Mandatory, ParameterSetName = "Alternate")]
                    $param2
                )
            }

            Resolve-ParameterSet @params | Should -Be 'Alternate'
        }

        It 'Returns a declared default parameter set name, when the default parameter set was used to break an ambiguous set tie' {
            function Global:TestFunction {
                [CmdletBinding(DefaultParameterSetName = "Default")]
                param (
                    [Parameter(Mandatory, ParameterSetName = "Default")]
                    [Parameter(Mandatory, ParameterSetName = "Alternate")]
                    $param1,

                    [Parameter(Mandatory, ParameterSetName = "Default")]
                    [Parameter(Mandatory, ParameterSetName = "Alternate")]
                    $param2
                )
            }

            Resolve-ParameterSet @params | Should -Be 'Default'
        }

        It 'Error, Non-terminating, when either parameter is not listed' {
            function Global:TestFunction {
                [CmdletBinding(DefaultParameterSetName = "Default")]
                param (
                    $param1,

                    $param3
                )
            }

            { Resolve-ParameterSet @params -ErrorAction Stop } | Should -Throw -ErrorId 'CouldNotResolveParameterSet,Resolve-ParameterSet'
            { Resolve-ParameterSet @params -ErrorAction SilentlyContinue } | Should -Not -Throw

            function Global:TestFunction {
                [CmdletBinding(DefaultParameterSetName = "Default")]
                param (
                    $param2,

                    $param3
                )
            }

            { Resolve-ParameterSet @params -ErrorAction Stop } | Should -Throw -ErrorId 'CouldNotResolveParameterSet,Resolve-ParameterSet'
            { Resolve-ParameterSet @params -ErrorAction SilentlyContinue } | Should -Not -Throw
        }

        It 'Error, Non-terminating, when the parameters resolve to more than one non-default parameter set' {
            function Global:TestFunction {
                [CmdletBinding(DefaultParameterSetName = "Default")]
                param (
                    [Parameter(Mandatory, ParameterSetName = "Alternate1")]
                    [Parameter(Mandatory, ParameterSetName = "Alternate2")]
                    $param1,

                    [Parameter(Mandatory, ParameterSetName = "Alternate1")]
                    [Parameter(Mandatory, ParameterSetName = "Alternate2")]
                    $param2
                )
            }

            { Resolve-ParameterSet @params -ErrorAction Stop } | Should -Throw -ErrorId 'AmbiguousParameterSet,Resolve-ParameterSet'
            { Resolve-ParameterSet @params -ErrorAction SilentlyContinue } | Should -Not -Throw
        }
    }
}
