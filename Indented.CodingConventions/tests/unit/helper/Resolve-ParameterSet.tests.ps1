InModuleScope Indented.CodingConventions {
    Describe Resolve-ParameterSet {
        BeforeAll {
            function NewTestSubject {
                param (
                    $paramBlock
                )

                & ([ScriptBlock]::Create("function Script:$Script:subjectName {
                    $paramBlock   
                }"))
            }

            $Script:subjectName = 'z' + [Guid]::NewGuid() -replace '-'
        }

        Context 'ParameterName empty' {
            BeforeAll {
                $params = @{
                    CommandName = $Script:subjectName
                }
            }

            It 'Returns __AllParameterSets, when no parameters are defined' {
                NewTestSubject -ParamBlock ''

                Resolve-ParameterSet @params | Should -Be '__AllParameterSets'
            }

            It 'Returns __AllParameterSets, when only non-mandatory parameters are defined' {
                NewTestSubject -ParamBlock '
                    param (
                        $param1,

                        $param2
                    )
                '
                
                Resolve-ParameterSet @params | Should -Be '__AllParameterSets'
            }

            It 'Returns a declared default parameter set name, when only non-mandatory parameters are defined' {
                NewTestSubject -ParamBlock '
                    [CmdletBinding(DefaultParameterSetName = "Default")]
                    param (
                        $param1,

                        $param2
                    )
                '
                
                Resolve-ParameterSet @params | Should -Be 'Default'
            }

            It 'Error, non-terminating, when no parameter sets match' {
                NewTestSubject -ParamBlock '
                    param (
                        [Parameter(Mandatory = $true)]
                        $param1
                    )
                '
                
                { Resolve-ParameterSet @params -ErrorAction Stop } | Should -Throw -ErrorId 'CouldNotResolveParameterSet'
                { Resolve-ParameterSet @params -ErrorAction SilentlyContinue } | Should -Not -Throw
            }
        }

        Context 'One parameter name requested' {
            BeforeAll {
                $params = @{
                    CommandName = $Script:subjectName
                    ParameterName = 'param1'
                }
            }

            It 'Returns __AllParameterSets, when a mandatory parameter is defined' {
                NewTestSubject -ParamBlock '
                    param (
                        [Parameter(Mandatory = $true)]
                        $param1
                    )
                '

                Resolve-ParameterSet @params | Should -Be '__AllParameterSets'
            }

            It 'Returns a declared default parameter set name, when a mandatory parameter is defined' {
                NewTestSubject -ParamBlock '
                    [CmdletBinding(DefaultParameterSetName = "Default")]
                    param (
                        [Parameter(Mandatory = $true)]
                        $param1
                    )
                '

                Resolve-ParameterSet @params | Should -Be 'Default'
            }

            It 'Returns a named parameter set name, when a mandatory parameter is defined in a set' {
                NewTestSubject -ParamBlock '
                    param (
                        [Parameter(Mandatory = $true, ParameterSetName = "Alternate")]
                        $param1
                    )
                '

                Resolve-ParameterSet @params | Should -Be 'Alternate'
            }

            It 'Returns a named parameter set name, when a mandatory parameter is defined in more than one set' {
                NewTestSubject -ParamBlock '
                    [CmdletBinding(DefaultParameterSetName = "Default")]
                    param (
                        [Parameter(Mandatory = $true, ParameterSetName = "Default")]
                        [Parameter(Mandatory = $true, ParameterSetName = "Alternate")]
                        $param1,

                        [Parameter(Mandatory = $true, ParameterSetName = "Default")]
                        $param2
                    )
                '

                Resolve-ParameterSet @params | Should -Be 'Alternate'
            }

            It 'Error, Non-terminating, when the parameter is not listed' {
                NewTestSubject -ParamBlock '
                    [CmdletBinding(DefaultParameterSetName = "Default")]
                    param (
                        $param2,

                        $param3
                    )
                '

                { Resolve-ParameterSet @params -ErrorAction Stop } | Should -Throw -ErrorId 'CouldNotResolveParameterSet'
                { Resolve-ParameterSet @params -ErrorAction SilentlyContinue } | Should -Not -Throw
            }
        }

        Context 'Two parameter names requested' {
            BeforeAll {
                $params = @{
                    CommandName = $Script:subjectName
                    ParameterName = 'param1', 'param2'
                }
            }

            It 'Returns __AllParameterSets, when either parameter is mandatory' {
                NewTestSubject -ParamBlock '
                    param (
                        [Parameter(Mandatory = $true)]
                        $param1,

                        $param2
                    )
                '

                Resolve-ParameterSet @params | Should -Be '__AllParameterSets'

                NewTestSubject -ParamBlock '
                    param (
                        $param1,

                        [Parameter(Mandatory = $true)]
                        $param2
                    )
                '

                Resolve-ParameterSet @params | Should -Be '__AllParameterSets'
            }

            It 'Returns a declared default parameter set name, when a mandatory parameter is defined' {
                NewTestSubject -ParamBlock '
                    [CmdletBinding(DefaultParameterSetName = "Default")]
                    param (
                        [Parameter(Mandatory = $true)]
                        $param1,

                        $param2
                    )
                '

                Resolve-ParameterSet @params | Should -Be 'Default'
            }
            
            It 'Returns a named parameter set name, when a mandatory parameter is defined in more than one set' {
                NewTestSubject -ParamBlock '
                    [CmdletBinding(DefaultParameterSetName = "Default")]
                    param (
                        [Parameter(Mandatory = $true, ParameterSetName = "Default")]
                        [Parameter(Mandatory = $true, ParameterSetName = "Alternate")]
                        $param1,

                        [Parameter(Mandatory = $true, ParameterSetName = "Alternate")]
                        $param2
                    )
                '

                Resolve-ParameterSet @params | Should -Be 'Alternate'
            }

            It 'Returns a declared default parameter set name, when the default parameter set was used to break an ambiguous set tie' {
                NewTestSubject -ParamBlock '
                    [CmdletBinding(DefaultParameterSetName = "Default")]
                    param (
                        [Parameter(Mandatory = $true, ParameterSetName = "Default")]
                        [Parameter(Mandatory = $true, ParameterSetName = "Alternate")]
                        $param1,

                        [Parameter(Mandatory = $true, ParameterSetName = "Default")]
                        [Parameter(Mandatory = $true, ParameterSetName = "Alternate")]
                        $param2
                    )
                '

                Resolve-ParameterSet @params | Should -Be 'Default'
            }

            It 'Error, Non-terminating, when either parameter is not listed' {
                NewTestSubject -ParamBlock '
                    [CmdletBinding(DefaultParameterSetName = "Default")]
                    param (
                        $param1,

                        $param3
                    )
                '

                { Resolve-ParameterSet @params -ErrorAction Stop } | Should -Throw -ErrorId 'CouldNotResolveParameterSet'
                { Resolve-ParameterSet @params -ErrorAction SilentlyContinue } | Should -Not -Throw

                NewTestSubject -ParamBlock '
                    [CmdletBinding(DefaultParameterSetName = "Default")]
                    param (
                        $param2,

                        $param3
                    )
                '

                { Resolve-ParameterSet @params -ErrorAction Stop } | Should -Throw -ErrorId 'CouldNotResolveParameterSet'
                { Resolve-ParameterSet @params -ErrorAction SilentlyContinue } | Should -Not -Throw                
            }

            It 'Error, Non-terminating, when the parameters resolve to more than one non-default parameter set' {
                NewTestSubject -ParamBlock '
                    [CmdletBinding(DefaultParameterSetName = "Default")]
                    param (
                        [Parameter(Mandatory = $true, ParameterSetName = "Alternate1")]
                        [Parameter(Mandatory = $true, ParameterSetName = "Alternate2")]
                        $param1,

                        [Parameter(Mandatory = $true, ParameterSetName = "Alternate1")]
                        [Parameter(Mandatory = $true, ParameterSetName = "Alternate2")]
                        $param2
                    )
                '

                { Resolve-ParameterSet @params -ErrorAction Stop } | Should -Throw -ErrorId 'AmbiguousParameterSet'
                { Resolve-ParameterSet @params -ErrorAction SilentlyContinue } | Should -Not -Throw
            }
        }
    }
}