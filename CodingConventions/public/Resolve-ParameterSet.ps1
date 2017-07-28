using namespace System.Management.Automation

function Resolve-ParameterSet {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [CommandInfo]$CommandInfo,

        [String[]]$ParameterName
    )

    try {
        $candidateSets = for ($i = 0; $i -lt $commandInfo.ParameterSets.Count; $i++) {
            $parameterSet = $commandInfo.ParameterSets[$i]
            $isCandidateSet = $true
            foreach ($parameter in $parameterSet.Parameters) {
                if ($parameter.IsMandatory -and -not ($ParameterName -contains $parameter.Name)) {
                    $isCandidateSet = $false
                    break
                }
            }
            foreach ($name in $ParameterName) {
                if ($name -notin $parameterSet.Parameters.Name) {
                    $isCandidateSet = $false
                    break
                }
            }
            if ($isCandidateSet) {
                [PSCustomObject]@{
                    Name  = $parameterSet.Name
                    Index = $i
                }
            }
        }
        if (@($candidateSets).Count -eq 1) {
            return $candidateSets.Name
        } elseif (@($candidateSets).Count -gt 0) {
            foreach ($parameterSet in $candidateSets) {
                if ($commandInfo.ParameterSets[$parameterSet.Index].IsDefault) {
                    return $parameterSet.Name
                }
            }
        } else {
            throw 'Failed to find parameter set'
        }
    } catch {
        throw
    }
}