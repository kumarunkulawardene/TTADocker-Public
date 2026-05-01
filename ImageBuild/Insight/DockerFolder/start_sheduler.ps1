foreach($ev in [System.Environment]::GetEnvironmentVariables('process').Keys)
{
    [System.Environment]::SetEnvironmentVariable($ev,[System.Environment]::GetEnvironmentVariable($ev,'process'), 'machine');
}

Restart-Service -Name InsightSchedulerService
Start-Process -FilePath 'C:\ServiceMonitor.exe' -ArgumentList 'InsightSchedulerService' -Wait;

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