
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


function Get-CommandLine {
    $signature = @'
        [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
        public static extern IntPtr GetCommandLineW();
'@

    $kernel32 = Add-Type -MemberDefinition $signature -Name 'Kernel32' -Namespace 'Win32' -PassThru
    $commandLinePtr = $kernel32::GetCommandLineW()
    $commandLine = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($commandLinePtr)
    return $commandLine
}

function Split-CommandLineArgs($commandLine) {
    $signaturex = @"
        [DllImport("shell32.dll", SetLastError=true, CharSet=CharSet.Unicode)]
        public static extern IntPtr CommandLineToArgvW(
            [MarshalAs(UnmanagedType.LPWStr)] string lpCmdLine,
            out int pNumArgs
        );
"@

    $shell32 = Add-Type -MemberDefinition $signaturex -Name 'CommandLine' -Namespace 'Win32' -PassThru
    $numArgs = 0
    $argsPtr = $shell32::CommandLineToArgvW($commandLine, [Ref]$numArgs)
    $args = @()

    for ($i = 0; $i -lt $numArgs; $i++) {
        $argPtr = [System.IntPtr]::Add($argsPtr, $i * [System.IntPtr]::Size)
        $arg = [System.Runtime.InteropServices.Marshal]::ReadIntPtr($argPtr)
        $argStr = [System.Runtime.InteropServices.Marshal]::PtrToStringUni($arg)
        $args += $argStr
    }

    return $args
}

function Get-DotNetFrameworkVersions {
    $versions = @{
        533320 = '4.8.1 or later'
        528040 = '4.8'
        461808 = '4.7.2'
        461308 = '4.7.1'
        460798 = '4.7'
        394802 = '4.6.2'
        394254 = '4.6.1'
        393295 = '4.6'
        379893 = '4.5.2'
        378675 = '4.5.1'
        378389 = '4.5'
    }

    $release = Get-ItemPropertyValue -LiteralPath 'HKLM:SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full' -Name Release

    foreach ($version in $versions.GetEnumerator() | Sort-Object Key) {
        if ($release -ge $version.Key) {
            Write-Output ".NET Framework Version: $($version.Value)"
        }
    }
}

function Get-DotNetFrameworkVersions2 {
    $versions = @()

    Get-ChildItem -Path 'HKLM:\SOFTWARE\Microsoft\NET Framework Setup\NDP' |
    Where-Object { ($_.PSChildName -ne "v4") -and ($_.PSChildName -like 'v*') } |
    ForEach-Object {
        $name = $_.Version
        $sp = $_.SP
        $install = $_.Install
        $majorVersion = $_.PSChildName
        if ($install -eq '1') {
            $versions += [PSCustomObject]@{
                MajorVersionName = $majorVersion
                Version = $name
                ServicePack = $sp
                SubVersion = $null
            }
        }

        if (-not $name) {
            $parentName = $_.PSChildName
            Get-ChildItem -LiteralPath $_.PSPath |
            Where-Object {
                if ($_.Property -contains 'Version') { $name = Get-ItemPropertyValue -Path $_.PSPath -Name Version }
                if ($name -and ($_.Property -contains 'SP')) { $sp = Get-ItemPropertyValue -Path $_.PSPath -Name SP }
                if ($_.Property -contains 'Install') { $install = Get-ItemPropertyValue -Path $_.PSPath -Name Install }
                if ($install -eq '1') {
                    $versions += [PSCustomObject]@{
                        MajorVersionName = $parentName
                        Version = $name
                        ServicePack = $sp
                        SubVersion = $_.PSChildName
                    }
                }
            }
        }
    }
    return $versions
}

function Get-DotnetRuntimes3 {
    # Get the list of .NET Core and .NET 5+ runtimes
    $dotnetRuntimes = (dotnet --list-runtimes) -split "`n"

    # Initialize an array to hold the runtime information
    $runtimes = @()

    foreach ($runtime in $dotnetRuntimes) {
        # Split each line of output into the runtime name, version, and installation path
        $parts = $runtime -split ' '

        # Convert the runtime name to the more common format
        $name = switch -Wildcard ($parts[0]) {
            'Microsoft.NETCore.App*' { 
                if([Version]::Parse($parts[1]).Major -ge 5) { 'dotnet' } else { 'netcore' }
            }
            'Microsoft.AspNetCore.App*' { 'aspnetcore' }
            'Microsoft.WindowsDesktop.App*' { 'windowsdesktop' }
            default { $parts[0] }
        }

        # Create a custom object for the runtime
        $runtimeObj = New-Object -TypeName PSObject
        $runtimeObj | Add-Member -MemberType NoteProperty -Name 'Name' -Value $name
        $runtimeObj | Add-Member -MemberType NoteProperty -Name 'OriginalName' -Value $parts[0]
        $runtimeObj | Add-Member -MemberType NoteProperty -Name 'Version' -Value $parts[1]
        $runtimeObj | Add-Member -MemberType NoteProperty -Name 'Path' -Value ($parts[2..($parts.Count - 1)] -join ' ')

        # Add the runtime to the array
        $runtimes += $runtimeObj
    }

    # Print out the runtimes
    foreach ($runtime in $runtimes) {
        Write-Host ("{0} {1} {2}" -f $runtime.Name, $runtime.Version, $runtime.Path)
    }

    # Return the array of runtimes
    return $runtimes
}

function Get-HighestDotnetRuntimes {
    $dotnetRuntimes = Get-DotnetRuntimes3

    $groupedRuntimes = $dotnetRuntimes | Group-Object -Property MajorVersionName

    $highestRuntimes = foreach ($group in $groupedRuntimes) {
        $group.Group | Sort-Object -Property Version -Descending | Select-Object -First 1
    }

    return $highestRuntimes
}


function Recursive-Copy {
    param (
        [string]$Source,       # The source directory to copy from
        [string]$Destination   # The destination directory to copy to
    )

    # Create the destination directory, if it doesn't exist
    New-Item -ItemType Directory -Path $Destination -Force | Out-Null

    # Get all items in the source directory recursively
    $items = Get-ChildItem $Source -Recurse
    for ($i = 0; $i -lt $items.Count; $i++) {
        $sourceItem = $items[$i]

        # Replace the source path with the destination in the target path
        $targetPath = $sourceItem.FullName -replace [regex]::Escape($Source), $Destination

        if (Test-Path -Path $targetPath)
        {
            $targetItem = Get-Item $targetPath
        }

        # Check if the current sourceItem is a directory
        if ($sourceItem.PSIsContainer) {
            # If it is, create the same directory structure in the destination
            New-Item -ItemType Directory -Path $targetPath -Force | Out-Null
        } else {

            $overwrite = $true

            if (Test-Path -Path $targetPath -PathType Leaf)
            {
                # If it's a file, copy it to the destination
                if ($sourceItem.Extension -eq ".dll" -or $sourceItem.Extension -eq ".exe" -or $sourceItem.Extension -eq ".sys" )
                {
                    $sourceVersion = (Get-Command "$($sourceItem.FullName)")
                    $destVersion =  (Get-Command "$($targetPath)")

                    if (($sourceItem.Length -eq $targetItem.Length) -and ($sourceItem.Length -eq $targetItem.Length))
                    {
                        if ($sourceVersion.FileVersionInfo.FileVersion -eq $destVersion.FileVersionInfo.FileVersion)
                        {
                            if ($sourceVersion.FileVersionInfo.ProductVersion -eq $destVersion.FileVersionInfo.ProductVersion)
                            {
                                $overwrite = $false
                            }
                        }

                    }
                }
                elseif ($sourceItem.Extension -eq ".ico")
                {
                  if (($sourceItem.Length -eq $targetItem.Length) -and ($sourceItem.Length -eq $targetItem.Length))
                    {
                        if ($sourceItem.LastWriteTimeUtc -eq $targetItem.LastWriteTimeUtc)
                        {
                                $overwrite = $false
                        }

                    }
                }
            }

            if ($overwrite)
            {
                Write-Host "Copying"
                Write-Host "$($sourceItem.FullName)"
                Write-Host "$targetPath"       
                Copy-Item $sourceItem.FullName -Destination $targetPath -Force | Out-Null
            }
            else {
                Write-Host "Skipping"
                Write-Host "$($sourceItem.FullName)"
            }
            Write-Host ""
            
        }
    }
}




$commandLine = Get-CommandLine
$args = Split-CommandLineArgs $commandLine
Write-Host "Number of arguments: $($args.Count)"
Write-Host "Command line arguments:"
Write-Host $args