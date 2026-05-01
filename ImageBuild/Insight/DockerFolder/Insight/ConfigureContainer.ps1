# Install self signed cert
filter timestamp {"$(Get-Date -Format G): $_"}
write-output "Install Self signed cert" | timestamp
Invoke-Expression C:\Insight\CreateHttpsCert.ps1;


<# # Install default cert
filter timestamp {"$(Get-Date -Format G): $_"}
write-output "Install Default cert" | timestamp
Invoke-Expression C:\Insight\ImportSSLCert.ps1; #>


#Update Registry for TAL (added 15/08/2022)

filter timestamp {"$(Get-Date -Format G): $_"}

try {   
	write-output "Updating Registry to restrict null session and anonymous access" | timestamp
	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters' -Name 'restrictnullsessaccess' -Value '1'

	Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa' -Name 'restrictanonymous' -Value '1'
}
catch {
  write-output "Error Registry Update" | timestamp
}
