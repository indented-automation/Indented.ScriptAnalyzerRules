function Invoke-CodingConventionRule {
    [CmdletBinding(DefaultParameterSetName = 'FromPath')]
    param (
        [Parameter(Mandatory = $true, ParameterSetName = 'FromPath')]
        [String]$Path,

        [Parameter(Mandatory = $true, ParameterSetName = 'FromScriptBlock')]
        [ScriptBlock]$ScriptBlock,

        [Parameter(Mandatory = $true, Position = 2)]
        [String]$TestName
    )

    if ($pscmdlet.ParameterSetName -eq 'FromPath') {
        $Path = $pscmdlet.GetUnresolvedProviderPathFromPSPath($Path)

        $ast = [System.Management.Automation.Language.Parser]::ParseInput(
            (Get-Content $Path -Raw),
            $Path,
            [Ref]$null,
            [Ref]$null
        )
    } else {
        $ast = $ScriptBlock.Ast
    }

    # Acquire the type to test
    $astType = (Get-Command $TestName).Parameters['ast'].ParameterType
    $predicate = [ScriptBlock]::Create(('param ( $ast ); $ast -is [{0}]' -f $astType.FullName))

    $ast.FindAll(
        $predicate,
        $true
    ) | & $TestName
}