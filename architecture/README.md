# Architecture

![BallotOnline Azure cloud architecture](ballotonline-azure-architecture.svg)

| File | Description |
|---|---|
| [`ballotonline-azure-architecture.svg`](ballotonline-azure-architecture.svg) | Main architecture diagram (vector, used in the README) |
| [`ballotonline-azure-architecture.png`](ballotonline-azure-architecture.png) | Same diagram as a PNG, for slides, LinkedIn or documents |

## IaaS path

| Component | Role in the project |
|---|---|
| Ubuntu VM + Nginx | Original web server hosting the BallotOnline website |
| Azure Compute Gallery | Stores the image captured from the original VM |
| Custom VM image | Reusable Ubuntu + Nginx + website image |
| VM Scale Set | Runs two identical instances built from the custom image |
| Azure Load Balancer (`CCS670LB`) | Spreads HTTP traffic across instances, health probe on port 80 |
| Azure Monitor | Instance health, metrics and autoscale signals |

Request flow: **Internet users → Load Balancer → healthy VM instance → Nginx → BallotOnline website**

## PaaS path

| Component | Role in the project |
|---|---|
| Developer | Maintains the BallotOnline PHP source code |
| Azure CLI | Creates the App Service plan, web app and deployment user |
| Git push | Sends code to the App Service Git deployment remote |
| Azure App Service | Runs the PHP site with managed scaling and monitoring |

Deployment flow: **Developer → Azure CLI setup → git push → App Service builds and deploys → live website**

## IaaS vs. PaaS

| | IaaS (VM Scale Set) | PaaS (App Service) |
|---|---|---|
| Server management | You manage the OS, Nginx and image | Azure manages the platform |
| Scaling | Scale Set instances behind a load balancer | Built-in App Service scaling |
| Deployment | Bake changes into a new VM image | `git push` |
| Control | Full control of the VM | Limited to the app and its settings |
| Best for | Custom server setups and lift-and-shift | Fast delivery of standard web apps |
