param($KTARole, $InstallerPath="C:\KTA")
# Check if SilentConfig exists for the KTA role requested
if(Test-Path -path "$InstallerPath\SillentConfigs\SilentInstallConfig_$KTARole.xml") 
{
	# Copying Silent Config to TotalAgilityInstall folder
	Copy-Item "$InstallerPath\SillentConfigs\SilentInstallConfig_$KTARole.xml" "$InstallerPath\TotalAgilityInstall\SilentInstallConfig.xml"
	
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Success: Silent Config copied" | timestamp
}
else
{
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Error: SilientConfig not found" | timestamp
}

# Check if FixPack SilentConfig exists for the KTA role requested
if(Test-Path -path "$InstallerPath\KTA-Fixpack\TotalAgilityInstall\SilentInstallConfig.xml") 
{
	# Copying Silent Config to TotalAgilityInstall folder
	Copy-Item "$InstallerPath\SillentConfigs\SilentInstallConfig_$KTARole.xml" "$InstallerPath\KTA-Fixpack\TotalAgilityInstall\SilentInstallConfig.xml"
	
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Success: FixPack Silent Config copied" | timestamp
}
else
{
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Error: FixPack SilientConfig not found" | timestamp
}