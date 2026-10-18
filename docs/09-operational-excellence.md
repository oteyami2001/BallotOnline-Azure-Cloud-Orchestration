# 09 — Operational Excellence

## Overview

The BallotOnline Azure proof of concept goes beyond deploying resources.
The architecture includes practices for:

- Availability
- Health management
- Repeatability
- Security
- Monitoring
- Scalability
- Cost awareness
- Troubleshooting
- Lifecycle management

---

## 1. Availability

The IaaS architecture removes the dependency on a single web server:

```text
                    Load Balancer
                         |
              +----------+----------+
              |                     |
              v                     v
          Instance 1            Instance 2
```

VM Scale Sets run multiple identical application instances, spread across
availability zones.

---

## 2. Health Management

HTTP health monitoring checks that each backend instance can serve
requests:

```text
HTTP GET /
    |
    v
Healthy?
 |      |
Yes     No
 |      |
Serve   Taken out of
traffic rotation
```

---

## 3. Repeatable Infrastructure

```text
ARM templates
     +
Azure Compute Gallery
     +
Shell automation
     +
Git
     |
     v
Repeatable deployment
```

| Mechanism | Role | In this repository |
|---|---|---|
| ARM templates | Describe infrastructure | [`infrastructure/arm/`](../infrastructure/arm/) |
| Azure Compute Gallery | Reusable, versioned VM images | [stage 02](02-azure-vm-image.md) |
| Shell scripts | Automate server and App Service setup | [`infrastructure/scripts/`](../infrastructure/scripts/) |
| Git | Version history and deployment | [stage 06](06-continuous-deployment.md) |

---

## 4. Security

Security controls demonstrated in the project:

- SSH public-key authentication with password login disabled
- Network Security Groups
- No public IPs on VM Scale Set backend instances
- System-assigned managed identity
- Trusted Launch with Secure Boot and virtual TPM
- Sanitized public ARM templates
- Secrets excluded from Git (`.gitignore`)

---

## 5. Monitoring

Both architectures are monitored:

| | IaaS | PaaS |
|---|---|---|
| Source | VM Scale Set | App Service |
| Signals | Instance health + metrics | Platform metrics |
| Tool | Azure Monitor | Azure Monitor |

See [stage 07](07-monitoring-autoscaling.md).

---

## 6. Scalability

Horizontal scaling is supported through:

- VM Scale Sets
- Load balancing
- App Service scale-out

Capacity can grow without changing the application's entry point.

---

## 7. Cost Awareness

The App Service Plan was temporarily scaled up from B1 to S2 to evaluate
advanced features, then returned to B1 after testing. Proof-of-concept
resources should not stay at production size once they are no longer
needed.

---

## 8. Troubleshooting

Operational failures were documented rather than hidden:

- Linux package repository failure
- Regional quota limitation
- Deployment username conflict
- Git authentication problem
- Azure CLI formatting error

See the [troubleshooting runbook](08-troubleshooting-runbook.md).

---

## 9. Infrastructure Lifecycle

```text
Plan --> Provision --> Configure --> Deploy --> Validate
                                                   |
                                                   v
        Retire <-- Update / Scale <-- Optimize <-- Monitor
```

---

## 10. IaaS vs. PaaS Operational Responsibility

| Responsibility            | Azure IaaS (VM Scale Set) | Azure App Service      |
|---------------------------|---------------------------|------------------------|
| Application code          | Customer                  | Customer               |
| Application configuration | Customer                  | Customer               |
| Web server                | Customer                  | Azure                  |
| Operating system patching | Customer                  | Azure                  |
| VM management             | Customer                  | Azure                  |
| Physical infrastructure   | Azure                     | Azure                  |
| Scaling configuration     | Customer                  | Customer (Azure executes) |
| Monitoring configuration  | Customer                  | Customer               |

Moving from IaaS to PaaS shifts much of the operational burden to Azure.

---

## Operational Goals

| Goal | Meaning |
|---|---|
| **Reliability** | Keep the application available |
| **Security** | Reduce exposure and protect credentials |
| **Performance** | Keep response times acceptable as load changes |
| **Cost** | Use only the capacity the workload needs |
| **Operations** | Make failures observable, diagnosable and recoverable |
| **Automation** | Reduce repetitive manual administration |

---

## Skills Demonstrated

- Operational excellence
- High availability and reliability engineering
- Cloud monitoring and autoscaling
- Incident response
- Infrastructure as Code
- Security engineering
- Cost optimization
- Cloud operations
