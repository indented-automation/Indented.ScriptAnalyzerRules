$public = 'AvoidNestedFunctions',
          'AvoidUsingAddType',
          'AvoidUsingNewObjectToCreatePSObject',
          'AvoidUsingThrow',
          'Invoke-CodingConventionRule'

foreach ($name in $public) {
    . "$psscriptroot\public\$name.ps1"
}