param($KTARole)
# Check if SilentConfig exists for the KTA role requested
if(Test-Path -path "C:\KTA\SillentConfigs\SilentInstallConfig_$KTARole.xml") 
{
	# Copying Silent Config to TotalAgilityInstall folder
	Copy-Item "C:\KTA\SillentConfigs\SilentInstallConfig_$KTARole.xml" "C:\KTA\TotalAgilityInstall\SilentInstallConfig.xml"
	
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Success: Silent Config copied" | timestamp

	# Check if FixPack SilentConfig exists for the KTA role requested
	if(Test-Path -path "C:\KTA\KTA-Fixpack\TotalAgilityInstall\SilentInstallConfig.xml") 
	{
		# Copying Silent Config to TotalAgilityInstall folder
		Copy-Item "C:\KTA\SillentConfigs\SilentInstallConfig_$KTARole.xml" "C:\KTA\KTA-Fixpack\TotalAgilityInstall\SilentInstallConfig.xml"
		
		filter timestamp {"$(Get-Date -Format G): $_"}
		Write-output "Success: FixPack Silent Config copied" | timestamp
	}
	else
	{
		filter timestamp {"$(Get-Date -Format G): $_"}
		Write-output "Error: FixPack SilientConfig not found" | timestamp
	} 
}
else
{
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Error: SilientConfig not found" | timestamp
}



# install prerequisites for TA
$IIS = Get-WindowsOptionalFeature -Online -FeatureName “IIS-WebServer”
filter timestamp {"$(Get-Date -Format G): $_"}
write-output "Install prerequisites for KTA" | timestamp
Invoke-Expression C:\KTA\PowershellScripts\InstallWindowsFeatures.ps1

filter timestamp {"$(Get-Date -Format G): $_"}
write-output "Add Admin user for KTA" | timestamp

# Add KTA_Admin account local system 
Invoke-Expression C:\KTA\PowershellScripts\AddAdminUser.ps1
Invoke-Expression C:\KTA\PowershellScripts\UpdateAdminUser.ps1

if($IIS.State -eq "Enabled")
{
	# Install self signed cert
	filter timestamp {"$(Get-Date -Format G): $_"}
	write-output "Install Self signed cert" | timestamp
	Invoke-Expression C:\KTA\PowershellScripts\CreateHttpsCert.ps1;
}
	
# Deleting Transformation Designer folder
$strings=@("TransformationDesigner*")
get-childitem -path "C:\KTA\" -Include ($strings) -Recurse -force | ForEach-Object {
    try {
		#  -ErrorAction Ignore is being used to suppress known issue in Docker on Windows Server 2016 with deletion
        Remove-Item $_ -Force –Recurse -ErrorAction Ignore
		}
    catch { }
	}

if($IIS.State -eq "Enabled")
{
	# Download and install prerequisites for KCMProxy in silent mode

	# Download URL Rewrite
	#Invoke-WebRequest https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi -OutFile "C:\rewrite_amd64_en-US.msi"
	# Download Application Request Routing
	#Invoke-WebRequest http://download.microsoft.com/download/E/9/8/E9849D6A-020E-47E4-9FD0-A023E99B54EB/requestRouter_amd64.msi -OutFile "C:\requestRouter_amd64.msi"
	# Install URL Rewrite
	$url = Start-Process msiexec.exe -ArgumentList '/i','C:\KTA\rewrite_amd64_en-US.msi','/qn','/log C:\URLRewrite.log' -Wait -PassThru
	if ($url.ExitCode -ne 0)
	{
		Write-Host("Error occured while installing URL Rewrite, please refer to C:\URLRewrite.log inside the container for more details")
	}
	# Install Application Request Routing
	$arr = Start-Process msiexec.exe -ArgumentList '/i','C:\KTA\requestRouter_amd64.msi','/qn','/log C:\ApplicationRequestRouting.log' -Wait -PassThru
	if ($arr.ExitCode -ne 0)
	{
		Write-Host("Error occured while installing URL Rewrite, please refer to C:\ApplicationRequestRouting.log inside the container for more details")
	}
}
	
# Configuring MS-DTC for cross DB transactions
filter timestamp {"$(Get-Date -Format G): $_"}
try {   
   write-output "Enable MS DTC" | timestamp
   Set-DtcNetworkSetting -DtcName "Local" -AuthenticationLevel "NoAuth" -InboundTransactionsEnabled $true -OutboundTransactionsEnabled $true -RemoteClientAccessEnabled $true -RemoteAdministrationAccessEnabled $true  -XATransactionsEnabled $true -LUTransactionsEnabled $true -Confirm:$false
   
   # Display network settings
   $dtcSettings = Get-DtcNetworkSetting
   write-output $dtcSettings
}
catch {
  write-output "Error Setting MSDTC Settings" | timestamp
}
$silentConfig = $null
#Update Registry for TAL (added 15/08/2022)
try {   
	write-output "Updating Registry to restrict null session and anonymous access" | timestamp
	
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'restrictnullsessaccess' -Value '1'

	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'restrictanonymous' -Value '1'
}
catch {
  write-output "Error Registry Update" | timestamp
}


