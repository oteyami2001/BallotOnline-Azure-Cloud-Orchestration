# 03 — Azure VM Scale Set, Load Balancer, and High Availability

## Objective

This stage moves the BallotOnline Azure deployment from a single server
to a highly available, horizontally scalable web tier.

The reusable BallotOnline image created in
[stage 02](02-azure-vm-image.md) is the source image for an Azure Virtual
Machine Scale Set. An Azure Load Balancer spreads incoming HTTP requests
across multiple Nginx web server instances.

---

## Architecture

```text
                         Internet
                            |
                            | HTTP :80
                            v
                  +---------------------+
                  | Azure Load Balancer |
                  |      CCS670LB       |
                  +----------+----------+
                             |
                      Health Probe
                        HTTP /
                        Port 80
                             |
                  +----------+----------+
                  |                     |
                  v                     v
          +---------------+     +---------------+
          | VMSS Instance |     | VMSS Instance |
          |      #1       |     |      #2       |
          | Ubuntu/Nginx  |     | Ubuntu/Nginx  |
          +---------------+     +---------------+
                  |                     |
                  +----------+----------+
                             |
                             v
                   Azure VM Scale Set
                     670PoCScaleSet
                             |
                             v
                   Azure Compute Gallery
                             |
                             v
                        670PoCImage
```

---

## VM Scale Set Configuration

| Setting            | Configuration     |
|--------------------|-------------------|
| Scale Set          | `670PoCScaleSet`  |
| Region             | West US 3         |
| Availability       | Availability zones |
| Orchestration      | Uniform           |
| Source Image       | `670PoCImage`     |
| Minimum Instances  | 1                 |
| Default Instances  | 2                 |
| Maximum Instances  | 2                 |
| OS Disk            | Standard SSD      |
| Authentication     | SSH public key    |
| HTTP               | TCP 80            |
| Instance Public IP | Disabled          |
| Load Balancer      | `CCS670LB`        |
| Health Protocol    | HTTP              |
| Health Port        | 80                |
| Health Path        | `/`               |

---

## Why Use a VM Scale Set?

A single virtual machine is a single point of failure. A VM Scale Set
runs multiple identical VM instances as one logical compute tier.

Benefits include:

- Horizontal scaling
- Consistent server configuration
- Automated instance provisioning
- Integration with Azure Load Balancer
- Health monitoring
- Instance replacement
- Availability-zone distribution
- Less manual server management

---

## Golden Image Deployment

The scale set uses the BallotOnline image captured in stage 02:

```text
BOWebServer
     |
     | Capture
     v
Azure Compute Gallery
     |
     v
670PoCImage
     |
     v
670PoCScaleSet
     |
 +---+---+
 |       |
 v       v
VM 1    VM 2
```

Every new instance starts from the same validated server configuration.

---

## High Availability

The scale set was deployed across multiple Azure availability zones.

Individual scale set instances do **not** get their own public IP
addresses. All external traffic enters through the Azure Load Balancer:

```text
Internet
   |
   v
Public Frontend IP
   |
   v
Azure Load Balancer
   |
   +----------------+
   |                |
   v                v
VMSS Instance 1  VMSS Instance 2
```

This reduces direct exposure of the backend servers and gives the
application a single, central entry point.

---

## Azure Load Balancer

An Azure Load Balancer named `CCS670LB` sits in front of the scale set
and spreads incoming HTTP traffic across healthy backend instances:

```text
              Client Requests
                    |
                    v
             CCS670LB :80
                    |
             +------+------+
             |             |
             v             v
          VM #1          VM #2
          Nginx          Nginx
```

The application no longer depends on a single web server. See
[stage 04](04-load-balancer-health-probe.md) for the load balancer and
health probe details.

---

## Health Monitoring

Application health monitoring was configured with:

```text
Protocol: HTTP
Port:     80
Path:     /
```

```text
Health check
       |
       | HTTP GET /
       v
VMSS Instance
       |
   +---+---+
   |       |
Healthy  Unhealthy
   |       |
   v       v
Receives  Taken out of
traffic   rotation
```

Health monitoring keeps application traffic away from instances that
cannot serve the site.

---

## Scaling Configuration

