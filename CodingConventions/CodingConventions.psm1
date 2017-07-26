$public = 'AvoidEmptyNamedBlocks',
          'AvoidNestedFunctions',
          'AvoidProcessWithoutPipeline',
          'AvoidUsingAddType',
          'AvoidUsingNewObjectToCreatePSObject',
          'AvoidUsingThrow',
          'AvoidWriteErrorStop',
          'Invoke-CodingConventionRule'

foreach ($name in $public) {
    . "$psscriptroot\public\$name.ps1"
}