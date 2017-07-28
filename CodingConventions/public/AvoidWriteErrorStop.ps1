using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language
using namespace System.Management.Automation

filter AvoidWriteErrorStop {
    <#
    .SYNOPSIS
        AvoidWriteErrorStop
    .DESCRIPTION
        Functions and scripts should avoid using Write-Error Stop to terminate a running command or pipeline. The context of the thrown error is Write-Error.
    .EXAMPLE
        Invoke-CodingConventionRule -ScriptBlock { Write-Error 'message' -ErrorAction Stop } -RuleName AvoidWriteErrorStop

        Execute the rule against a script block using Invoke-CodingConventionRule.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord[]])]
    param (
        # An AST node.
        [Parameter(ValueFromPipeline = $true)]
        [CommandAst]
        $ast
    )

    $isErrorActionStopUsed = if ($ast.GetCommandName() -eq 'Write-Error') {
        $parameter = $ast.CommandElements.Where{ $_.ParameterName -like 'ErrorA*' -or $_.ParameterName -eq 'EA' }[0]
        if ($parameter) {
            $argumentIndex = $ast.CommandElements.IndexOf($parameter) + 1
            $argument = $ast.CommandElements[$argumentIndex].SafeGetValue()
            
            [Enum]::Parse([ActionPreference], $argument) -eq 'Stop'
        }
    }

    if ($isErrorActionStopUsed) {
        [DiagnosticRecord]@{
            Message  = 'Write-Error is used to create a terminating error. throw or $pscmdlet.ThrowTerminatingError should be used.'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}