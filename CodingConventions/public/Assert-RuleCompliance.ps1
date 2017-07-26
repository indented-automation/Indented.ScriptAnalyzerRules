function Assert-RuleCompliance {
    <#
    Experimental, not ready.
    #>

    param (
        # The name of a compliance rule.
        [String]$RuleName
    )

    Assert-DescribeInProgress -CommandName $myinvocation.MyCommand.Name

    Invoke-CodingConventionRule -CommandName -RuleName $RuleName
}