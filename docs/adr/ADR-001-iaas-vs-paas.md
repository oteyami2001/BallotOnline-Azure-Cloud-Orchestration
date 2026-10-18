# ADR-001 — Evaluate PaaS Alongside IaaS

**Status:** Accepted

## Context

BallotOnline needed an evaluation of Microsoft Azure for hosting its web
application. Two operating models were available:

1. **Infrastructure as a Service** using Azure Virtual Machines
2. **Platform as a Service** using Azure App Service

IaaS gives more control over the operating system and web server but
requires more administration. PaaS reduces infrastructure management.

---

## Decision

Implement **both** architectures as part of the proof of concept.

**IaaS**

```text
Load Balancer
     |
VM Scale Set
     |
Ubuntu
     |
Nginx
     |
BallotOnline
```

**PaaS**

```text
Azure App Service
       |
  BallotOnline
```

---

## Alternatives Considered

| Option | Why not chosen |
|---|---|
| IaaS only | Would show control but give no evidence about PaaS operating effort |
| PaaS only | Simpler, but would not test whether Azure could replace BallotOnline's existing VM-based setup |
| **Both (chosen)** | Gives a side-by-side, evidence-based comparison |

---

## Rationale

Building both models gives direct evidence for comparing:

- Deployment effort
- Infrastructure control
- Scaling
- Monitoring
- Operational responsibility
- Troubleshooting
- Automation

---

## Consequences

**Positive**

- Evidence-based architecture comparison
- Demonstrates both Azure IaaS and PaaS
- Shows how operational responsibility shifts between service models
- Keeps options open for future workloads

**Negative**

- Two deployment models to build and document
- IaaS requires more operating-system and web-server administration
- PaaS gives less low-level infrastructure control

---

## Outcome

Both architectures successfully hosted BallotOnline.

For a relatively simple web workload, Azure App Service had noticeably
lower management overhead: no web server installation, OS patching or
image management. VM-based IaaS remains the right choice when OS-level
control or custom server configuration is required.

The comparison also showed that the choice between **IaaS and PaaS**
affects day-to-day operations more than the choice between **Azure and
AWS** (see [AWS vs. Azure](../11-aws-vs-azure.md)).
