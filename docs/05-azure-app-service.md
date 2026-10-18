# 05 — Azure App Service PaaS Deployment

## Objective

This stage evaluates Microsoft Azure Platform as a Service (PaaS) by
deploying the BallotOnline web application to Azure App Service.

Unlike the IaaS architecture in stages [01](01-azure-vm-deployment.md)
to [04](04-load-balancer-health-probe.md), App Service removes the need to
administer virtual machines, operating systems, Nginx, patching, or
individual web server instances.

---

## Architecture

```text
                    Developer
                        |
                        v
                    Azure CLI
                        |
                        v
              +-------------------+
              | Azure App Service |
              | CCS670WebAppTAO   |
              +---------+---------+
                        |
                   PHP Runtime
                        |
                        v
                BallotOnline App
                        |
                        v
                  Internet Users
```

---

## IaaS vs. PaaS

The IaaS deployment required managing every layer:

```text
IaaS

Internet
   |
Load Balancer
   |
VM Scale Set
   |
Ubuntu
   |
Nginx
   |
Application
```

Azure App Service provides a higher level of abstraction:

```text
PaaS

Internet
   |
Azure App Service
   |
Application
```

Azure manages the underlying infrastructure.

---

## Azure Resources

| Resource                 | Configuration             |
|--------------------------|---------------------------|
| Resource Group           | `CCS670WebAppRG`          |
| Service                  | Azure App Service         |
| Web App                  | `CCS670WebAppTAO`         |
| Operating System         | Linux                     |
| Runtime                  | PHP 8.4                   |
| Initial App Service Tier | Basic B1                  |
| Deployment               | Local Git                 |
| Management               | Azure CLI                 |
| Monitoring               | Azure App Service metrics |

All of these resources can be recreated with
[`infrastructure/scripts/deploy-app-service.sh`](../infrastructure/scripts/deploy-app-service.sh).

---

## Resource Group

A dedicated resource group was created for the PaaS deployment:

```bash
az group create \
  --name CCS670WebAppRG \
  --location westus3
```

A separate resource group gives the App Service resources a clear
logical boundary and makes cleanup a single command.

---

## App Service Plan

A Linux App Service Plan provides the compute that runs the web app:

```text
Resource Group
      |
      v
App Service Plan
      |
      v
Azure Web App
      |
      v
BallotOnline
```

The proof of concept started on the Basic B1 tier.

---

## Troubleshooting — Regional Quota

| | |
|---|---|
| **Symptom** | Creating the App Service Plan in East US failed with a quota error |
| **Root cause** | The Azure student subscription had no available compute quota for that tier in East US |
| **Fix** | Deployed to West US 3, where quota was available, instead of waiting for a quota increase |

```text
East US  -->  Quota error  -->  Deployment failed
                                       |
                                       v
West US 3  -->  Quota available  -->  Deployment successful
```

**Lesson:** managed PaaS services still depend on subscription-level and
regional capacity limits. Checking quotas early (`az vm list-usage
--location <region>`) avoids surprises.

---

## Web App

The BallotOnline web app was created as `CCS670WebAppTAO` on the PHP
runtime.

The existing static site was adapted for PaaS by renaming its entry
point:

```text
index.html  -->  index.php
```

This let the existing site run on the PHP runtime without rewriting the
application. See [`app-service/`](../app-service/) for details.

---

## PaaS Operational Model

With IaaS, the team was responsible for:

- VM provisioning
- Linux administration
- Package installation
- Nginx configuration
- VM images
- Scale set instances
- Load balancing
- Server-level troubleshooting

With Azure App Service, Azure handles most of these. The workflow
becomes application-focused:

```text
Application Code
      |
      v
Git Deployment
      |
      v
Azure App Service
      |
      v
Managed Runtime
```

---

## Scaling

During the proof of concept, the App Service Plan was temporarily scaled
up from Basic B1 to Standard S2 to explore the features of higher tiers:

- Scale-out to multiple instances
- Autoscale rules
- Deployment slots
- Backups
- Other production features

After testing, the plan was scaled back to Basic B1 to avoid unnecessary
charges.

```bash
# Scale up for testing, then back down
az appservice plan update --name <plan> --resource-group CCS670WebAppRG --sku S2
az appservice plan update --name <plan> --resource-group CCS670WebAppRG --sku B1
```

---

## Monitoring

App Service metrics were reviewed while requests were generated against
the application, showing traffic and resource usage without logging in
to any server.

---

## Security Considerations

The PaaS architecture reduces infrastructure exposure because the team
does not manage public VM instances.

Security considerations include:

- Azure identity and access controls
- Secure deployment credentials
- HTTPS
- Application configuration
- Secrets management
- Least-privilege deployment access

No passwords, deployment credentials, tokens, or secrets are stored in
this repository.

---

## Skills Demonstrated

- Azure App Service (Linux)
- Platform as a Service
- Azure CLI
- PHP
- Resource groups and App Service Plans
- Cloud scaling
- Azure monitoring
- Cloud troubleshooting
- IaaS vs. PaaS architecture
