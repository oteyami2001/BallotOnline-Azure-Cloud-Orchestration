# 02 — Azure Compute Gallery and Reusable VM Image

## Objective

After deploying and validating the BallotOnline web server in
[stage 01](01-azure-vm-deployment.md), this stage converts the configured
Azure Virtual Machine into a reusable machine image.

This creates a repeatable deployment model that can provision multiple
identical web servers.

---

## Architecture

```text
BOWebServer
Ubuntu + Nginx + BallotOnline
        |
        | Capture
        v
Azure Compute Gallery
        |
        v
670PoCImage
Version 0.0.1
        |
        v
Reusable Golden Image
        |
        +----------------+
        |                |
        v                v
   VM Instance      VM Instance
        |                |
        +-------+--------+
                |
                v
        Azure VM Scale Set
```

---

## Why Create a VM Image?

The original `BOWebServer` VM was manually configured with:

- Ubuntu Server
- Nginx
- BallotOnline website files
- Web server configuration
- Required Linux packages
- Startup configuration

Instead of repeating these steps for every new server, the configured VM
was captured as a reusable image. This follows the **golden image**
deployment pattern.

---

## Azure Compute Gallery

The image was stored in Azure Compute Gallery.

| Resource         | Configuration           |
|------------------|-------------------------|
| Source VM        | `BOWebServer`           |
| Image Gallery    | `670PoCGallery`         |
| Image Definition | `670PoCImage`           |
| Image Version    | `0.0.1`                 |
| Operating System | Linux / Ubuntu          |
| Workload         | BallotOnline web server |
| Web Server       | Nginx                   |
| Deployment Model | Reusable VM image       |

Azure Compute Gallery provides centralized image management and
versioning for reusable VM deployments.

---

## Image Creation Workflow

```text
Configured Azure VM
        |
        v
Validate Application
        |
        v
Export ARM Template
        |
        v
Capture VM
        |
        v
Azure Compute Gallery
        |
        v
Image Definition
        |
        v
Image Version 0.0.1
        |
        v
Reusable Infrastructure
```

---

## Infrastructure as Code

Before capturing the VM, its Azure Resource Manager (ARM) deployment
template was exported. The template is a declarative definition of the
VM infrastructure.

A sanitized version is published in this repository:

| File | Purpose |
|---|---|
| [`infrastructure/arm/vm-template.json`](../infrastructure/arm/vm-template.json) | ARM template for the Ubuntu web server VM |
| [`infrastructure/arm/parameters.example.json`](../infrastructure/arm/parameters.example.json) | Example parameter values with placeholders |

The template keeps the important settings from the exported original:

- Ubuntu 24.04 LTS image
- Standard SSD managed OS disk
- SSH-only authentication (password login disabled)
- System-assigned managed identity
- Trusted Launch with Secure Boot and vTPM
- Boot diagnostics

Excerpt:

```json
{
  "type": "Microsoft.Compute/virtualMachines",
  "apiVersion": "2024-03-01",
  "name": "[parameters('vmName')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  }
}
```

### Deploying the template

Copy the example parameters, fill in your own values, then deploy with
Azure CLI:

```bash
cp infrastructure/arm/parameters.example.json infrastructure/arm/parameters.json
# Edit parameters.json: set sshPublicKey and networkInterfaceId

az deployment group create \
  --resource-group <resource-group> \
  --template-file infrastructure/arm/vm-template.json \
  --parameters @infrastructure/arm/parameters.json
```

`parameters.json` is listed in `.gitignore` so real values are never
committed by accident.

### Sanitization

The public version of the template has been sanitized. These values are
intentionally excluded:

- Azure subscription IDs
- Resource-specific IDs (disks, network interfaces)
- SSH public keys
- Private keys
- Credentials
- Public IP addresses
- Other environment-specific identifiers

---

## Security

The source VM incorporated several security features:

- SSH public-key authentication
- Password authentication disabled
- System-assigned managed identity
- Trusted Launch
- Secure Boot
- Virtual TPM (vTPM)
- Azure Managed Disks

Sensitive infrastructure values are not stored in this repository.

---

## Benefits of the Golden Image Pattern

| Benefit | Why it matters |
|---|---|
| **Consistency** | Every VM created from the image starts with the same validated software configuration |
| **Faster provisioning** | Nginx and the BallotOnline application do not need to be installed on each instance |
| **Scalability** | The same image provisions every instance in an Azure VM Scale Set |
| **Repeatability** | The image combines with ARM templates and deployment automation |
| **Version control** | Gallery image versions allow controlled, reversible updates to the server image |

---

## Transition to VM Scale Sets

The reusable image becomes the foundation for the next stage:

```text
670PoCImage
     |
     v
Azure VM Scale Set
     |
 +---+---+
 |       |
 v       v
VM 1    VM 2
 |       |
 +---+---+
     |
     v
Azure Load Balancer
     |
     v
Internet
```

This moves the project from a single server to a highly available,
horizontally scalable web tier.

---

## Skills Demonstrated

- Azure Compute Gallery
- Azure VM images and image versioning
- Golden image architecture
- Azure Resource Manager (ARM) templates
- Infrastructure as Code
- Linux and Nginx
- Azure security (Trusted Launch, managed identity)
- Reusable infrastructure and cloud automation
