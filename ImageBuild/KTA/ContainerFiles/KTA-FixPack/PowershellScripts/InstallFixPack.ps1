
# Install TA in silent mode
filter timestamp {"$(Get-Date -Format G): $_"}
write-output "Start Fixpack silent Install" | timestamp

# -passthru is used to get output from the command
if(Test-Path -path "C:\KTA\KTA-Fixpack\TotalAgilityInstall\setup.exe") {
$proc = Start-Process C:\KTA\KTA-Fixpack\TotalAgilityInstall\setup.exe -argumentlist '/silent /hotfix' -wait -PassThru
}

# Setting the KTA service startup type to manual to prevent automatic startup of services during container creation
	Get-Service| ForEach-Object {	
    if ($_.DisplayName.StartsWith("Kofax")) {
        Set-Service -Name  $_.Name -StartupType Manual -Status "Stopped" -PassThru;        
	}
}
if ($proc.ExitCode -ne 0) {
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Install FixPack failed with errors" | timestamp
    Get-ChildItem -Path "C:\Users\ContainerAdministrator\Desktop" | Where-Object {$_.Name.StartsWith("KofaxTotalAgility")} | ForEach-Object {get-content $_.FullName}
}
elseif ($proc.ExitCode -eq 0) {	
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Completed fixpack silent Install" | timestamp
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "Delete installation media" | timestamp
	# Deleting Installation media since installation was successful	
	Get-ChildItem -Path  "C:\KTA\KTA-Fixpack\" -Recurse -exclude loktarogar.txt | 
	Select -ExpandProperty FullName | 
	Where {$_ -notlike "C:\KTA\KTA-Fixpack\PowershellScripts*"} | 
	sort length -Descending | 
	ForEach-Object {
	try {
		#  -ErrorAction Ignore is being used to suppress known issue in Docker on Windows Server 2016 with deletion
		Remove-Item -path $_ -force -ErrorAction Ignore;
		}
	catch { }
	}
	filter timestamp {"$(Get-Date -Format G): $_"}
	Write-output "FixPack Installation media deletion completed" | timestamp	
}