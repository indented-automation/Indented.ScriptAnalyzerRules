function Assert-RuleCompliance {
    <#
    Experimental, not ready.
    #>

    param (
        [String]$RuleName
    )

    Assert-DescribeInProgress -CommandName $myinvocation.MyCommand.Name

    Invoke-CodingConventionRule -CommandName -RuleName $RuleName
}