The proof-of-concept scaling limits were:

```text
Minimum:  1
Default:  2
Maximum:  2
```

The low maximum suited the proof-of-concept environment (and its regional
compute quota) while still demonstrating a multi-instance deployment.

A production architecture would raise these limits and add metric-based
autoscale rules, for example:

| Condition | Action |
|---|---|
| Average CPU > 70% | Scale out by one instance |
| Average CPU between 30% and 70% | Keep current capacity |
| Average CPU < 30% | Scale in by one instance |

---

## Instance Bootstrap

A bootstrap script was supplied so that Nginx is running whenever Azure
provisions or replaces an instance. The lab used this minimal version:

```bash
#!/bin/bash
systemctl enable nginx
systemctl start nginx
```

A more robust version that installs Nginx if it is missing and verifies
the service is in
[`infrastructure/scripts/vmss-user-data.sh`](../infrastructure/scripts/vmss-user-data.sh).

---

## Infrastructure as Code

[`infrastructure/arm/vmss-template.json`](../infrastructure/arm/vmss-template.json)
is a sanitized ARM template for the scale set. It captures the
configuration above: gallery image source, Uniform orchestration,
availability zones, Standard SSD disks, SSH-only login, no instance public
IPs, load balancer backend pool membership, the application health
extension (HTTP, port 80, `/`) and the bootstrap script.

> **Note:** The scale set was built through the Azure portal. This
> template is a sanitized reconstruction of that configuration for this
> portfolio, not the original portal-exported file.

Example deployment:

```bash
az deployment group create \
  --resource-group <resource-group> \
  --template-file infrastructure/arm/vmss-template.json \
  --parameters \
      sshPublicKey="$(cat ~/.ssh/id_rsa.pub)" \
      imageVersionResourceId=<gallery-image-version-id> \
      subnetResourceId=<subnet-id> \
      loadBalancerBackendPoolId=<backend-pool-id> \
      customData="$(base64 -w0 infrastructure/scripts/vmss-user-data.sh)"
```

---

## Network Security

Backend application servers should not need direct Internet exposure
when traffic can enter through a controlled load-balancing layer.

The VM Scale Set therefore uses:

- Load-balanced HTTP access
- No public IP on individual instances
- SSH public-key authentication
- Network Security Group controls
- Azure-managed health monitoring
- Trusted, reusable VM images

---

## Deployment Verification

After deployment, Azure provisioned two VM instances behind the load
balancer. The application was tested through the load balancer's public
frontend IP:

```text
Browser
   |
   v
Load Balancer Public IP
   |
   v
CCS670LB
   |
   +---------+
   |         |
   v         v
VM #1      VM #2
   |         |
   +----+----+
        |
        v
BallotOnline
```

The BallotOnline homepage loaded successfully through the load balancer.

---

## Monitoring

Repeated browser requests were sent to the load-balanced public endpoint,
and Azure Monitor metrics were reviewed to confirm application traffic
and resource activity across the multi-instance deployment.

---

## IaaS Evolution

```text
STAGE 01
Single Azure VM
       |
       v
STAGE 02
Reusable Golden Image
       |
       v
STAGE 03
VM Scale Set
  + Azure Load Balancer
  + Health Monitoring
       |
       v
Highly Available Web Tier
```

---

## AWS Equivalent Architecture

| Microsoft Azure             | Amazon Web Services        |
|-----------------------------|----------------------------|
| Azure VM                    | Amazon EC2                 |
| Azure Compute Gallery image | Amazon Machine Image (AMI) |
| VM Scale Set                | Auto Scaling Group         |
| Azure Load Balancer         | Elastic Load Balancing     |
| Azure Monitor               | Amazon CloudWatch          |
| Network Security Group      | Security Group             |

Knowing these equivalents shows transferable multi-cloud architecture
knowledge.

---

## Skills Demonstrated

- Azure Virtual Machine Scale Sets
- Azure Load Balancer and health probes
- High availability and horizontal scaling
- Azure Compute Gallery and golden images
- Linux and Nginx
- Azure networking and Network Security Groups
- Azure Monitor
- Infrastructure as Code
- Cloud automation
- Multi-cloud architecture
