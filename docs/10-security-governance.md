# 10 — Security and Governance

## Overview

Security was built into the BallotOnline Azure proof of concept from the
start rather than added as a final step.

The architecture applies controls across identity, compute, networking,
deployment, and source control. Each section below separates what was
**implemented in the proof of concept** from what is **recommended for
production**.

---

## Security Architecture

```text
                       Internet
                          |
                          v
                +-------------------+
                |    Azure Load     |
                |     Balancer      |
                +---------+---------+
                          |
                    HTTP :80 only
                          |
             +------------+------------+
             |                         |
             v                         v
       VMSS Instance 1           VMSS Instance 2
       No public IP              No public IP
             |                         |
             +------------+------------+
                          |
                   Private backend
```

Individual VM Scale Set instances are not exposed through their own
public IP addresses.

---

## Defense in Depth

```text
Identity                 Microsoft Entra ID, Azure RBAC, managed identity
   |
Network                  NSGs, load balancer front end, no backend public IPs
   |
Compute                  Trusted Launch, Secure Boot, vTPM
   |
Operating system         SSH keys only, password login disabled
   |
Application              Nginx / App Service runtime
   |
Source and deployment    Sanitized templates, .gitignore, no secrets in Git
```

A failure at one layer should not automatically compromise every other
layer.

---

## 1. Identity and Access Management

Microsoft Entra ID and Azure role-based access control (RBAC) provide the
identity and authorization foundation for Azure resources.

The proof-of-concept VM used a **system-assigned managed identity**,
which lets the VM authenticate to supported Azure services without
credentials embedded in scripts:

```text
Azure VM
   |
Managed identity
   |
   v
Microsoft Entra ID
   |
   v
Authorized Azure resource
```

---

## 2. SSH Security

The Linux VM used SSH public-key authentication, and password
authentication was disabled:

```text
Administrator
     |
     | SSH private key (never leaves the admin's machine)
     v
Azure VM
     |
Public key validation
     |
     v
Access granted
```

This avoids reusable administrative passwords. Private SSH keys must
never be committed to Git.

---

## 3. Trusted Launch

The VM used Azure Trusted Launch, which includes:

- **Secure Boot** — only signed boot loaders and kernels can start
- **Virtual TPM (vTPM)** — hardware-style key storage and boot measurements

Together these protect the VM against boot-level malware and rootkits.

---

## 4. Network Security

Network Security Groups (NSGs) control permitted traffic:

| Traffic | Port | Purpose | PoC | Production recommendation |
|---|---|---|---|---|
| HTTP | 80 | Web application | Open | Redirect to HTTPS (443) |
| SSH | 22 | Administration | Open | Restrict to approved IPs, or close and use Azure Bastion |

---

## 5. Backend Isolation

VM Scale Set instances were deployed without public IP addresses, so
traffic follows:

```text
Internet --> Load Balancer --> Backend VMSS instances
```

rather than:

```text
Internet --> VM 1 public IP
Internet --> VM 2 public IP
```

This removes unnecessary direct exposure of backend compute.

---

## 6. Secrets Management

This public repository must never contain:

- Azure passwords
- Private SSH keys
- Access tokens
- Publishing passwords
- Service principal secrets
- Connection strings
- API keys
- Real deployment credentials

The repository uses placeholders instead, for example:

```text
REPLACE_WITH_YOUR_SSH_PUBLIC_KEY
```

In production, secrets belong in a secrets-management service such as
Azure Key Vault.

---

## 7. Infrastructure as Code Security

The ARM templates in [`infrastructure/arm/`](../infrastructure/arm/) are
sanitized. Environment-specific values are supplied through parameters
rather than hardcoded:

```text
ARM template
     |
     +--> Infrastructure definition (public)
     |
     +--> Parameters
             |
             +--> Environment values (kept out of Git)
```

This improves portability and reduces the risk of exposing
deployment-specific information.

---

## 8. Source Control Security

The repository's [`.gitignore`](../.gitignore) blocks accidental commits
of:

- `.env` files
- SSH keys and certificates
- Azure CLI local configuration
- App Service publish profiles
- Terraform state
- Logs

`.gitignore` is not a replacement for credential scanning (for example,
GitHub secret scanning) or proper secret management.

---

## 9. Governance

Cloud governance defines how resources are created, controlled,
monitored and retired. A production governance model should cover:

- Resource naming
- Required tags
- Approved regions
- Identity and RBAC
- Cost ownership
- Resource lifecycle
- Logging
- Security baselines
- Backup requirements
- Compliance requirements

### Example tagging strategy

| Tag | Example |
|---|---|
| Application | BallotOnline |
| Environment | Production |
| Owner | CloudEngineering |
| CostCenter | IT |
| ManagedBy | IaC |
| Criticality | High |

Tags improve cost attribution, inventory, automation and governance.
Azure Policy can require them on every new resource.

---

## 10. Least Privilege

Users, workloads and automation should receive only the permissions they
need:

```text
User / workload
      |
      v
Only required permissions (e.g. Website Contributor, not Owner)
      |
      v
Only required resources (e.g. one resource group, not the subscription)
```

---

## 11. Production Security Improvements

These are **recommended enhancements**, not all of which were implemented
in the original proof of concept:

| Improvement | Benefit |
|---|---|
| Azure Key Vault | Central, audited secret storage |
| Azure Policy | Enforce tags, regions and security baselines |
| Microsoft Defender for Cloud | Security posture and threat detection |
| Application Gateway with WAF | Protection against common web attacks |
| HTTPS-only enforcement | Encrypted traffic |
| Azure Bastion | SSH without exposing port 22 |
| Private endpoints | Keep service traffic off the public internet |
| Log Analytics + Microsoft Sentinel | Centralized security logging and SIEM |
| Managed identities for app dependencies | No stored credentials |
| Automated security scanning in CI/CD | Catch issues before deployment |

See also [`security/`](../security/).

---

## Skills Demonstrated

- Azure security
- Microsoft Entra ID and Azure RBAC
- Managed identity
- Network Security Groups
- Trusted Launch, Secure Boot and vTPM
- Least privilege
- Secrets management
- Cloud governance
- Defense in depth
