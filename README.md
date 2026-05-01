# Tungsten TotalAgility and Insight Docker Assets

This repository contains Docker build assets, startup scripts, deployment examples, and supporting configuration files for Tungsten TotalAgility (KTA) and Tungsten Insight containers.

Configuration values are represented with placeholders such as `<REDACTED_PASSWORD>`, `<DB_SERVER>`, `<DB_USER>`, `<CONTAINER_REGISTRY>`, `<IP_ADDRESS>`, and `<REDACTED_MACHINE_KEY>`. Ensure placeholders are updated before use.

## Folder Map

- `ImageBuild/KTA` - TotalAgility image build files, role-specific installer folders, runtime PowerShell configuration scripts, certificate placeholders, and historical build logs.
- `ImageBuild/Insight` - Insight web and scheduler image build files, Docker Compose, Kubernetes, Swarm, certificate placeholders, and historical build logs.

## Placeholder Handling

- Update database connection strings, service account passwords, certificate passwords, machine keys, certificate files, host names, and IP addresses before deployment.
- Certificate files in this repository are placeholders. Supply environment-specific certificates at build or runtime.
- The `.gitignore` excludes common installer binaries, logs, archives, and certificate formats for future additions.

## Typical Workflow

1. Copy the relevant product installer media into the documented installer folders outside source control.
2. Update placeholders through environment variables, Docker configuration, Kubernetes configuration, or a local untracked environment file.
3. Build the required role images from the product folder.
4. Deploy with the Docker Compose, Kubernetes, or Swarm examples after updating image names and placeholder references.
