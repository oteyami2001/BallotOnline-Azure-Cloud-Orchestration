# 07 — Monitoring and Autoscaling

## Objective

Deploying cloud infrastructure is only part of running a reliable
application.

This stage covers monitoring the BallotOnline Azure environment,
observing application activity, evaluating scaling options, and
designing an operating model that can respond to changing workloads.

---

## Monitoring Architecture

### IaaS path

```text
                       Internet Users
                              |
                              v
                    Azure Load Balancer
                              |
                    +---------+---------+
                    |                   |
                    v                   v
              VMSS Instance 1     VMSS Instance 2
                    |                   |
                    +---------+---------+
                              |
                              v
                        Azure Monitor
                              |
              +---------------+---------------+
              |               |               |
              v               v               v
           Metrics         Health        Diagnostics
```

### PaaS path

```text
Internet Users
      |
      v
Azure App Service
      |
      v
App Service Metrics
      |
      v
Azure Monitor
```

---

## Monitoring the VM Scale Set

After deploying the VM Scale Set and Azure Load Balancer, repeated
requests were sent to the BallotOnline public endpoint and the scale
set's Monitoring tab was reviewed to observe resource and application
activity.

```text
Generate HTTP requests
         |
         v
Azure Load Balancer
         |
         v
VM Scale Set
         |
         v
Azure metrics
         |
         v
Analyze activity
```

Generating test traffic from the command line:

```bash
for i in $(seq 1 100); do
  curl -s -o /dev/null http://<load-balancer-public-ip>/
done
```

---

## Health Monitoring

The VM Scale Set uses application health monitoring:

| Setting  | Value |
|----------|-------|
| Protocol | HTTP  |
| Port     | 80    |
| Path     | `/`   |

```text
              Health check
                    |
               HTTP GET /
                    |
        +-----------+-----------+
        |                       |
        v                       v
    Instance 1              Instance 2
        |                       |
     Healthy?                Healthy?
        |                       |
        +-----------+-----------+
                    |
                    v
              Load Balancer
```

Unhealthy instances do not receive normal application traffic until they
become healthy again.

---

## Capacity Configuration

| Capacity | Instances |
|----------|-----------|
| Minimum  | 1         |
| Default  | 2         |
| Maximum  | 2         |

The limits were deliberately small for a proof of concept, but the
architecture provides the foundation for horizontal scaling.

---

## Production Autoscaling Strategy

A production environment would use metric-based autoscaling:

```text
                  Azure Monitor Metrics
                           |
             +-------------+-------------+
             |                           |
             v                           v
       CPU > threshold             CPU < threshold
             |                           |
             v                           v
         Scale out                   Scale in
             |                           |
             v                           v
       Add instance               Remove instance
```

| Condition | Action |
|---|---|
| Average CPU > 70% | Add a VM instance |
| Average CPU < 30% | Remove a VM instance |
| Normal workload | Keep current capacity |
| Instance unhealthy | Remove from traffic rotation |

> These thresholds are a proposed production design, not the exact
> autoscale rules used in the original proof of concept.

The Azure CLI commands to implement them are in
[`infrastructure/monitoring/`](../infrastructure/monitoring/).

---

## App Service Monitoring

The App Service deployment was monitored in the Azure portal while
requests were sent to the BallotOnline web app. App Service provides
metrics without anyone connecting to an operating system, which shows a
key difference between IaaS and PaaS:

**IaaS** — the team manages more layers:

```text
Application
    |
  Nginx
    |
  Ubuntu
    |
Virtual Machine
    |
Azure Infrastructure
```

**PaaS** — Azure manages more of the platform:

```text
Application
    |
Azure App Service
    |
Azure Infrastructure
```

---

## App Service Scaling Evaluation

The App Service Plan started on Basic B1. During the proof of concept it
was temporarily scaled up to Standard S2 to evaluate:

- Scale-out
- Autoscaling
- Deployment slots
- Backups
- Other production features

Afterwards the plan was returned to B1 to control cost.

---

## Operational Metrics

A production BallotOnline environment would track:

- HTTP request volume
- Response time
- CPU and memory utilization
- Healthy instance count
- Failed requests (HTTP 4xx and 5xx)
- Application availability
- Deployment failures
- Scale events

---

## Monitoring Goals

Monitoring should answer four questions:

1. Is the application available?
2. Is it performing normally?
3. Does the environment have enough capacity?
4. Is an operational response needed?

---

## Skills Demonstrated

- Azure Monitor
- VM Scale Set and App Service monitoring
- Application health monitoring
- Capacity management
- Horizontal scaling and autoscaling
- IaaS and PaaS operations
- Cloud observability
