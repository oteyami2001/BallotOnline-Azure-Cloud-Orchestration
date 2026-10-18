# 08 — Troubleshooting Runbook

## Purpose

This runbook records the issues encountered during the BallotOnline Azure
proof of concept and how each was resolved. Every incident below
happened during the real deployment.

| # | Incident | Layer | Root cause |
|---|---|---|---|
| 1 | [Nginx installation failure](#incident-1--nginx-installation-failure) | Operating system | Stale APT package index |
| 2 | [App Service regional quota failure](#incident-2--app-service-regional-quota-failure) | Subscription / quota | No compute quota in East US |
| 3 | [Publishing username conflict](#incident-3--publishing-username-conflict) | Azure platform | Username must be unique across Azure |
| 4 | [Git authentication failure](#incident-4--git-authentication-failure) | Deployment tool | Stale Git remote URL |
| 5 | [Azure CLI argument error](#incident-5--azure-cli-argument-error) | Deployment tool | Typographic dash in a copied command |

---

## Incident 1 — Nginx Installation Failure

**Symptom:** Installing Nginx on the Ubuntu VM returned package download
errors:

```text
404 Not Found
```

**Impact:** The web server could not be installed, so the application
could not be served.

**Investigation:** The VM had network connectivity, but its local package
metadata referenced package versions no longer available on the
repository mirror.

**Root cause:** Stale local APT package index.

**Resolution:**

```bash
sudo apt-get update
sudo apt-get install -y nginx
```

**Result:** Nginx installed successfully.

**Lesson learned:** Refresh package metadata before assuming the package
is unavailable or the network is the problem.

**Prevention:** [`install-nginx.sh`](../infrastructure/scripts/install-nginx.sh)
always runs `apt-get update` first.

---

## Incident 2 — App Service Regional Quota Failure

**Symptom:** Creating the App Service Plan failed in the first region
selected (East US).

**Impact:** The PaaS deployment could not continue in that region.

**Investigation:** Azure reported insufficient compute quota for the
subscription.

**Root cause:** The student subscription had no available regional
capacity for the requested App Service configuration.

**Resolution:** Deployed the App Service resources to West US 3, where
quota was available.

**Result:** The App Service Plan and web app were provisioned
successfully.

**Lesson learned:** Resource availability depends on both the service and
subscription-specific regional quotas.

**Prevention:** Check quota before deploying:

```bash
az vm list-usage --location <region> --output table
```

---

## Incident 3 — Publishing Username Conflict

**Symptom:** The chosen App Service deployment username was rejected.

**Root cause:** Deployment credentials belong to the Azure user account,
not a single app, so the username must be unique across all of Azure.
The chosen name was already taken.

**Resolution:** Configured a different, more specific username:

```bash
az webapp deployment user set --user-name <unique-username>
```

**Result:** Deployment configuration could continue.

**Lesson learned:** Some Azure identifiers must be unique far beyond the
resource group or subscription.

---

## Incident 4 — Git Authentication Failure

**Symptom:** `git push` to Azure App Service failed authentication.

**Investigation:** The deployment username had changed (incident 3), but
the local Git remote still contained the old username.

**Root cause:** Stale Git remote URL.

**Diagnosis:**

```bash
git remote -v
```

**Resolution:**

```bash
git remote set-url azure <CORRECT_AZURE_GIT_URL>
git remote -v                 # verify
git push azure main:master    # retry
```

**Result:** Azure accepted the deployment.

**Lesson learned:** When cloud-side deployment credentials or identifiers
change, local deployment configuration must be updated too.

---

## Incident 5 — Azure CLI Argument Error

**Symptom:** An Azure CLI command failed even though the option looked
correct.

**Investigation:** The command had been copied from formatted text, which
had replaced the ASCII hyphens with a typographic dash.

```text
Incorrect:  –-resource-group
Correct:    --resource-group
```

**Root cause:** Invalid characters in the command-line option.

**Resolution:** Retyped the command with standard ASCII hyphens.

**Result:** The command ran correctly.

**Lesson learned:** When a CLI reports an unexpected argument, check the
characters of copied commands, not just the syntax.

---

## Troubleshooting Method

All five incidents followed the same process:

```text
Detect
  |
  v
Observe error
  |
  v
Collect evidence
  |
  v
Identify layer
  |
  +--> Application
  +--> Operating system
  +--> Network
  +--> Azure platform
  +--> Subscription / quota
  +--> Deployment tool
  |
  v
Determine root cause
  |
  v
Apply controlled fix
  |
  v
Validate
  |
  v
Document lesson learned
```

---

## Troubleshooting Commands

**Linux**

```bash
sudo systemctl status nginx
sudo systemctl restart nginx
sudo apt-get update
curl http://localhost
sudo tail -n 50 /var/log/nginx/error.log
```

**Git**

```bash
git status
git remote -v
git log --oneline
```

**Azure CLI**

```bash
az account show
az group list --output table
az webapp list --output table
az vmss list-instances --name <scale-set> --resource-group <rg> --output table
az webapp log tail --name <web-app-name> --resource-group <rg>
```

**HTTP**

```bash
curl -I http://<application-endpoint>/
```

---

## Operational Principle

For every incident, a cloud engineer should be able to answer:

1. What failed?
2. Where did it fail?
3. Why did it fail?
4. What evidence supports the diagnosis?
5. What changed to resolve it?
6. How can recurrence be prevented?

---

## Skills Demonstrated

- Root-cause analysis
- Linux, Azure, Git and Azure CLI troubleshooting
- Incident response
- Problem isolation
- Cloud operations
- Technical documentation
