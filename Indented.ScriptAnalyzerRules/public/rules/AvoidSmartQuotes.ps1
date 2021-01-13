using namespace Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic
using namespace System.Management.Automation.Language

function AvoidSmartQuotes {
    <#
    .SYNOPSIS
        AvoidSmartQuotes

    .DESCRIPTION
        Avoid smart quotes.
    #>

    [CmdletBinding()]
    [OutputType([Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord])]
    param (
        [StringConstantExpressionAst]$ast
    )

    $normalQuotes = @(
        "'"
        '"'
    )

    if ($ast.StringConstantType -in 'DoubleQuotedHereString', 'SingleQuotedHereString') {
        $startQuote, $endQuote = $ast.Extent.Text[1, -2]
    } else {
        $startQuote, $endQuote = $ast.Extent.Text[0, -1]
    }

    if ($startQuote -notin $normalQuotes -or $endQuote -notin $normalQuotes) {
        [DiagnosticRecord]@{
            Message  = 'Avoid smart quotes, always use " or ''.'
            Extent   = $ast.Extent
            RuleName = $myinvocation.MyCommand.Name
            Severity = 'Warning'
        }
    }
}
