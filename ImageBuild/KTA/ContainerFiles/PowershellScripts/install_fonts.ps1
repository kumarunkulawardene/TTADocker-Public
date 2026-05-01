$sFontsFolder = "C:\KTA\Fonts";
$sRegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Fonts";

$objShell = New-Object -ComObject Shell.Application;

$objFolder = $objShell.namespace($sFontsFolder);

foreach ($objFile in $objFolder.items()) {
    
    $sFontName = $($objFolder.getDetailsOf($objFile, 21));
    $sRegKeyName = $sFontName, "(TrueType)" -join " ";
    $sRegKeyValue = $objFile.Name;
	try{
		if(-not(Test-Path -path "c:\windows\fonts\$($objFolder.getDetailsOf($objFile, 0))"))
		{
			Copy-Item $objFile.Path "c:\windows\fonts";
			write-host "Font copied : c:\windows\fonts\$($objFolder.getDetailsOf($objFile, 0))" 
		} else {  write-host "Font already exists in c:\windows\fonts\$($objFolder.getDetailsOf($objFile, 0))" }

		If (-not(Get-ItemProperty -Name $sRegKeyName -Path $sRegPath  -ErrorAction SilentlyContinue)) {  
			New-ItemProperty -Path $sRegPath -Name $sRegKeyName -Value $sRegKeyValue -PropertyType String -Force;  
			write-host "Registered font: $sRegKeyName"
        } else {  write-host "Font already registered: $sRegKeyName" }
	}
	catch {
		write-host "Error installing font: $objFile.Path. " $_.exception.message
	}
}