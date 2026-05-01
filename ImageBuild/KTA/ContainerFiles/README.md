# KTA Shared Container Files

Shared runtime files copied into KTA images.

## Contents

- `PowershellScripts/` - Startup, configuration update, certificate import, font installation, Windows feature installation, and service startup scripts.
- `SillentConfigs/` - Silent install XML templates for KTA roles. Placeholder values must be updated per environment.
- `KTA-FixPack/` - Fix pack installation scripts.
- `Other/` - Converter and Log Monitor configuration files.
- `Utilities/` - Prerequisite tooling and configuration required by image builds.

Installer binaries and generated archives should be provided in the local build workspace.
