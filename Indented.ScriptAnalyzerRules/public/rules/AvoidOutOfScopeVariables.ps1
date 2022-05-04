using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language
using namespace System.Collections.Generic

function AvoidOutOfScopeVariables {
    <#
    .SYNOPSIS
        AvoidOutOfScopeVariables

    .DESCRIPTION
        Functions should not use out of scope variables unless a scope modifier is explicitly used to indicate source scope.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [FunctionDefinitionAst]$ast
    )

    # Special variables:
    # [PowerShell].Assembly.GetType('System.Management.Automation.SpecialVariables').GetFields('Static,NonPublic') |
    #    Where-Object FieldType -eq ([string]) |
    #    ForEach-Object GetValue($null)
    $specialVariables = [HashSet[string]]::new([IEqualityComparer[string]][StringComparer]::OrginalIgnoreCase)
    $whitelist = @(
        '_'
        '?'
        '^'
        '$'
        'args'
        'ConfirmPreference'
        'CurrentlyExecutingCommand'
        'DebugPreference'
        'EnabledExperimentalFeatures'
        'env:PATHEXT'
        'error'
        'ErrorActionPreference'
        'ErrorView'
        'ExecutionContext'
        'false'
        'foreach'
        'HOME'
        'Host'
        'InformationPreference'
        'input'
        'IsCoreCLR'
        'IsLinux'
        'IsMacOS'
        'IsWindows'
        'LASTEXITCODE'
        'LogCommandHealthEvent'
        'LogCommandLifecycleEvent'
        'LogEngineHealthEvent'
        'LogEngineLifecycleEvent'
        'LogProviderHealthEvent'
        'LogProviderLifecycleEvent'
        'LogSettingsEvent'
        'Matches'
        'MaximumHistoryCount'
        'MyInvocation'
        'NestedPromptLevel'
        'null'
        'OFS'
        'OutputEncoding'
        'PID'
        'ProgressPreference'
        'PSBoundParameters'
        'PSCmdlet'
        'PSCommandPath'
        'PSCulture'
        'PSDebugContext'
        'PSDefaultParameterValues'
        'PSEdition'
        'PSEmailServer'
        'PSHOME'
        'PSItem'
        'PSLogUserData'
        'PSModuleAutoLoadingPreference'
        'PSNativeCommandArgumentPassing'
        'PSScriptRoot'
        'PSSenderInfo'
        'PSSessionApplicationName'
        'PSSessionConfigurationName'
        'PSStyle'
        'PSUICulture'
        'PSVersionTable'
        'PWD'
        'ShellId'
        'StackTrace'
        'switch'
        'this'
        'true'
        'VerboseHelpErrors'
        'VerbosePreference'
        'WarningPreference'
        'WhatIfPreference'
    )
    foreach ($name in $whitelist) {
        $null = $specialVariables.Add($name)
    }

    $declaredVariables = [HashSet[string]]::new([IEqualityComparer[string]][StringComparer]::OrginalIgnoreCase)
    $ast.Body.FindAll(
        {
            param (
                $ast
            )

            $ast -is [AssignmentStatementAst] -and
            $ast.Left.VariablePath.IsUnqualified
        },
        $true
    ) | ForEach-Object {
        $null = $declaredVariables.Add($_.Left.VariablePath.UserPath)
    }

    $ast.Body.FindAll(
        {
            param (
                $ast
            )

            $ast -is [VariableExpressionAst] -and
            $ast.VariablePath.IsUnqualified -and
            $ast.Parent -isnot [ForEachStatementAst] -and
            -not $declaredVariables.Contains($ast.VariablePath.UserPath) -and
            -not $specialVariables.Contains($ast.VariablePath.UserPath)
        },
        $true
    ) | ForEach-Object {
        [DiagnosticRecord]@{
            Message  = 'The function {0} contains an out of scope variable: ${1}' -f $ast.Name, $_.VariablePath.UserPath
            Extent   = $_.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}
