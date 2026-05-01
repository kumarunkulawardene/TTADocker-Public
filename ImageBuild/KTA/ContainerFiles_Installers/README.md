# KTA Installer Staging Folders

This folder contains role-specific staging locations for KTA installer media and fix packs.

## Contents

- `Fonts/` - Optional font files required by image builds.
- `KIC/` - Kofax/Tungsten Import Connector installer media staging.
- `NET-Framework35-Features/` - .NET Framework 3.5 feature media staging.
- `KTA-FixPack/` - Fix pack media staging by role.

Place real installer files here only in a local/private build workspace. Installer packages and generated archives are ignored by `.gitignore`.
