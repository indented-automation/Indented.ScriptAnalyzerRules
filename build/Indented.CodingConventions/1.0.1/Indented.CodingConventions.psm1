using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation
using namespace System.Management.Automation.Language
using namespace System.Reflection

function Get-FunctionInfo {
    <#
    .SYNOPSIS
        Get an instance of FunctionInfo.
    .DESCRIPTION
        FunctionInfo does not present a public constructor. This function calls an internal / private constructor on FunctionInfo to create a description of a function from a script block or file containing one or more functions.
    .INPUTS
        System.String
    .EXAMPLE
        Get-ChildItem -Filter *.psm1 | Get-FunctionInfo

        Get all functions declared within the *.psm1 file and construct FunctionInfo.
    .EXAMPLE
        Get-ChildItem C:\Scripts -Filter *.ps1 -Recurse | Get-FunctionInfo

        Get all functions declared in all ps1 files in C:\Scripts.
    .NOTES
        Change log:
            10/12/2015 - Chris Dent - Improved error handling.
            28/10/2015 - Chris Dent - Created.
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromPath')]
    [OutputType([System.Management.Automation.FunctionInfo])]
    param (
        # The path to a file containing one or more functions.
        [Parameter(Position = 1, ValueFromPipelineByPropertyName = $true, ParameterSetName = 'FromPath')]
        [Alias('FullName')]
        [String]$Path,

        # A script block containing one or more functions.
        [Parameter(ParameterSetName = 'FromScriptBlock')]
        [ScriptBlock]$ScriptBlock,

        # By default functions nested inside other functions are ignored. Setting this parameter will allow nested functions to be discovered.
        [Switch]$IncludeNested
    )

    begin {
        $executionContextType = [PowerShell].Assembly.GetType('System.Management.Automation.ExecutionContext')
        $constructor = [FunctionInfo].GetConstructor(
            [BindingFlags]'NonPublic, Instance',
            $null,
            [CallingConventions]'Standard, HasThis',
            ([String], [ScriptBlock], $executionContextType),
            $null
        )
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'FromPath') {
            try {
                $scriptBlock = [ScriptBlock]::Create((Get-Content $Path -Raw))
            } catch {
                $ErrorRecord = @{
                    Exception = $_.Exception.InnerException
                    ErrorId   = 'InvalidScriptBlock'
                    Category  = 'OperationStopped'
                }
                Write-Error @ErrorRecord
            }
        }

        if ($scriptBlock) {
            $scriptBlock.Ast.FindAll( {
                    param( $ast )

                    $ast -is [FunctionDefinitionAst]
                },
                $IncludeNested
            ) | ForEach-Object {
                $constructor.Invoke(([String]$_.Name, $_.Body.GetScriptBlock(), $null))
            }
        }
    }
}

function Invoke-CodingConventionRule {
    <#
    .SYNOPSIS
        Invoke a specific coding convention rule.
    .DESCRIPTION
        Invoke a specific coding convention rule against a defined file, script block, or command name.
    .EXAMPLE
        Invoke-CodingConventionRule -Path C:\Script.ps1 -RuleName AvoidNestedFunctions

        Invoke the rule AvoidNestedFunctions against the script in the specified path.
    .NOTES
        Change log:
            26/07/2017 - Chris Dent - Created.
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromPath')]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'FromPath')]
        [String]$Path,

        [Parameter(Mandatory = $true, ParameterSetName = 'FromScriptBlock')]
        [ScriptBlock]$ScriptBlock,

        [Parameter(Mandatory = $true, ParameterSetName = 'FromCommandName')]
        [String]$CommandName,

        [Parameter(Mandatory = $true, Position = 2)]
        [String]$RuleName
    )

    switch ($pscmdlet.ParameterSetName) {
        'FromPath' {
            $Path = $pscmdlet.GetUnresolvedProviderPathFromPSPath($Path)

            $ast = [System.Management.Automation.Language.Parser]::ParseInput(
                (Get-Content $Path -Raw),
                $Path,
                [Ref]$null,
                [Ref]$null
            )
        }
        'FromScriptBlock' {
            $ast = $ScriptBlock.Ast
        }
        'FromCommandName' {
            try {
                $command = Get-Command $CommandName -ErrorAction Stop
                if ($command.CommandType -notin 'ExternalScript', 'Function') {
                    throw [InvalidOperationException]::new('The command "{0}" is not a script or function.' -f $CommandName)
                }
                $ast = $command.ScriptBlock.Ast
            } catch {
                $pscmdlet.ThrowTerminatingError(
                    [System.Management.Automation.ErrorRecord]::new(
                        $_.Exception,
                        'InvalidCommand',
                        'OperationStopped',
                        $CommandName
                    )
                )
            }
        }
    }

    # Acquire the type to test
    try {
        $astType = (Get-Command $RuleName -ErrorAction Stop).Parameters['ast'].ParameterType
    } catch {
        $pscmdlet.ThrowTerminatingError(
            [System.Management.Automation.ErrorRecord]::new(
                [InvalidOperationException]::new('The name "{0}" is not a valid rule' -f $RuleName, $_.Exception),
                'InvalidRuleName',
                'OperationStopped',
                $RuleName
            )
        )
    }

    $predicate = [ScriptBlock]::Create(('param ( $ast ); $ast -is [{0}]' -f $astType.FullName))
    $ast.FindAll($predicate, $true) | & $RuleName
}

