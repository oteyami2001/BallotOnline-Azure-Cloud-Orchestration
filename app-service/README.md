# BallotOnline — Azure App Service Deployment

This directory covers the Platform as a Service (PaaS) implementation of
the BallotOnline application. See
[stage 05](../docs/05-azure-app-service.md) and
[stage 06](../docs/06-continuous-deployment.md) for the full write-up.

| | |
|---|---|
| **Deployment target** | Microsoft Azure App Service (`CCS670WebAppTAO`) |
| **Runtime** | PHP 8.4 on Linux |
| **Deployment method** | Local Git push |
| **Provisioning** | [`deploy-app-service.sh`](../infrastructure/scripts/deploy-app-service.sh) (Azure CLI) |

## Entry Point

The original static application used:

```text
index.html
```

For the App Service proof of concept, the entry point was changed to:

```text
index.php
```

This let the existing application assets run on the configured PHP
runtime without a rewrite.

## Deployment Model

```text
Application files
       |
       v
Local Git
       |
       v
Azure deployment endpoint
       |
       v
Azure App Service
       |
       v
BallotOnline
```

## Security

This directory must never contain:

- Azure passwords
- Publishing passwords or deployment credentials
- Publish profiles (`*.PublishSettings`)
- API keys or access tokens
- Private SSH keys
- Azure subscription credentials

Sensitive configuration belongs in App Service application settings or
Azure Key Vault, not in Git. The repository's `.gitignore` blocks the most
common secret files.
