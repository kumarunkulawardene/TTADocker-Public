# Tungsten Insight Container Assets

This folder contains Docker build and deployment assets for Tungsten Insight.

## Contents

- `DockerFolder/` - Primary build context for Insight web and scheduler images.
- `BuildLogs/` - Historical build logs.
- `Cert/` - Certificate placeholders. Replace with environment-specific certificates before use.

## Configuration

Insight runtime settings are primarily supplied through `DockerFolder/Insight.env`, `DockerFolder/docker-compose.yml`, and the deployment manifests under `DockerFolder/kubernetes` and `DockerFolder/Swarm`.

Database servers, database users, scheduler credentials, machine keys, registry names, and certificate passwords are represented as placeholders. Ensure placeholders are updated before use.