function Resolve-ParameterSet {
    <#
    .SYNOPSIS
        Resolve a set of parameter names to a parameter set.
    .DESCRIPTION
        Resolve-ParameterSet attempts to discover the parameter set used by a set of named parameters.
    .EXAMPLE
        Resolve-ParameterSet Invoke-Command -ParameterName ScriptBlock, NoNewScope

        Find the parameter set name Invoke-Command uses when ScriptBlock and NoNewScope are parameters.
    .EXAMPLE
        Resolve-ParameterSet Get-Process -ParameterName IncludeUserName

        Find the parameter set name Get-Process uses when the IncludeUserName parameter is defined.
    .EXAMPLE
        Resolve-ParameterSet Invoke-Command -ParameterName Session, ArgumentList

        Writes a non-terminating error noting that no parameter sets matched.
    .NOTES
        Change log:
            24/08/2017 - Chris Dent - Added help.
    #>

    [CmdletBinding()]
    param (
        # Attempt to resolve the parameter set for the specified command name.
        [Parameter(Mandatory = $true, Position = 1, ParameterSetName = 'FromCommandName')]
        [String]$CommandName,

        # Attempt to resolve the parameter set for the specified CommandInfo.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'FromCommandInfo')]
        [CommandInfo]$CommandInfo,

        # The parameter names which would be supplied.
        [AllowEmptyCollection()]
        [String[]]$ParameterName = @()
    )

    begin {
        if ($pscmdlet.ParameterSetName -eq 'FromCommandName') {
            Get-Command $CommandName | Resolve-ParameterSet -ParameterName $ParameterName
        }
    }

    process {
        if ($pscmdlet.ParameterSetName -eq 'FromCommandInfo') {
            try {
                $candidateSets = for ($i = 0; $i -lt $commandInfo.ParameterSets.Count; $i++) {
                    $parameterSet = $commandInfo.ParameterSets[$i]

                    Write-Debug ('Analyzing {0}' -f $parameterSet.Name)

                    $isCandidateSet = $true
                    foreach ($parameter in $parameterSet.Parameters) {
                        if ($parameter.IsMandatory -and -not ($ParameterName -contains $parameter.Name)) {
                            Write-Debug ('  Discarded {0}: Missing mandatory parameter {1}' -f $parameterSet.Name, $parameter.Name)

                            $isCandidateSet = $false
                            break
                        }
                    }
                    if ($isCandidateSet) {
                        foreach ($name in $ParameterName) {
                            if ($name -notin $parameterSet.Parameters.Name) {
                                Write-Debug ('  Discarded {0}: Parameter {1} is not within set' -f $parameterSet.Name, $parameter.Name)

                                $isCandidateSet = $false
                                break
                            }
                        }
                    }
                    if ($isCandidateSet) {
                        Write-Debug ('  Discovered candidate set {0} at index {1}' -f $parameterSet.Name, $i)

                        [PSCustomObject]@{
                            Name  = $parameterSet.Name
                            Index = $i
                        }
                    }
                }

                if (@($candidateSets).Count -eq 1) {
                    return $candidateSets.Name
                } elseif (@($candidateSets).Count -gt 1) {
                    foreach ($parameterSet in $candidateSets) {
                        if ($CommandInfo.ParameterSets[$parameterSet.Index].IsDefault) {
                            return $parameterSet.Name
                        }
                    }

                    $errorRecord = [ErrorRecord]::new(
                        [InvalidOperationException]::new(('{0}: Ambiguous parameter set: {1}' -f
                            $CommandInfo.Name,
                            ($candidateSets.Name -join ', ')
                        )),
                        'AmbiguousParameterSet',
                        'InvalidOperation',
                        $ParameterName
                    )
                    throw $errorRecord
                } else {
                    $errorRecord = [ErrorRecord]::new(
                        [InvalidOperationException]::new('{0}: Unable to match parameters to a parameter set' -f $CommandInfo.Name),
                        'CouldNotResolveParameterSet',
                        'InvalidOperation',
                        $ParameterName
                    )
                    throw $errorRecord
                }
            } catch {
                Write-Error -ErrorRecord $_
            }
        }
    }
}

