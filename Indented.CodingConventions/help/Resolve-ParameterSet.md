---
external help file: Indented.CodingConventions-help.xml
online version: 
schema: 2.0.0
---

# Resolve-ParameterSet

## SYNOPSIS
Resolve a set of parameter names to a parameter set.

## SYNTAX

### FromCommandName
```
Resolve-ParameterSet [-CommandName] <String> [-ParameterName <String[]>]
```

### FromCommandInfo
```
Resolve-ParameterSet -CommandInfo <CommandInfo> [-ParameterName <String[]>]
```

## DESCRIPTION
Resolve-ParameterSet attempts to discover the parameter set used by a set of named parameters.

## EXAMPLES

### -------------------------- EXAMPLE 1 --------------------------
```
Resolve-ParameterSet Invoke-Command -ParameterName ScriptBlock, NoNewScope
```

Find the parameter set name Invoke-Command uses when ScriptBlock and NoNewScope are parameters.

### -------------------------- EXAMPLE 2 --------------------------
```
Resolve-ParameterSet Get-Process -ParameterName IncludeUserName
```

Find the parameter set name Get-Process uses when the IncludeUserName parameter is defined.

### -------------------------- EXAMPLE 3 --------------------------
```
Resolve-ParameterSet Invoke-Command -ParameterName Session, ArgumentList
```

Writes a non-terminating error noting that no parameter sets matched.

## PARAMETERS

### -CommandName
Attempt to resolve the parameter set for the specified command name.

```yaml
Type: String
Parameter Sets: FromCommandName
Aliases: 

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CommandInfo
Attempt to resolve the parameter set for the specified CommandInfo.

```yaml
Type: CommandInfo
Parameter Sets: FromCommandInfo
Aliases: 

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ParameterName
The parameter names which would be supplied.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases: 

Required: False
Position: Named
Default value: @()
Accept pipeline input: False
Accept wildcard characters: False
```

## INPUTS

## OUTPUTS

## NOTES
Change log:
    24/08/2017 - Chris Dent - Added help.

## RELATED LINKS

