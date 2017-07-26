filter AvoidWriteErrorStop {
    <#
    .SYNOPSIS
        AvoidWriteErrorStop
    .DESCRIPTION
        Functions and scripts should avoid using Write-Error Stop to terminate a running command or pipeline. The context of the thrown error is Write-Error.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [System.Management.Automation.Language.CommandAst]
        $ast
    )

    $isErrorActionStopUsed = if ($ast.GetCommandName() -eq 'Write-Error') {
        $parameter = $ast.CommandElements.Where{ $_.ParameterName -like 'ErrorA*' -or $_.ParameterName -eq 'EA' }[0]
        if ($parameter) {
            $argumentIndex = $ast.CommandElements.IndexOf($parameter) + 1
            $argument = $ast.CommandElements[$argumentIndex].SafeGetValue()
            
            [Enum]::Parse([System.Management.Automation.ActionPreference], $argument) -eq 'Stop'
        }
    }

    if ($isErrorActionStopUsed) {
        [Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord]@{
            Message  = 'Write-Error is used to create a terminating error. throw or $pscmdlet.ThrowTerminatingError should be used.'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}