param (
   [string]$configPath = "C:\Program Files\Kofax\TotalAgility\"   
)

# get current script path
$pos = $MyInvocation.MyCommand.Path.IndexOf($MyInvocation.MyCommand.Name);

#Remove current script name
$currentPath = $MyInvocation.MyCommand.Path.SubString(0,$pos);

# call UpdateConfigAppSettings.ps1 to update app config settings.
Invoke-Expression "$currentPath\UpdateConfigAppSettings.ps1 -configPath '$configPath'";

# call UpdateConfigBindings.ps1 to update config bindings.
Invoke-Expression "$currentPath\UpdateConfigBindings.ps1 -configPath '$configPath'";

# Import Certificate
$certPath =[Environment]::getEnvironmentVariable('KTA_SSL_CERT_PATH');
$certPasswordPath =[Environment]::getEnvironmentVariable('KTA_SSL_CERT_PASSWORD_PATH');
$certPassword = [Environment]::getEnvironmentVariable('KTA_SSL_CERT_PASSWORD');
$bindingHostHeader = [Environment]::getEnvironmentVariable('WEB_BINDING_HOST_HEADER');
$rootCertPath = [Environment]::getEnvironmentVariable('KTA_ROOT_SSL_CERT_PATH');
$caCertPath = [Environment]::getEnvironmentVariable('KTA_CA_SSL_CERT_PATH');

if($certPasswordPath -ne $null)
{
    #check password file path
    if(Test-Path $certPasswordPath)
    {    
      $certPassword = Get-Content $certPasswordPath -TotalCount 1;
    }
}

if($certPath -ne $null -and $null -ne $certPassword)
{
    Write-Output("Importing certificate $certPath");        
    Invoke-Expression "$currentPath\ImportSSLCert.ps1 -certPath '$certPath' -certPassword '$certPassword' -bindingHostHeader '$bindingHostHeader' -rootCertPath '$rootCertPath' -caCertPath '$caCertPath'";

    #Reset envoirnment varible.
    [Environment]::SetEnvironmentVariable('KTA_SSL_CERT_PASSWORD_PATH', $null, 'Process');
    [Environment]::SetEnvironmentVariable('KTA_SSL_CERT_PATH', $null, 'Process');
    [Environment]::SetEnvironmentVariable('KTA_SSL_CERT_PASSWORD', $null, 'Process');

    [Environment]::SetEnvironmentVariable('KTA_SSL_CERT_PASSWORD_PATH', $null, 'Machine');
    [Environment]::SetEnvironmentVariable('KTA_SSL_CERT_PASSWORD', $null, 'Machine');
    [Environment]::SetEnvironmentVariable('KTA_SSL_CERT_PATH', $null, 'Machine');

    [Environment]::SetEnvironmentVariable('KTA_SSL_CERT_PASSWORD_PATH', $null, 'User');
    [Environment]::SetEnvironmentVariable('KTA_SSL_CERT_PASSWORD', $null, 'User');
    [Environment]::SetEnvironmentVariable('KTA_SSL_CERT_PATH', $null, 'User');   
}


# Perform KCM proxy installation if valid server URL is specified
Invoke-Expression "$currentPath\KCMProxyInstallation.ps1";

# call StartTAServices.ps1 to start services.
$scriptPath = "$currentPath\StartTAServices.ps1";
Invoke-Expression "$scriptPath";

# Encrypt the config files
Invoke-Expression "$currentPath\CryptoConfigFiles.ps1";

# Uncomment the below code to install legacy wrappers
#if (Test-path -Path 'C:\Program Files\Kofax\TotalAgility\LegacyWrappers\WrapperInstaller.exe')
#{
#	'C:\Program Files\Kofax\TotalAgility\LegacyWrappers\WrapperInstaller.exe'
#}

#Run extranal startup script
$extStartupScriptPath =[Environment]::getEnvironmentVariable('KTA_EXT_STARTUP_SCRIPT_PATH');
$extStartupScriptEnabled =[Environment]::getEnvironmentVariable('KTA_EXT_STARTUP_SCRIPT_ENABLED');

#Check if ExternalStartupScript exists and run it if exists
if($extStartupScriptEnabled -eq "true") 
{
    filter timestamp {"$(Get-Date -Format G): $_"}
    write-output "ExternalStartupScript Enabled" | timestamp
    if(Test-Path -path "$extStartupScriptPath") 
    {
        write-output "Found ExternalStartupScript.. Running" | timestamp
        Invoke-Expression "$extStartupScriptPath\ExternalStartupScript.ps1";
    }
}

$sleep = 500
while ($true)
{
    Start-Sleep $sleep
} 
