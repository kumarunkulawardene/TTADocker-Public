ARG ImageTag=4.8.1-windowsservercore-ltsc2022

FROM mcr.microsoft.com/dotnet/framework/aspnet:$ImageTag
#FROM mcr.microsoft.com/dotnet/framework/runtime:$ImageTag

ARG KTARole=MC

#RUN Write-Host KTARole: $env:KTARole

COPY ContainerFiles ContainerFiles_Installers ContainerFiles_$KTARole C:\\KTA/
#COPY ContainerFiles ContainerFiles_$KTARole C:\\KTA/

#RUN powershell C:\KTA\CopySilentConfig.ps1 -KTARole $env:KTARole -InstallerPath "C:\KTA"
RUN powershell C:\KTA\PowershellScripts\ConfigureContainer.ps1 -KTARole $env:KTARole

EXPOSE 80

EXPOSE 443

#ENTRYPOINT powershell "C:\KTA\PowershellScripts\Startup.ps1"
#ENTRYPOINT powershell "C:\\KTA\\PowershellScripts\\Startup.ps1"

#LogMonitor directory contains LogMonitor.exe and LogMonitorConfig.json file
WORKDIR /LogMonitor
COPY LogMonitorConfig.json .
COPY LogMonitor.exe .
SHELL ["C:\\LogMonitor\\LogMonitor.exe", "powershell.exe"]

ENTRYPOINT "C:\\KTA\\PowershellScripts\\Startup.ps1"
