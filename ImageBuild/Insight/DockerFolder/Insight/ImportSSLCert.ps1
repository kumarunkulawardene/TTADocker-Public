#Import SSL Cert

param (
	[string]$certPath = "C:\Insight\Certs\ktawebappbe.pfx",   
	[string]$rootCertPath = "C:\Insight\Certs\ktawebappbe.cer",
	[string]$caCertPath = "C:\Insight\Certs\ktawebappbe.cer",
	[string]$certPassword = "<REDACTED_PASSWORD>",   
	[string]$bindingHostHeader = ""
)

if (Test-Path $rootCertPath)
{
	$file = ( Get-ChildItem -Path  $rootCertPath )
	$file | Import-Certificate -CertStoreLocation cert:\LocalMachine\Root
}

if (Test-Path $caCertPath)
{
	$file = ( Get-ChildItem -Path  $caCertPath )
	$file | Import-Certificate -CertStoreLocation cert:\LocalMachine\CA
}


	
#cd iis:
#iisreset

if (Test-Path $certPath)
{    
    # Import certificate to container      
    $pfx = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2  
    $pfx.Import($certPath,$certPassword,"Exportable,MachineKeySet,PersistKeySet")   
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store("WebHosting","LocalMachine")   
    $store.Open("ReadWrite")  
    $store.Add($pfx)   
    $store.Close()   
    $certThumbprint = $pfx.Thumbprint  

    $thumbprints = Get-ChildItem -path cert:\LocalMachine\WebHosting;
         
    # assign cert to default web site
    $iisWebsiteName="Default Web Site"
      

	Import-Module WebAdministration 

    $binding1 = Get-WebBinding -Name $iisWebsiteName -Port 443 -Protocol "https";
        
	if($binding1 -eq $null)
	{            
		#New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https;
		#$binding1 = Get-WebBinding -Name $iisWebsiteName -Port 443 -Protocol "https";
		
		Set-Location cert:
		$cert = get-item cert:\LocalMachine\WebHosting\$certThumbprint

		Set-Location iis:

		Write-Host ("add cert");
		
		new-item -path IIS:\SslBindings\0.0.0.0!443 -value $cert 
		New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https

	}
	else
	{
		#Get-WebBinding -Name $iisWebsiteName -Port 443 -Protocol "https" | Remove-WebBinding;
		
		#New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https;
		#$binding1 = Get-WebBinding -Name $iisWebsiteName -Port 443 -Protocol "https";
		
		cd cert:
		$cert = get-item cert:\LocalMachine\WebHosting\$certThumbprint
		
		cd iis:
		
		Write-Host ("remove exiting cert");
		
		Get-Item IIS:\SslBindings\0.0.0.0!443 | Remove-Item
		Get-WebBinding -Name $iisWebsiteName -Port 443 -Protocol "https" | Remove-WebBinding
		
		Write-Host ("add cert");
		
		new-item -path IIS:\SslBindings\0.0.0.0!443 -value $cert 
		New-WebBinding -Name "Default Web Site" -IP "*" -Port 443 -Protocol https
		
		#$sleep = 15
		#Start-Sleep $sleep

	}
	

    #$binding1.AddSslCertificate($certThumbprint, "WebHosting");      

		

	if($bindingHostHeader)
    {    
		Write-Host ("add host reader");
		Set-WebBinding -Name "Default Web Site" -BindingInformation "*:443:" -PropertyName "HostHeader" -Value $bindingHostHeader;
	}
        

}
else
{
    Write-Output("Error: SSL Certificate not found @ '$certPath'");
}

# Do not use IISRESET , not recommended by MS
#cd iis:
#iisreset

#Use following to gracefully stop and start IIS
Write-Host ("Stop w3svc");
NET STOP w3svc
Write-Host ("Start w3svc");
NET START w3svc