# Install TA in silent mode
filter timestamp {"$(Get-Date -Format G): $_"}
write-output "Start silent Install" | timestamp

# -passthru is used to get output from the command
if(Test-Path -path "C:\KTA\TotalAgilityInstall\setup.exe") {
$proc = Start-Process C:\KTA\TotalAgilityInstall\setup.exe -argumentlist '/silent' -wait -PassThru

# Copying Encrypt utility to powershellscripts folder
Copy-Item "C:\KTA\Utilities\Kofax.CEBPM.EncryptConfig.exe" "C:\KTA\PowershellScripts\Kofax.CEBPM.EncryptConfig.exe"
$silentConfig = "C:\KTA\TotalAgilityInstall\SilentInstallConfig.xml"
}
elseif(Test-Path -path "C:\KTA\OnPremiseMultiTenancyInstall\setup.exe") {
$proc = Start-Process C:\KTA\OnPremiseMultiTenancyInstall\setup.exe -argumentlist '/silent' -wait -PassThru

# Copying Encrypt utility to powershellscripts folder
Copy-Item "C:\KTA\Utilities\Kofax.CEBPM.EncryptConfig.exe" "C:\KTA\PowershellScripts\Kofax.CEBPM.EncryptConfig.exe"
$silentConfig = "C:\KTA\OnPremiseMultiTenancyInstall\SilentInstallConfig.xml"
}
elseif(Test-Path -path "C:\KTA\IntegrationServerInstall\setup.exe") {
	Add-Content C:\Windows\System32\drivers\etc\hosts  -Value '<IP_ADDRESS>    <KTA_SERVICE_HOSTNAME>'
	write-output "Added KTA service hostname and IP placeholder to hosts file."
	$proc = Start-Process C:\KTA\IntegrationServerInstall\setup.exe -argumentlist '/silent' -wait -PassThru
	write-output "IS install completed."

# Copying Encrypt utility to powershellscripts folder
Copy-Item "C:\KTA\Utilities\Kofax.CEBPM.EncryptConfig.exe" "C:\KTA\PowershellScripts\Kofax.CEBPM.EncryptConfig.exe"
}

# CopyFonts for OP and OPMT if install transformation service is true
if ($null -ne $silentConfig) {
    $xmlDoc = [System.Xml.XmlDocument](Get-Content $silentConfig);
    if (($xmlDoc.ConfigurationEntity.ServicesInstallOptions.TransformationService -eq $true) -And (Test-Path -path "C:\KTA\Fonts")) {
		#Invoke-Expression C:\KTA\PowershellScripts\install_fonts.ps1
		#updated install font script to support new Windows 2022
		Invoke-Expression C:\KTA\PowershellScripts\install_fonts_new.ps1
		 write-output "Windows fonts copied successfully." | timestamp
	}
}

# Setting the KTA service startup type to manual to prevent automatic startup of services during container creation
Get-Service| ForEach-Object {	
	if ($_.DisplayName.StartsWith("Kofax")) {
		Set-Service -Name  $_.Name -StartupType Manual -Status "Stopped" -PassThru;        
	} 
}

