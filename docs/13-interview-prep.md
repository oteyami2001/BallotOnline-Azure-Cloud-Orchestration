# 13 — Interview Preparation

## 30-Second Project Summary

> I designed and implemented an Azure proof of concept for BallotOnline
> using both IaaS and PaaS architectures.
>
> For IaaS, I deployed an Ubuntu VM running Nginx, captured it as a
> reusable Azure Compute Gallery image, and used that image to create a
> Virtual Machine Scale Set behind an Azure Load Balancer.
>
> For PaaS, I deployed the application to Azure App Service using Azure
> CLI and Git-based deployment.
>
> I also evaluated monitoring, scaling, security, troubleshooting,
> Infrastructure as Code, and AWS-to-Azure service equivalents.

---

## Architecture at a Glance

```text
                         BALLOTONLINE
                              |
                +-------------+-------------+
                |                           |
                v                           v
              IaaS                        PaaS
                |                           |
                v                           v
       Azure Load Balancer          Azure App Service
                |                     (PHP, Git deploy)
                v
     Virtual Machine Scale Set
                |
         +------+------+
         |             |
         v             v
       VM #1         VM #2
   Ubuntu/Nginx   Ubuntu/Nginx
         \             /
          \           /
     Azure Compute Gallery image
```

## Key Numbers and Names

| Item | Value |
|---|---|
| Original VM | `BOWebServer` (Ubuntu, Nginx) |
| Image | `670PoCImage` v0.0.1 in Azure Compute Gallery |
| Scale set | `670PoCScaleSet` — min 1, default 2, max 2 |
| Load balancer | `CCS670LB`, health check HTTP :80 `/` |
| Web app | `CCS670WebAppTAO` in `CCS670WebAppRG`, PHP 8.4, Basic B1 |
| Region | West US 3 (moved from East US due to quota) |

---

## Questions and Answers

### Why did you evaluate both IaaS and PaaS?

I wanted to compare the operational responsibilities of the two models,
not just compare cloud providers. IaaS gave more control over the
operating system and web server but required more administration. App
Service removed most of that work, so the deployment workflow could focus
on the application. ([ADR-001](adr/ADR-001-iaas-vs-paas.md))

### How did you make the IaaS environment scalable?

I captured the configured BallotOnline VM as a reusable Azure Compute
Gallery image, used that image for a Virtual Machine Scale Set, and put
an Azure Load Balancer in front of the instances. The proof of concept
ran two backend instances. ([ADR-002](adr/ADR-002-load-balanced-vmss.md))

### How did you provide high availability?

The scale set ran multiple instances across availability zones. The load
balancer spread HTTP traffic across them, and HTTP health monitoring on
port 80, path `/`, kept unhealthy instances out of rotation.

### Why use a golden image?

The original server already had a validated Ubuntu, Nginx and
BallotOnline configuration. Capturing it as an image gave a repeatable
starting point for every new instance and removed manual setup.

### How did you secure the environment?

SSH public-key authentication with password login disabled, Network
Security Groups, a system-assigned managed identity, and Trusted Launch
with Secure Boot and vTPM. The scale set instances had no public IP
addresses — all traffic came through the load balancer. In this public
repository, credentials and deployment-specific identifiers are removed
or parameterized.

### What problems did you run into?

Five real issues ([runbook](08-troubleshooting-runbook.md)):

1. **Nginx install failed with 404s** — stale APT package index;
   `apt-get update` fixed it.
2. **App Service Plan creation failed** — no regional quota in East US;
   moved to West US 3.
3. **Deployment username rejected** — deployment usernames must be unique
   across all of Azure; chose a different one.
4. **Git push authentication failed** — the remote URL still had the old
   username; fixed with `git remote set-url`.
5. **Azure CLI rejected a flag** — a typographic dash copied from a
   document instead of `--`; retyped it.

### What did you learn from those problems?

Cloud troubleshooting starts with finding which layer is actually failing
— application, OS, network, cloud platform, subscription quota,
authentication, deployment tooling or command syntax. I collect evidence
first, isolate the layer, find the root cause, apply a controlled fix,
and validate the result.

### How does the Azure architecture compare with AWS?

| AWS | Azure |
|---|---|
| EC2 | Azure Virtual Machines |
| AMI | Azure Compute Gallery image |
| Auto Scaling Group | VM Scale Set |
| Elastic Load Balancing | Azure Load Balancer |
| Elastic Beanstalk | Azure App Service |
| CloudWatch | Azure Monitor |
| IAM | Entra ID / Azure RBAC |
| CloudFormation | ARM / Bicep |

The biggest difference was workflow, not capability: Azure's scale set
wizard combines image, networking, load balancer and health settings in
one flow, where AWS configures them as separate services.
([comparison](11-aws-vs-azure.md))

### Why Azure App Service?

For web workloads that don't need OS-level control, App Service removes
most of the administrative overhead. Azure runs the platform and the team
focuses on deploying and configuring the application.

### What would you improve for production?

HTTPS-only access, a Web Application Firewall, Azure Key Vault, Azure
Policy, Microsoft Defender for Cloud, Application Insights and Log
Analytics, centralized alerting, deployment slots, a CI/CD pipeline, and
Azure Bastion instead of open SSH. I keep these clearly separate from
what the proof of concept actually implemented.
([security](10-security-governance.md))

### What was your recommendation?

Azure is technically viable for BallotOnline. Rather than an immediate
migration away from AWS, I recommended a focused Azure PaaS pilot as a
lower-risk way to evaluate operations, cost, security and team
familiarity.

### What would you do differently?

- Define the infrastructure as code from the start (Bicep or Terraform)
  instead of exporting templates from portal-built resources.
- Check regional quotas before choosing a region.
- Automate the image build (for example with Azure VM Image Builder) so
  new image versions don't require manual capture.

---

## Closing Statement

> The project wasn't just about learning individual Azure services. I
> evaluated how BallotOnline could operate under both IaaS and PaaS,
> implemented both architectures, troubleshot real deployment failures,
> compared their operational differences, and documented the decisions
> so another engineer could understand and reproduce the approach.

---

## Key Technologies

Microsoft Azure • Azure VM • VM Scale Sets • Azure Load Balancer •
Azure Compute Gallery • Azure App Service • Azure CLI • ARM •
Azure Monitor • Linux • Nginx • Git • GitHub Actions • IaaS • PaaS
