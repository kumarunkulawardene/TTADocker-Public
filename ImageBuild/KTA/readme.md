# Tungsten TotalAgility Container Assets

This folder contains Docker build assets for Tungsten TotalAgility (KTA) Windows container images, including role-specific installer inputs, silent install templates, runtime configuration scripts, and sample deployment utilities.

## Contents

- `Dockerfile` - Primary role-aware image build definition.
- `Dockerfile.MonitorTest` - Alternate/test Dockerfile for Log Monitor validation.
- `DockerSettings_*.Env` - Environment templates for runtime KTA configuration.
- `ContainerFiles/` - Shared runtime scripts, silent install templates, fix pack scripts, utilities, and configuration files copied into images.
- `ContainerFiles_WebApp/`, `ContainerFiles_MC/`, `ContainerFiles_License/`, `ContainerFiles_Reporting/`, `ContainerFiles_Transformation/` - Role-specific installer/build context folders.
- `ContainerFiles_Installers/` - Installer media staging folders. Keep real installer binaries outside source control.
- `Certs/` - Certificate placeholders. Replace with environment-specific certificates before use.
- `ExternalScripts/` - Optional startup/customisation scripts.
- `LogMonitor/` and `LogMonitorConfig.json` - Windows container log monitoring configuration.
- `archive/` - Older silent install and fix pack configuration material retained for reference.
- `logs/` - Historical build/runtime logs.

## Build

Prepare the build context by copying the required KTA installer media into the appropriate role-specific folder. The `KTARole` build argument must match the target role folder suffix.

```powershell
docker build -t <image-name>:<tag> "<docker-folder-path>" --build-arg KTARole=<role> --build-arg ImageTag=<base-image-tag>
```

Common `KTARole` values:

- `WebApp`
- `MC`
- `License`
- `Reporting`
- `TS`

## Silent Install Templates

Review `ContainerFiles/SillentConfigs/SilentInstallConfig_*.xml` before building. For container builds these templates generally use:

- `IsDocker=true`
- `CheckDatabaseCompatibility=false`
- `InstallDatabases=false`
- prerequisite checks disabled where the Dockerfile handles them
- `StartServices=false`
- `SslEnabled=true`

## Runtime SSL

`ContainerFiles/PowershellScripts/Startup.ps1` can install and bind certificates at container startup. Provide these values through secure environment injection:

- `KTA_SSL_CERT_PASSWORD`
- `KTA_SSL_CERT_PASSWORD_PATH`
- `KTA_SSL_CERT_PATH`
- `WEB_BINDING_HOST_HEADER`
- `KTA_ROOT_SSL_CERT_PATH`
- `KTA_CA_SSL_CERT_PATH`

Ensure certificate files, certificate passwords, database credentials, resource host names, and IP addresses are updated before use.