filter PSAvoidEmptyNamedBlocks {
    <#
    .SYNOPSIS
        PSAvoidEmptyNamedBlocks
    .DESCRIPTION
        Functions and scripts should not contain empty begin, process, end, or dynamicparam declarations.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { process { } } -RuleName AvoidEmptyNamedBlocks

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [NamedBlockAst]$ast
    )

    if ($ast.Statements.Count -eq 0) {
        [DiagnosticRecord]@{
            Message  = 'Empty {0} block.' -f $ast.BlockKind
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}

filter PSAvoidNestedFunctions {
    <#
    .SYNOPSIS
        PSAvoidNestedFunctions
    .DESCRIPTION
        Functions should not contain nested functions.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { function outer { function inner { } } } -RuleName AvoidNestedFunctions

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [FunctionDefinitionAst]$ast
    )

    $ast.Body.FindAll( {
        param (
            $ast
        )

        $ast -is [FunctionDefinitionAst]
    }, $true ) | ForEach-Object {
        [DiagnosticRecord]@{
            Message  = 'The function {0} in {1} contains the nested function {2}.' -f $ast.Name, $ast.Extent.File, $_.name
            Extent   = $_.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}

filter PSAvoidProcessWithoutPipeline {
    <#
    .SYNOPSIS
        PSAvoidProcessWithoutPipeline
    .DESCRIPTION
        Functions and scripts should not declare process unless an input pipeline is supported.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { function name { process { } } } -RuleName AvoidProcessWithoutPipeline

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [ScriptBlockAst]$ast
    )

    if ($null -ne $ast.ProcessBlock -and $ast.ParamBlock) {
        $attributeAst = $ast.ParamBlock.Find( {
            param ( $ast )

            $ast -is [AttributeAst] -and
            $ast.TypeName.Name -eq 'Parameter' -and
            $ast.NamedArguments.Where{
                $_.ArgumentName -in 'ValueFromPipeline', 'ValueFromPipelineByPropertyName' -and
                $_.Argument.SafeGetValue() -eq $true
            }
        }, $false )

        if (-not $attributeAst) {
            [DiagnosticRecord]@{
                Message  = 'Process declared without an input pipeline'
                Extent   = $ast.ProcessBlock.Extent
                RuleName = $myinvocation.MyCommand.Name
                Severity = 'Warning'
            }
        }
    }
}

filter PSAvoidUsingAddType {
    <#
    .SYNOPSIS
        PSAvoidUsingAddType
    .DESCRIPTION
        Functions and scripts should not call Add-Type to load assemblies. Assemblies should be required in the module manifest.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { Add-Type -AssemblyName System.Web } -RuleName AvoidUsingAddType

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [CommandAst]$ast
    )

    if ($ast -is [CommandAst] -and
        $ast.GetCommandName() -eq 'Add-Type') {

        [DiagnosticRecord]@{
            Message  = 'Add-Type is used to load an assembly.'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}

filter PSAvoidUsingNewObjectToCreatePSObject {
    <#
    .SYNOPSIS
        PSAvoidUsingNewObjectToCreatePSObject
    .DESCRIPTION
        Functions and scripts should use [PSCustomObject] to create PSObject instances with named properties.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { New-Object PSObject -Property @{} } -RuleName AvoidUsingNewObjectToCreatePSObject

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [CommandAst]$ast
    )

    if ($ast -is [CommandAst] -and
        $ast.GetCommandName() -eq 'New-Object' -and
        $ast.CommandElements.Where{ $_.ParameterName -like 'Prop*' }) {

        [DiagnosticRecord]@{
            Message  = 'New-Object is used to create an object. [PSCustomObject] should be used instead.'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}

filter PSAvoidUsingThrow {
    <#
    .SYNOPSIS
        PSAvoidUsingThrow
    .DESCRIPTION
        Advanced functions and scripts should not use throw, except within a try / catch block. Throw is affected by ErrorAction.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { function name { [CmdletBinding()]param ( ); throw 'message' } } -RuleName AvoidUsingThrow

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [FunctionDefinitionAst]$ast
    )

    $isAdvanced = $null -ne $ast.Find( {
        param ( $ast )

        $ast -is [AttributeAst] -and
        $ast.TypeName.Name -in 'CmdletBinding', 'Parameter'
    }, $true )

    if (-not $isAdvanced) {
        return
    }

    [Array]$throwStatements = $ast.FindAll( {
        param ( $ast )

        $ast -is [ThrowStatementAst]
    }, $true )

    if (-not $throwStatements) {
        return
    }

    [Array]$tryStatements = $ast.FindAll( {
        param ( $ast )

        $ast -is [TryStatementAst]
    }, $true )

    foreach ($throwStatement in $throwStatements) {
        $isWithinExtentOfTry = $false

        foreach ($tryStatement in $tryStatements) {
            if ($throwStatement.Extent.StartOffset -gt $tryStatement.Extent.StartOffset -and
                    $throwStatement.Extent.EndOffset -lt $tryStatement.Extent.EndOffset) {

                $isWithinExtentOfTry = $true
            }
        }
        if (-not $isWithinExtentOfTry) {
            [DiagnosticRecord]@{
                Message  = 'throw is used to terminate a function outside of try in the function {0}.' -f $ast.name
                Extent   = $throwStatement.Extent
                RuleName = $myinvocation.MyCommand.Name
                Severity = 'Warning'
            }
        }
    }
}

filter PSAvoidWriteErrorStop {
    <#
    .SYNOPSIS
        PSAvoidWriteErrorStop
    .DESCRIPTION
        Functions and scripts should avoid using Write-Error Stop to terminate a running command or pipeline. The context of the thrown error is Write-Error.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { Write-Error 'message' -ErrorAction Stop } -RuleName AvoidWriteErrorStop

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [CommandAst]$ast
    )

    if ($ast.GetCommandName() -eq 'Write-Error') {
        $parameter = $ast.CommandElements.Where{ $_.ParameterName -like 'ErrorA*' -or $_.ParameterName -eq 'EA' }[0]
        if ($parameter) {
            $argumentIndex = $ast.CommandElements.IndexOf($parameter) + 1
            $argument = $ast.CommandElements[$argumentIndex].SafeGetValue()

            if ([Enum]::Parse([ActionPreference], $argument) -eq 'Stop') {
                [DiagnosticRecord]@{
                    Message  = 'Write-Error is used to create a terminating error. throw or $pscmdlet.ThrowTerminatingError should be used.'
                    Extent   = $ast.Extent
                    RuleName = $myinvocation.MyCommand.Name
                    Severity = 'Warning'
                }
            }
        }
    }
}

filter PSUseFilterForProcessBlockOnlyFunctions {
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [FunctionDefinitionAst]$ast
    )

    if ($ast.IsFilter -eq $false -and $null -eq $ast.Body.BeginBlock -and $null -eq $ast.Body.EndBlock) {
        $attributeAst = $ast.Body.ParamBlock.Find( {
            param ( $ast )

            $ast -is [AttributeAst] -and
            $ast.TypeName.Name -eq 'Parameter' -and
            $ast.NamedArguments.Where{
                $_.ArgumentName -in 'ValueFromPipeline', 'ValueFromPipelineByPropertyName' -and
                $_.Argument.SafeGetValue() -eq $true
            }
        }, $false )

        if ($attributeAst) {
            [DiagnosticRecord]@{
                Message  = 'Functions which accept pipeline input and only use a process block should be created using "filter"'
                Extent   = $ast.Extent
                RuleName = $myinvocation.MyCommand.Name
                Severity = 'Warning'
            }
        }
    }
}

