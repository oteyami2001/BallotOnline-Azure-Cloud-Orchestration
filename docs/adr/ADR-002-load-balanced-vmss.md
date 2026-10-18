# ADR-002 — Use a Load-Balanced Azure VM Scale Set

**Status:** Accepted

## Context

The first BallotOnline IaaS implementation used a single Azure Virtual
Machine ([stage 01](../01-azure-vm-deployment.md)).

That was enough to validate application compatibility, but a single VM is
a single point of failure and cannot demonstrate horizontal scaling.

---

## Decision

Use an Azure Virtual Machine Scale Set behind an Azure Load Balancer,
with instances built from a reusable Azure Compute Gallery image.

```text
                    Internet
                       |
                       v
              Azure Load Balancer
                       |
              +--------+--------+
              |                 |
              v                 v
          VMSS VM 1         VMSS VM 2
            Nginx             Nginx
```

### Configuration

| Setting | Value |
|---|---|
| Orchestration | Uniform |
| Instances | Minimum 1, default 2, maximum 2 |
| Availability | Multiple availability zones |
| Traffic | HTTP on port 80 |
| Health monitoring | HTTP on `/` |
| Load balancer | Azure Load Balancer (`CCS670LB`) |
| Backend public IPs | None |

---

## Alternatives Considered

| Option | Assessment |
|---|---|
| Single Azure VM | Simpler and cheaper, but a single point of failure |
| Azure App Service | Managed PaaS alternative; evaluated separately in [ADR-001](ADR-001-iaas-vs-paas.md) |
| **VM Scale Set + Load Balancer (chosen)** | Keeps VM-level control while demonstrating availability and horizontal scaling |

---

## Rationale

This architecture provides:

- Horizontal scaling
- Multiple application instances
- Centralized traffic distribution
- Health-aware routing
- Reusable, image-based provisioning
- Less direct exposure of backend servers

---

## Consequences

**Positive**

- Better application availability
- Repeatable instance provisioning
- Horizontal scaling capability
- Load-balanced traffic
- No public IP addresses needed on backend instances

**Negative**

- More architectural complexity
- Additional networking configuration
- More resources to monitor
- Higher potential cost than a single VM
- Application updates require a new image version and instance rollout

---

## Outcome

Two BallotOnline web server instances were deployed behind the Azure Load
Balancer. The application was reachable through the load-balanced public
endpoint, and monitoring confirmed request activity.

See [stage 03](../03-vm-scale-set-load-balancer.md) and
[stage 04](../04-load-balancer-health-probe.md).
