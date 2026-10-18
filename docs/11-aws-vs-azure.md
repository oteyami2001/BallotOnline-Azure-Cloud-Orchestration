# 11 — AWS vs. Microsoft Azure Architecture Comparison

## Objective

BallotOnline already ran workloads on AWS. This proof of concept evaluated
whether Microsoft Azure offers comparable IaaS, PaaS, scaling, operations
and governance capabilities.

---

## Service Mapping

| Capability | AWS | Microsoft Azure |
|---|---|---|
| Virtual compute | Amazon EC2 | Azure Virtual Machines |
| Machine images | AMI | Azure Compute Gallery images |
| Auto scaling | Auto Scaling Groups | VM Scale Sets |
| Load balancing | Elastic Load Balancing | Azure Load Balancer |
| PaaS web hosting | Elastic Beanstalk | Azure App Service |
| Identity | AWS IAM | Microsoft Entra ID / Azure RBAC |
| Firewall rules | Security Groups | Network Security Groups |
| Monitoring | Amazon CloudWatch | Azure Monitor |
| Recommendations | AWS Trusted Advisor | Azure Advisor |
| Operations | AWS Systems Manager | Azure Automation / Azure Arc |
| Infrastructure as Code | CloudFormation | ARM templates / Bicep |
| Object storage | Amazon S3 | Azure Blob Storage |

---

## IaaS Comparison

**AWS**

```text
AMI
 |
 v
Launch Template
 |
 v
Auto Scaling Group
 |
 v
EC2 Instances
 |
 v
Elastic Load Balancer
```

**Azure**

```text
Azure Compute Gallery
 |
 v
VM Image
 |
 v
VM Scale Set
 |
 v
VM Instances
 |
 v
Azure Load Balancer
```

Both platforms provide everything needed for a highly available,
horizontally scaled web application.

### Workflow difference

The biggest difference observed during the proof of concept was
**workflow, not capability**.

AWS exposes the building blocks as more distinct services, each
configured separately:

```text
AMI + Launch Template + Auto Scaling Group + Load Balancer
```

Azure's VM Scale Set wizard combines several of these decisions into one
provisioning flow:

```text
Image
   |
VM Scale Set wizard
   |
   +-- Instance count
   +-- Networking
   +-- Load balancer
   +-- Health monitoring
   +-- Scaling
```

The Azure workflow means fewer separate configuration steps; the AWS
approach makes each infrastructure component more explicit.

---

## PaaS Comparison

```text
AWS:    Application --> Elastic Beanstalk
Azure:  Application --> Azure App Service
```

Both provide managed application hosting that reduces infrastructure
administration for the application team.

---

## Identity

**AWS IAM**

```text
IAM
 +-- Users
 +-- Roles
 +-- Policies
```

**Azure**

```text
Microsoft Entra ID
 +-- Identities
 +-- RBAC role assignments
 +-- Managed identities
```

The proof of concept used an Azure system-assigned managed identity on
the VM — the Azure counterpart of attaching an IAM role to an EC2
instance.

---

## Monitoring

```text
AWS:    Resources --> CloudWatch    --> Metrics / Logs / Alarms
Azure:  Resources --> Azure Monitor --> Metrics / Logs / Alerts
```

The BallotOnline proof of concept used Azure monitoring views to observe
resource and application activity.

---

## Infrastructure as Code

The declarative IaC approach carries across both platforms:

```text
             Infrastructure as Code
                       |
             +---------+---------+
             |                   |
             v                   v
            AWS                Azure
             |                   |
       CloudFormation       ARM / Bicep
             |                   |
             +---------+---------+
                       |
                       v
                   Terraform
            (one workflow for both)
```

---

## Key Differences Observed

| Area | AWS | Azure |
|---|---|---|
| Scaling setup | Separate launch template, ASG and load balancer | One VM Scale Set wizard covering image, networking, load balancer and health |
| Resource organization | Tags and accounts | Resource groups as a first-class container, plus tags and subscriptions |
| Identity model | IAM users, roles and policies per account | Entra ID tenant with RBAC across subscriptions |
| IaC format | CloudFormation (JSON/YAML) | ARM (JSON) or Bicep |

The services differ in terminology and workflow, but the underlying
architecture principles transfer directly.

---

## Recommendation

The proof of concept showed that Azure can meet BallotOnline's web
hosting requirements with both IaaS and PaaS.

Rather than treating AWS and Azure as either/or, the lower-risk strategy
is a focused Azure pilot for workloads where managed PaaS gives clear
operational advantages, while keeping the existing AWS core:

```text
Existing AWS environment
          |
          +----------------------+
          |                      |
          v                      v
   Core workloads           Azure pilot
   (stay on AWS)                 |
                                 v
                         Azure App Service
                                 |
                                 v
                    Evaluate operations, cost,
                    security and team familiarity
```

This tests Azure without committing to an immediate full migration.

See [ADR-001](adr/ADR-001-iaas-vs-paas.md) for the related IaaS vs. PaaS
decision.

---

## Skills Demonstrated

- AWS and Microsoft Azure
- Multi-cloud architecture
- IaaS and PaaS
- Cloud migration planning
- Infrastructure as Code
- Cloud governance
- Architecture evaluation and technology comparison
