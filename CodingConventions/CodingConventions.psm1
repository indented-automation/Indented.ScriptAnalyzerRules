$public = 'Get-FunctionInfo',
          'Invoke-CodingConventionRule',
          'Resolve-ParameterSet',
          'AvoidEmptyNamedBlocks',
          'AvoidNestedFunctions',
          'AvoidProcessWithoutPipeline',
          'AvoidUsingAddType',
          'AvoidUsingNewObjectToCreatePSObject',
          'AvoidUsingThrow',
          'AvoidWriteErrorStop',
          'UseSyntacticallyCorrectExamples'

foreach ($name in $public) {
    . "$psscriptroot\public\$name.ps1"
}