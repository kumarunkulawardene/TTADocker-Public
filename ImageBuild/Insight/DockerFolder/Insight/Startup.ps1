foreach($ev in [System.Environment]::GetEnvironmentVariables('process').Keys)
{
    [System.Environment]::SetEnvironmentVariable($ev,[System.Environment]::GetEnvironmentVariable($ev,'process'), 'machine');
}

# get current script path
$pos = $MyInvocation.MyCommand.Path.IndexOf($MyInvocation.MyCommand.Name);

#Remove current script name
$currentPath = $MyInvocation.MyCommand.Path.SubString(0,$pos);


# Import Certificate
$certPath =[Environment]::getEnvironmentVariable('SSL_CERT_PATH');
$certPasswordPath =[Environment]::getEnvironmentVariable('SSL_CERT_PASSWORD_PATH');
$certPassword = [Environment]::getEnvironmentVariable('SSL_CERT_PASSWORD');
$bindingHostHeader = [Environment]::getEnvironmentVariable('WEB_BINDING_HOST_HEADER');
$rootCertPath = [Environment]::getEnvironmentVariable('ROOT_SSL_CERT_PATH');
$caCertPath = [Environment]::getEnvironmentVariable('CA_SSL_CERT_PATH');

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
    [Environment]::SetEnvironmentVariable('SSL_CERT_PASSWORD_PATH', $null, 'Process');
    [Environment]::SetEnvironmentVariable('SSL_CERT_PATH', $null, 'Process');
    [Environment]::SetEnvironmentVariable('SSL_CERT_PASSWORD', $null, 'Process');

    [Environment]::SetEnvironmentVariable('SSL_CERT_PASSWORD_PATH', $null, 'Machine');
    [Environment]::SetEnvironmentVariable('SSL_CERT_PATH', $null, 'Machine');
    [Environment]::SetEnvironmentVariable('SSL_CERT_PASSWORD', $null, 'Machine');

    [Environment]::SetEnvironmentVariable('SSL_CERT_PASSWORD_PATH', $null, 'User');
    [Environment]::SetEnvironmentVariable('SSL_CERT_PATH', $null, 'User');
    [Environment]::SetEnvironmentVariable('SSL_CERT_PASSWORD', $null, 'User');   
}

#Run extranal startup script
$extStartupScriptPath =[Environment]::getEnvironmentVariable('INSIGHT_EXT_STARTUP_SCRIPT_PATH');
$extStartupScriptEnabled =[Environment]::getEnvironmentVariable('INSIGHT_EXT_STARTUP_SCRIPT_ENABLED');

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
