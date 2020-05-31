<#
.SYNOPSIS
The scripts hides the Workspace ONE Intelligent Hub Installer.
.DESCRIPTION
The scripts hides the Workspace ONE Intelligent Hub Installer, preventing an admin from removing it using Control Panel or Apps and Features in Windows 10.
.EXAMPLE
Hide-Installer.ps1 
Running the script without any parameter will remove the unistall REG key without any output.
.EXAMPLE
Hide-Installer.ps1 -debug
Running the script unsing -debug parameter will provide debug output useful for troubleshooting.
#>

#region Author
#Federico Lillacci - https://github.com/tsmagnum
#version 1.0
#endregion

[cmdletbinding()]
Param()

#Finding WS1 installer info
if ($targetInstaller = Get-WmiObject -class Win32_Product | Where-Object {$_.Name -eq "Workspace ONE Intelligent Hub Installer"})
{
$identifier = $targetInstaller.IdentifyingNumber.ToString()
Write-Debug "The installer identifier is $identifier"

#Checking if OS is x86
if(!([Environment]::Is64BitOperatingSystem))
{
    Write-Debug "OS x86, Removing Uninstall Key for $identifier"
    Remove-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$identifier
}

#If it is x64
else 
{
    if (Test-Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$identifier)
    {
        Write-Debug "OS x64, Removing Uninstall Key for $identifier"
        Remove-Item HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$identifier
    }

    else 
    {
        Write-Debug "OS x64, Removing Uninstall Key for $identifier"
        Remove-Item HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$identifier
    }

}
}
