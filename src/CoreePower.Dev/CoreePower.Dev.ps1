
<#
.SYNOPSIS
Generates a new GUID (Globally Unique Identifier) and returns it as a string.

.EXAMPLE
The following example assigns the generated GUID to a variable named $newGuid:
$newGuid = Generate-GuidAsString

.NOTES
This function has an alias "ggas" for ease of use.
#>

function GenerateGuidAsString {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("ggas")]
    param()
    $guid = New-Guid
    $guidString = $guid.ToString()
    return $guidString
}





# Modify user or machine settings based on the desired scope
function ChangeSomethingScoped {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    param(
        [Parameter(Position = 0)]
        [Scope]$Scope = [Scope]::CurrentUser
    )

    # Check if the current process can execute in the desired scope
    if (-not(CanExecuteInDesiredScope -Scope $Scope))
    {
        return
    }

    if ($Scope -eq [Scope]::CurrentUser)
    {
        # Modify user settings
        Write-Output "Modifying user settings..."
    }
    elseif ($Scope -eq [Scope]::LocalMachine) {
        # Modify machine settings
        Write-Output "Modifying machine settings..."
    }
}

function ExportPowerShellCustomObject {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("expsco")]
    param (
        [Parameter(Mandatory=$true)]
        $InputObject,
        [int]$IndentLevel = 0,
        [array]$CustomOrder = @()
    )

    $Indent = " " * (4 * $IndentLevel)

    if ($InputObject -is [PSCustomObject]) {
        $Properties = $InputObject | Get-Member -MemberType NoteProperty
    } elseif ($InputObject -is [hashtable]) {
        $Properties = $InputObject.Keys | ForEach-Object { [PSCustomObject]@{ Name = $_ } }
    } else {
        return
    }
    
    $Properties = $Properties | Sort-Object { if ($CustomOrder -notcontains $_.Name) { [int]::MaxValue } else { [array]::IndexOf($CustomOrder, $_.Name) } }, Name

    $Output = @()
    foreach ($Property in $Properties) {
        $PropertyName = $Property.Name
        $PropertyValue = $InputObject.$PropertyName

        if ($PropertyValue -is [string]) {
            $Output += "${Indent}$PropertyName = '$PropertyValue'"
        } elseif ($PropertyValue -is [array]) {
            $ArrayOutput = @()
            foreach ($Item in $PropertyValue) {
                if ($Item -is [string]) {
                    $ArrayOutput += "'$Item'"
                } else {
                    $ArrayOutput += "@{" + (ExportPowerShellCustomObject -InputObject $Item -IndentLevel ($IndentLevel + 1) -CustomOrder $CustomOrder) + "}"
                }
            }
            $Output += "${Indent}$PropertyName = @(" + (($ArrayOutput) -join ", ") + ")"
        } elseif ($PropertyValue -is [PSCustomObject] -or $PropertyValue -is [hashtable]) {
            $NestedProperties = (ExportPowerShellCustomObject -InputObject $PropertyValue -IndentLevel ($IndentLevel + 1) -CustomOrder $CustomOrder) -split "`n"
            $Output += "${Indent}$PropertyName = @{"
            $Output += $NestedProperties -join "`n"
            $Output += "${Indent}}"
        } else {
            $Output += "${Indent}$PropertyName = $PropertyValue"
        }
    }

    $Output -join "`n"
}

function ExportPowerShellCustomObjectWrapper {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("expscow")]
    param (
        [Parameter(Mandatory=$true)]
        $InputObject,
        [int]$IndentLevel = 0,
        [array]$CustomOrder = @(),
        [string]$Prefix = "",
        [string]$Suffix = ""
    )

    $Output = ""
    $Properties = ExportPowerShellCustomObject -InputObject $InputObject -IndentLevel $IndentLevel -CustomOrder $CustomOrder
    if ($Properties) {
        $Output += $Prefix + "`n"
        $Output += $Properties -join "`n"
        $Output += "`n" + $Suffix
    }
    return $Output
}



function ExportPowerShellCustomObject2 {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("expsco2")]
    param (
        [Parameter(Mandatory=$true)]
        $InputObject,
        [int]$IndentLevel = 0,
        [array]$CustomOrder = @()
    )

    $Indent = " " * (4 * $IndentLevel)

    if ($InputObject -is [PSCustomObject]) {
        $Properties = $InputObject | Get-Member -MemberType NoteProperty
    } elseif ($InputObject -is [hashtable]) {
        $Properties = $InputObject.Keys | ForEach-Object { [PSCustomObject]@{ Name = $_ } }
    } else {
        return
    }
    
    $Properties = $Properties | Sort-Object { if ($CustomOrder -notcontains $_.Name) { [int]::MaxValue } else { [array]::IndexOf($CustomOrder, $_.Name) } }, Name

    $Output = @()
    foreach ($Property in $Properties) {
        $PropertyName = $Property.Name
        $PropertyValue = $InputObject.$PropertyName

        if ($PropertyValue -is [string]) {

            # Define the regular expression pattern to match
            $pattern = "^[a-zA-Z0-9_]*$"

            # Use the -match operator to check if the string matches the pattern
            if ($PropertyName -match $pattern) {
                $Output += "${Indent}$PropertyName = '$PropertyValue'"
            } else {
                $Output += "${Indent}`"$PropertyName`" = '$PropertyValue'"
            }
        } elseif ($PropertyValue -is [array]) {
            $ArrayOutput = @()
            foreach ($Item in $PropertyValue) {
                if ($Item -is [string]) {
                    $ArrayOutput += "'$Item'"
                } else {
                    $ArrayOutput += "@{ " + (ExportPowerShellCustomObject2 -InputObject $Item -IndentLevel ($IndentLevel + 1) -CustomOrder $CustomOrder) + "}"
                }
            }
            $Output += "${Indent}$PropertyName = @(" + (($ArrayOutput) -join ", ") + ")"
        } elseif ($PropertyValue -is [PSCustomObject] -or $PropertyValue -is [hashtable]) {
            $NestedProperties = (ExportPowerShellCustomObject2 -InputObject $PropertyValue -IndentLevel ($IndentLevel + 1) -CustomOrder $CustomOrder) -split "`n"
            $Output += "${Indent}$PropertyName = @{ "
            $Output += $NestedProperties -join "`n"
            $Output += "${Indent}}"
        } else {
            $Output += "${Indent}$PropertyName = $PropertyValue"
        }
    }

    $Output -join "`n"
}

function ExportPowerShellCustomObjectWrapper2 {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "")]
    [alias("expscow2")]
    param (
        [Parameter(Mandatory=$true)]
        $InputObject,
        [int]$IndentLevel = 0,
        [array]$CustomOrder = @(),
        [string]$Prefix = "",
        [string]$Suffix = ""
    )

    $Output = ""
    $Properties = ExportPowerShellCustomObject2 -InputObject $InputObject -IndentLevel $IndentLevel -CustomOrder $CustomOrder
    if ($Properties) {
        $Output += $Prefix + "`n"
        $Output += $Properties -join "`n"
        $Output += "`n" + $Suffix
    }
    return $Output
}


