FROM mcr.microsoft.com/dotnet/framework/aspnet:4.8.1-windowsservercore-ltsc2022

RUN NET USER Insight_Admin /add
RUN NET LOCALGROUP Administrators /add Insight_Admin
RUN NET ACCOUNTS /maxpwage:unlimited

SHELL ["powershell", "-Command"]

COPY Insight c:\\Insight

RUN Write-Host 'Downloading Microsoft Redistributive Packages' ; \  
$RedistFile = 'C:\Insight\Tools\vc_redist.x64.exe' ; \
#(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/9/3/F/93FCF1E7-E6A4-478B-96E7-D4B285925B00/vc_redist.x64.exe', $RedistFile) ; \
Write-Host 'Installing Microsoft Redistributive Packages' ; \
Start-Process $RedistFile -ArgumentList '/quiet', '/norestart' -NoNewWindow -Wait

RUN Write-Host 'Microsoft Access Database Engine 2016 Redistributable' ; \  
$MdacFile = 'C:\Insight\Tools\accessdatabaseengine_X64.exe' ; \
#(New-Object Net.WebClient).DownloadFile('https://download.microsoft.com/download/3/5/C/35C84C36-661A-44E6-9324-8786B8DBE231/accessdatabaseengine_X64.exe', $MdacFile) ; \
Write-Host 'Microsoft Access Database Engine 2016 Redistributable' ; \
Start-Process $MdacFile -ArgumentList '/quiet', '/norestart' -NoNewWindow -Wait

#install adal driver to enable connecting to SQL with Active Directory with Password option
RUN Start-Process msiexec.exe -ArgumentList '/i', 'C:\Insight\adalsql.msi','/quiet' -NoNewWindow -Wait
	
USER Insight_Admin

#Update Registry for TAL (added 15/08/2022)
RUN c:\\Insight\\configurecontainer.ps1	

RUN Start-Process msiexec.exe -ArgumentList '/i', 'C:\Insight\KofaxInsightSetup_6.5.0.0.0.820_x64.msi', '/qn', 'INSTALLATION_TYPE=CUSTOM', 'INSTALLATION_TYPE_W=0', 'INSTALLATION_TYPE_I=0', 'INSTALLATION_TYPE_S=1' -NoNewWindow -Wait

#uncomment the line below to install Fix Pack
RUN Start-Process msiexec.exe -ArgumentList '/update', 'C:\Insight\KofaxInsight_6.5.0.5.0.877_x64.msp', '/norestart', '/qn' -NoNewWindow -Wait

EXPOSE 13501

COPY start_sheduler.ps1 c:\\start_sheduler.ps1

#LogMonitor directory contains LogMonitor.exe and LogMonitorConfig.json file
COPY LogMonitor c:\\LogMonitor

SHELL ["C:\\LogMonitor\\LogMonitor.exe", "powershell.exe"]

ENTRYPOINT "C:\\start_sheduler.ps1"

#ENTRYPOINT powershell -File 'C:\\start_sheduler.ps1'