if ($proc.ExitCode -ne 0) {
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Install failed with errors" | timestamp
    Write-output "Install Logs"
	Get-ChildItem -Path "C:\Users\ContainerAdministrator\Desktop" | Where-Object {$_.Name.StartsWith("KofaxTotalAgility")} | ForEach-Object {
                            Write-Output $_.Name
                            get-content $_.FullName
                        }
}
elseif ($proc.ExitCode -eq 0) {	
	# KK 04072022 start change - added fix pack install code
	# Install TA Fixpack in silent mode
	filter timestamp {"$(Get-Date -Format G): $_"}
	write-output "Start Fixpack Silent Install" | timestamp

	# -passthru is used to get output from the command
	if(Test-Path -path "C:\KTA\KTA-Fixpack\TotalAgilityInstall\setup.exe") {
	$proc2 = Start-Process C:\KTA\KTA-Fixpack\TotalAgilityInstall\setup.exe -argumentlist '/silent /hotfix' -wait -PassThru
	}

	filter timestamp {"$(Get-Date -Format G): $_"}
	write-output "Fixpack Silent Install Finished.. sleep for 10 seconds" | timestamp

	$sleep = 10
    Start-Sleep -Seconds $sleep

	# Setting the KTA service startup type to manual to prevent automatic startup of services during container creation
	Get-Service| ForEach-Object {	
		if ($_.DisplayName.StartsWith("Kofax")) {
			Set-Service -Name  $_.Name -StartupType Manual -Status "Stopped" -PassThru;        
		} 
	}

	if ($proc2.ExitCode -ne 0) {
		filter timestamp {"$(Get-Date -Format G): $_"}
		Write-output "Install FixPack failed with errors" | timestamp
		
	}
	elseif ($proc2.ExitCode -eq 0){
		filter timestamp {"$(Get-Date -Format G): $_"}
		Write-output "Completed FixPack silent Install" | timestamp
	}
	# KK 04072022 end change

	#KK 11112022 start change - Copy doc converter ini
	if((Test-Path -path "C:\KTA\Other\KFXConverter.ini") -And (Test-Path -path "C:\Program Files (x86)\Kofax\Document Converter\bin\KFXConverter")) 
	{
		# Copying doc converter ini
		Copy-Item "C:\KTA\Other\KFXConverter.ini" "C:\Program Files (x86)\Kofax\Document Converter\bin\KFXConverter\KFXConverter.ini"
		
		filter timestamp {"$(Get-Date -Format G): $_"}
		Write-output "Success: TS doc converter ini copied" | timestamp

		# Copying doc converter default ini
		Copy-Item "C:\KTA\Other\KFXConverter_Default.ini" "C:\Program Files (x86)\Kofax\Document Converter\bin\KFXConverter\KFXConverter_Default.ini"

				
		filter timestamp {"$(Get-Date -Format G): $_"}
		Write-output "Success: TS doc converter default ini copied" | timestamp
	}
		#added KIC-EID folder 15/08/2023
	if((Test-Path -path "C:\KTA\Other\KFXConverter.ini") -And (Test-Path -path "C:\Program Files (x86)\Kofax\KIC-ED\MC\bin\KFXConverter")) 
	{
		# Copying doc converter ini
		Copy-Item "C:\KTA\Other\KFXConverter.ini" "C:\Program Files (x86)\Kofax\KIC-ED\MC\bin\KFXConverter\KFXConverter.ini"
		
		filter timestamp {"$(Get-Date -Format G): $_"}
		Write-output "Success: KIC doc converter ini copied" | timestamp

		# Copying doc converter default ini
		Copy-Item "C:\KTA\Other\KFXConverter_Default.ini" "C:\Program Files (x86)\Kofax\KIC-ED\MC\bin\KFXConverter\KFXConverter_Default.ini"
		
		filter timestamp {"$(Get-Date -Format G): $_"}
		Write-output "Success: KIC doc converter default ini copied" | timestamp
	}
	# KK 11112022 end change
	
	Write-output "Install Logs"
	Get-ChildItem -Path "C:\Users\ContainerAdministrator\Desktop" | Where-Object {$_.Name.StartsWith("KofaxTotalAgility")} | ForEach-Object {
                            Write-Output $_.Name
                            get-content $_.FullName
                        }
}
if ($proc.ExitCode -eq 0) {	

	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Completed silent Install" | timestamp
	
	
						
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Delete Program Cache" | timestamp
	# Delete Program Cache

	Get-ChildItem -LiteralPath 'C:\ProgramData\Package Cache\'  -Recurse | 
	Select-Object -ExpandProperty FullName | 
	Sort-Object length -Descending | 
		ForEach-Object {
			try {
					#  -ErrorAction Ignore is being used to suppress known issue in Docker on Windows Server 2016 with deletion
					Remove-Item -path $_ -force -ErrorAction Ignore;
				}
			catch { }
		}
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Program Cache deletion completed" | timestamp
	
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Delete installation media" | timestamp
	# Deleting Installation media since installation was successful	
	Get-ChildItem -Path  "C:\KTA\" -Recurse -exclude SilentInstallConfig.xml | 
	Select-Object -ExpandProperty FullName | 
	Where-Object {$_ -notlike "C:\KTA\PowershellScripts*"} | 
	Sort-Object length -Descending | 
	ForEach-Object {
	try {
		#  -ErrorAction Ignore is being used to suppress known issue in Docker on Windows Server 2016 with deletion
		Remove-Item -path $_ -force -ErrorAction Ignore;
		}
	catch { }
	}
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Installation media deletion completed" | timestamp	
}
