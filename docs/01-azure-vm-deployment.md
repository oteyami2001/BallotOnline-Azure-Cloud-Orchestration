# 01 — Azure VM and Nginx Web Server Deployment

## Objective

The first implementation stage of the BallotOnline Azure proof of concept
deploys the application on a manually managed Microsoft Azure Virtual Machine.

This establishes the baseline IaaS architecture before introducing
VM Scale Sets, load balancing, autoscaling, and Azure App Service.

---

## Architecture

```text
Internet User
     |
     | HTTP :80
     v
Public IP
     |
     v
Network Security Group
     |
     v
Azure Virtual Machine (BOWebServer)
     |
     +-- Ubuntu Server
     |
     +-- Nginx
     |
     +-- BallotOnline Website
```

---

## Azure Resources

| Component        | Configuration          |
|------------------|------------------------|
| Virtual Machine  | `BOWebServer`          |
| Cloud Platform   | Microsoft Azure        |
| Operating System | Ubuntu Server          |
| Web Server       | Nginx                  |
| Authentication   | SSH public key         |
| Web Protocol     | HTTP                   |
| HTTP Port        | 80                     |
| SSH Port         | 22                     |
| Managed Identity | System-assigned        |
| Storage          | Azure Managed Disk     |

---

## VM Provisioning

An Ubuntu-based Azure Virtual Machine named `BOWebServer` was provisioned
as the initial web server for the BallotOnline proof of concept.

SSH public-key authentication was used instead of password authentication.

Network Security Group rules permitted:

- TCP 22 for SSH administration
- TCP 80 for HTTP web traffic

A system-assigned managed identity was also enabled.

---

## Nginx Installation

After connecting to the server through SSH, the Ubuntu package index was
refreshed and Nginx was installed:

```bash
sudo apt-get update
sudo apt-get install -y nginx

sudo systemctl enable nginx
sudo systemctl start nginx
sudo systemctl status nginx
```

The same steps are automated in
[`infrastructure/scripts/install-nginx.sh`](../infrastructure/scripts/install-nginx.sh):

```bash
chmod +x install-nginx.sh
./install-nginx.sh
```

---

## BallotOnline Website Deployment

The BallotOnline website files were deployed to:

```text
/data/www/BallotOnline
```

Nginx was configured to use this directory as the website document root.

The configuration is in
[`infrastructure/nginx/nginx.conf`](../infrastructure/nginx/nginx.conf),
and a recreated version of the site is in [`website/`](../website/).

```text
Website Archive
      |
      v
Azure Ubuntu VM
      |
      v
/data/www/BallotOnline
      |
      v
Nginx
      |
      v
HTTP :80
      |
      v
Internet Users
```

---

## Troubleshooting

One of the most valuable parts of this deployment was troubleshooting an
Nginx installation failure.

| | |
|---|---|
| **Symptom** | `apt-get install nginx` returned `404 Not Found` for the Nginx packages |
| **Root cause** | The VM's local APT package index was stale and pointed to package versions no longer on the mirror |
| **Fix** | `sudo apt-get update` refreshed the package metadata, then `sudo apt-get install -y nginx` succeeded |

**Lesson:** a package installation failure does not necessarily mean the
package is unavailable. Repository metadata should be validated and
refreshed before changing the deployment architecture. This is why the
install script always runs `apt-get update` first.

---

## Verification

After Nginx was installed and configured, the deployment was tested by
opening the VM's public IP address in a web browser.

The BallotOnline homepage loaded successfully, confirming:

- VM network connectivity
- HTTP access through the Network Security Group
- Nginx operation
- Website file deployment
- Nginx document-root configuration

The same check can be run from the command line:

```bash
curl -I http://<vm-public-ip>/
# Expected: HTTP/1.1 200 OK  Server: nginx
```

---

## Security Considerations

The deployment incorporated several security controls:

- SSH public-key authentication
- Password authentication disabled
- Network Security Group rules
- Only the required service ports open (22 and 80)
- System-assigned managed identity
- Nginx worker processes running as a non-privileged user
- Azure Trusted Launch capabilities

No passwords, private SSH keys, subscription credentials, or other
secrets are stored in this repository.

---

## Skills Demonstrated

- Azure Virtual Machines
- Linux administration (Ubuntu)
- Nginx web server configuration
- SSH key-based access
- Network Security Groups and Azure networking
- Managed identities
- Linux package management
- Cloud troubleshooting
- IaaS deployment
