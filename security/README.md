# BallotOnline Cloud Security

Summary of the security principles behind the BallotOnline Azure
architecture. The full write-up is in
[Security and Governance](../docs/10-security-governance.md).

## Security Principles

### 1. Minimize public exposure

Backend VM Scale Set instances have no public IP addresses. All traffic
enters through the load balancer.

### 2. Use strong administrative authentication

Linux administration uses SSH public keys; password login is disabled.

### 3. Protect credentials

Secrets and credentials are never committed to source control. The
repository uses placeholders and a security-focused `.gitignore`.

### 4. Use managed identity

Azure managed identities remove the need for embedded credentials when
workloads access supported Azure resources.

### 5. Apply defense in depth

```text
Identity
   |
Network
   |
Compute
   |
Operating System
   |
Application
   |
Data
```

### 6. Use least privilege

Users, applications and automation receive only the permissions they
need.

### 7. Monitor the environment

Security and reliability depend on visibility into resource behavior,
health, deployments and failures.

## Implemented in the Proof of Concept

- SSH public-key authentication
- Password authentication disabled
- Network Security Groups
- System-assigned managed identity
- Trusted Launch with Secure Boot and vTPM
- Backend VMSS instances without public IPs
- Sanitized public infrastructure templates
- Secrets excluded from Git

## Recommended Production Enhancements

These are future improvements, not claims about the original proof of
concept:

- Azure Key Vault
- Microsoft Defender for Cloud
- Azure Policy
- HTTPS-only application access
- Web Application Firewall
- Azure Bastion
- Private endpoints
- Centralized security logging
- Automated vulnerability scanning
- Microsoft Sentinel

## Reporting a Security Issue

If you find credentials or sensitive data in this repository, please
open an issue without including the sensitive value itself, and it will
be removed and rotated.