filter PSUseSyntacticallyCorrectExamples {
    <#
    .SYNOPSIS
        PSUseSyntacticallyCorrectExamples
    .DESCRIPTION
        Examples should use parameters described by the function correctly.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock {
            function name {
                # .SYNOPSIS
                #   name
                # .DESCRIPTION
                #   description
                # .EXAMPLE
                #   name -param3 value

                [CmdletBinding()]
                param (
                    [String]$param1,

                    [String]$param2
                )
            }
        } -RuleName UseSyntacticallyCorrectExamples

        Execute the rule against a script block using Invoke-CodingConventionRule.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock {
            function name {
                # .SYNOPSIS
                #   name
                # .DESCRIPTION
                #   description
                # .EXAMPLE
                #   name -param1 value -param2 value

                [CmdletBinding()]
                param (
                    [Parameter(ParameterSetName = 'one')]
                    [String]$param1,

                    [Parameter(ParameterSetName = 'two')]
                    [String]$param2
                )
            }
        } -RuleName UseSyntacticallyCorrectExamples

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'hasTriggered')]
    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [FunctionDefinitionAst]$ast
    )

    $definition = [ScriptBlock]::Create($ast.Extent.ToString())
    $functionInfo = Get-FunctionInfo -ScriptBlock $definition

    if ($functionInfo.CmdletBinding) {
        $helpContent = $ast.GetHelpContent()

        for ($i = 0; $i -lt $helpContent.Examples.Count; $i++) {
            $example = $helpContent.Examples[$i]
            $exampleNumber = $i + 1

            $exampleAst = [Parser]::ParseInput(
                $example,
                [Ref]$null,
                [Ref]$null
            )

            $exampleAst.FindAll( {
                param ( $ast )

                $ast -is [CommandAst]
            }, $false ) | Where-Object {
                $_.GetCommandName() -eq $ast.Name
            } | ForEach-Object {
                $hasTriggered = $false

                # Non-existant parameters
                $_.CommandElements | Where-Object {
                    $_ -is [CommandParameterAst] -and $_.ParameterName -notin $functionInfo.Parameters.Keys
                } | ForEach-Object {
                    $hasTriggered = $true

                    [DiagnosticRecord]@{
                        Message  = 'Example {0} in function {1} uses invalid parameter {2}.' -f
                            $exampleNumber,
                            $ast.Name,
                            $_.ParameterName
                        Extent   = $ast.Extent
                        RuleName = $myinvocation.MyCommand.Name
                        Severity = 'Warning'
                    }
                }

                # Only trigger this test if the command includes valid parameters.
                if (-not $hasTriggered) {
                    # Ambiguous parameter set use
                    try {
                        $parameterName = $_.CommandElements | Where-Object { $_ -is [CommandParameterAst] } | ForEach-Object { $_.ParameterName }
                        $null = Resolve-ParameterSet -CommandInfo $functionInfo -ParameterName $parameterName -ErrorAction Stop
                    } catch {
                        Write-Debug $_.Exception.Message

                        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
                            Message  = 'Unable to determine parameter set used by example {0} for the function {1}' -f
                                $exampleNumber,
                                $ast.Name
                            Extent   = $ast.Extent
                            RuleName = $myinvocation.MyCommand.Name
                            Severity = 'Warning'
                        }
                    }
                }
            }
        }
    }
}