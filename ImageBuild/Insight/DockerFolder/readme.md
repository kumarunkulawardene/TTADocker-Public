# Tungsten Insight Docker Folder

This is the main Docker build context for Tungsten Insight web and scheduler containers.

## Contents

- `InsightWeb.Dockerfile` - Builds the Insight web/data service image.
- `Scheduler.Dockerfile` - Builds the Insight scheduler image.
- `docker-compose.yml` - Local Windows container composition for web and scheduler services.
- `Insight.env` - Environment variable template with database, password, scheduler, and machine-key placeholders.
- `Insight/` - Runtime scripts, install configuration, certificate placeholders, fonts, and supporting tools copied into the image.
- `kubernetes/` - AKS-style Kubernetes storage and deployment examples.
- `Swarm/` - Docker Swarm deployment example.
- `LogMonitor/` - Log Monitor configuration used by Windows containers.

## Build

Run from this folder:

```powershell
docker compose build
docker build -f .\InsightWeb.Dockerfile -t insightwebssl:<tag> .
docker build -f .\Scheduler.Dockerfile -t insightschedulerssl:<tag> --memory=16g .
```

## Runtime Values

Before deployment, update placeholders such as `<DB_SERVER>`, `<DB_USER>`, `<REDACTED_PASSWORD>`, `<REDACTED_MACHINE_KEY>`, and `<CONTAINER_REGISTRY>`.

For SSL installation, provide environment-specific certificate files and ensure the certificate thumbprint is reflected in `Insight/InstallConfig.xml` where required.
