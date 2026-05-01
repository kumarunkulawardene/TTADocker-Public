# ImageBuild

This folder groups the container build material by Tungsten product.

## Contents

- `KTA/` - Dockerfile, role-specific build context folders, silent install templates, runtime PowerShell scripts, certificate placeholders, and TotalAgility build logs.
- `Insight/` - Insight web and scheduler Dockerfiles, Docker Compose/Kubernetes/Swarm deployment examples, runtime scripts, certificate placeholders, fonts, tools, and build logs.

## Notes

- Files are designed for Windows container builds.
- Installer binaries and generated image archives should remain outside source control.
- Ensure placeholder values are updated before use.
