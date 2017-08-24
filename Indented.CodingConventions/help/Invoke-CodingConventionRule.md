---
external help file: Indented.CodingConventions-help.xml
online version: 
schema: 2.0.0
---

# Invoke-CodingConventionRule

## SYNOPSIS
Invoke a specific coding convention rule.

## SYNTAX

### FromPath (Default)
```
Invoke-CodingConventionRule -Path <String> [-RuleName] <String>
```

### FromScriptBlock
```
Invoke-CodingConventionRule -ScriptBlock <ScriptBlock> [-RuleName] <String>
```

### FromCommandName
```
Invoke-CodingConventionRule -CommandName <String> [-RuleName] <String>
```

## DESCRIPTION
Invoke a specific coding convention rule against a defined file, script block, or command name.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Invoke-CodingConventionRule -Path C:\Script.ps1 -RuleName AvoidNestedFunctions
```

Invoke the rule AvoidNestedFunctions against the script in the specified path.

## PARAMETERS

### -Path
{{Fill Path Description}}

```yaml
Type: String
Parameter Sets: FromPath
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptBlock
{{Fill ScriptBlock Description}}

```yaml
Type: ScriptBlock
Parameter Sets: FromScriptBlock
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CommandName
{{Fill CommandName Description}}

```yaml
Type: String
Parameter Sets: FromCommandName
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RuleName
{{Fill RuleName Description}}

```yaml
Type: String
Parameter Sets: (All)
Aliases: 

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

### Microsoft.Windows.PowerShell.ScriptAnalyzer.Generic.DiagnosticRecord

## NOTES
Change log:
    26/07/2017 - Chris Dent - Created.

## RELATED LINKS

