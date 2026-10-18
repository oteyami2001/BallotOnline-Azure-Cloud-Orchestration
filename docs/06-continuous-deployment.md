# 06 — Git Continuous Deployment to Azure App Service

## Objective

This stage adds a DevOps deployment workflow to the BallotOnline Azure
App Service implementation from [stage 05](05-azure-app-service.md).

Instead of manually copying files to a server, Git is used to deploy
application changes to App Service.

---

## Deployment Architecture

```text
Developer
    |
    | git add
    | git commit
    | git push
    v
Local Git Repository
    |
    | HTTPS
    v
Azure App Service
Deployment Endpoint
    |
    v
Deployment Process
    |
    v
CCS670WebAppTAO
    |
    v
BallotOnline Website
```

---

## Deployment Workflow

```text
Modify Application
       |
       v
git add
       |
       v
git commit
       |
       v
git push
       |
       v
Azure receives code
       |
       v
Deployment starts
       |
       v
Application updated
```

This is more repeatable than manually copying files to a VM.

---

## Local Git Deployment

App Service was configured for local Git deployment. The app's
deployment endpoint acts as a remote Git repository.

```bash
# 1. Set deployment credentials (username must be unique across Azure)
az webapp deployment user set --user-name <deployment-username>

# 2. Get the app's Git deployment URL
az webapp deployment source config-local-git \
  --name <web-app-name> \
  --resource-group CCS670WebAppRG \
  --query url --output tsv

# 3. Add it as a remote and push
git remote add azure <AZURE_GIT_DEPLOYMENT_URL>

git add .
git commit -m "Deploy BallotOnline application"
git push azure main:master
```

App Service local Git deploys from the `master` branch by default, so
`main:master` pushes the local `main` branch to it.

The deployment URL and credentials are intentionally left out of this
public repository.

---

## Troubleshooting

### Publishing username already taken

| | |
|---|---|
| **Symptom** | Setting the deployment username failed because the name was already in use |
| **Root cause** | App Service deployment credentials belong to the Azure user account, not to one app, so the username must be unique across all of Azure |
| **Fix** | Chose a different, more specific deployment username |

### Git remote pointing to the old username

| | |
|---|---|
| **Symptom** | `git push azure` failed with authentication errors |
| **Root cause** | The Git remote URL still contained the previous deployment username |
| **Fix** | Updated the remote, after which authentication succeeded |

```bash
git remote -v                                   # shows the stale URL
git remote set-url azure <CORRECT_AZURE_GIT_URL>
```

### Malformed Azure CLI option

| | |
|---|---|
| **Symptom** | Azure CLI rejected a copied command |
| **Root cause** | Copying from formatted documentation replaced `--` with a typographic dash |
| **Fix** | Retyped the option with plain ASCII hyphens |

```text
Incorrect:  –-resource-group
Correct:    --resource-group
```

---

## Deployment Verification

After the Git and authentication issues were fixed, the code was pushed
to Azure. The Deployment Center logs confirmed the deployment succeeded,
and the BallotOnline site loaded at the web app's hostname
(`https://<web-app-name>.azurewebsites.net`).

```bash
# Check recent deployments from the command line
az webapp log deployment list \
  --name <web-app-name> \
  --resource-group CCS670WebAppRG \
  --output table
```

---

## DevOps Value

The deployment model changes from:

```text
Administrator
    |
   SSH
    |
  Server
    |
Manually update files
```

to:

```text
Developer
    |
   Git
    |
Azure App Service
    |
Automated deployment
```

Benefits include:

- Version-controlled deployments
- Repeatability
- Less manual server access
- Faster application updates
- Deployment history
- Easier troubleshooting
- Separation of application and infrastructure management

---

## Production Evolution

The proof of concept used App Service local Git deployment. A production
environment could grow this into a full CI/CD pipeline:

```text
GitHub
   |
   v
GitHub Actions
   |
   +--> Build
   |
   +--> Test
   |
   +--> Security scan
   |
   +--> Deploy
   |
   v
Azure App Service
```

This adds automated quality gates while keeping the same application
architecture.

---

## Skills Demonstrated

- Git and version control
- Azure App Service
- Continuous deployment
- Azure CLI
- Deployment Center
- PaaS
- DevOps
- Deployment troubleshooting
- Cloud automation
