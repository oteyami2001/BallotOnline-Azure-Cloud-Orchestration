# 04 — Azure Load Balancer and Health Probe

## Overview

The BallotOnline VM Scale Set from [stage 03](03-vm-scale-set-load-balancer.md)
sits behind an Azure Load Balancer named `CCS670LB`.

Individual scale set instances do not have their own public IP addresses.
All incoming application traffic enters through the load balancer's
public frontend.

---

## Traffic Flow

```text
Internet
   |
   | HTTP :80
   v
Azure Load Balancer
CCS670LB
   |
   | Health-checked traffic
   |
   +-------------------+
   |                   |
   v                   v
VMSS Instance 1    VMSS Instance 2
Nginx :80          Nginx :80
```

---

## Load Balancer Components

| Component | Role |
|---|---|
| Frontend IP | Single public entry point for the BallotOnline site |
| Backend pool | The VM Scale Set instances |
| Load-balancing rule | Forwards TCP 80 from the frontend to port 80 on the backend pool |
| Health check | Decides which instances can receive traffic |

---

## Health Probe

| Setting  | Value |
|----------|-------|
| Protocol | HTTP  |
| Port     | 80    |
| Path     | `/`   |

Each instance is checked with an HTTP request to `/` on port 80. An
instance that answers successfully is healthy and receives traffic; one
that stops answering is taken out of rotation until it recovers.

This lets the platform tell whether an instance can actually serve the
application, not just whether the VM is powered on: if Nginx stops, the
instance fails the check even though the VM is still running.

---

## Security Design

Backend VM instances are not assigned public IP addresses:

```text
Internet
    X
    |   No direct access
    |
Backend VM


Internet
    |
    v
Load Balancer
    |
    v
Backend VM
```

The load balancer is the only public entry point for the BallotOnline
IaaS web tier.

---

## Verification

The deployment was validated by opening the load balancer's public IP
address in a browser. The BallotOnline application was returned from the
VM Scale Set backend.

Repeated browser requests were then generated while Azure Monitor
metrics were reviewed to observe the traffic.

The same check from the command line:

```bash
for i in $(seq 1 10); do
  curl -s -o /dev/null -w "%{http_code}\n" http://<load-balancer-public-ip>/
done
# Expected: 200 for every request
```

---

## Interview Summary

> "After validating the application on a single Azure VM, I captured the
> configured server as a reusable image in Azure Compute Gallery. I used
> that image to deploy a Virtual Machine Scale Set across availability
> zones, put an Azure Load Balancer in front of it, removed public IPs
> from the backend instances, and configured HTTP health monitoring on
> port 80. The proof of concept ran two Nginx instances and demonstrated
> a highly available, horizontally scalable web tier."
