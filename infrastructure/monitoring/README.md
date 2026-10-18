# BallotOnline Azure Monitoring

Monitoring and observability strategy for the BallotOnline Azure
architecture. See [stage 07](../../docs/07-monitoring-autoscaling.md) for
what was monitored during the proof of concept.

## Monitored Components

```text
BallotOnline
    |
    +-- Azure VM Scale Set
    |       +-- Instance health
    |       +-- CPU utilization
    |       +-- Request activity
    |
    +-- Azure Load Balancer
    |       +-- Backend health
    |       +-- Traffic
    |
    +-- Azure App Service
            +-- HTTP requests
            +-- Response time
            +-- CPU
            +-- Errors
```

## Recommended Production Signals

| Signal | Purpose |
|---|---|
| Availability | Is BallotOnline reachable? |
| HTTP 5xx | Detect server-side failures |
| Response time | Detect application slowdowns |
| CPU | Identify compute pressure |
| Healthy hosts | Detect VM Scale Set capacity problems |
| Request count | Understand demand |
| Deployment status | Detect failed releases |

## Alerting Strategy

| Condition | Alert type |
|---|---|
| Application unavailable | Critical |
| HTTP 5xx errors increase | Application |
| Healthy VM count drops | Infrastructure |
| CPU stays high | Capacity |

Thresholds should be tuned against real workload baselines, not chosen
arbitrarily.

## Example Azure CLI Configuration

These commands show how the proposed strategy could be implemented. They
were not part of the original proof of concept.

### VM Scale Set autoscale

```bash
RG=<resource-group>
VMSS=670PoCScaleSet

# Autoscale profile: min 1, default 2, max 4
az monitor autoscale create \
  --resource-group "$RG" \
  --resource "$VMSS" \
  --resource-type Microsoft.Compute/virtualMachineScaleSets \
  --name ballotonline-vmss-autoscale \
  --min-count 1 --count 2 --max-count 4

# Scale out when average CPU > 70% for 5 minutes
az monitor autoscale rule create \
  --resource-group "$RG" \
  --autoscale-name ballotonline-vmss-autoscale \
  --condition "Percentage CPU > 70 avg 5m" \
  --scale out 1

# Scale in when average CPU < 30% for 5 minutes
az monitor autoscale rule create \
  --resource-group "$RG" \
  --autoscale-name ballotonline-vmss-autoscale \
  --condition "Percentage CPU < 30 avg 5m" \
  --scale in 1
```

### Alerts

```bash
# Action group that emails the on-call engineer
az monitor action-group create \
  --resource-group "$RG" \
  --name ballotonline-oncall \
  --action email oncall <email-address>

# High CPU on the scale set
az monitor metrics alert create \
  --resource-group "$RG" \
  --name vmss-high-cpu \
  --scopes "$(az vmss show -g "$RG" -n "$VMSS" --query id -o tsv)" \
  --condition "avg Percentage CPU > 80" \
  --window-size 5m --evaluation-frequency 1m \
  --action ballotonline-oncall

# HTTP 5xx errors on the web app
az monitor metrics alert create \
  --resource-group CCS670WebAppRG \
  --name webapp-http-5xx \
  --scopes "$(az webapp show -g CCS670WebAppRG -n <web-app-name> --query id -o tsv)" \
  --condition "total Http5xx > 10" \
  --window-size 5m --evaluation-frequency 1m \
  --action "$(az monitor action-group show -g "$RG" -n ballotonline-oncall --query id -o tsv)"
```

## Future Improvements

- Azure Monitor alert rules and action groups
- Log Analytics workspace
- Application Insights
- Availability (synthetic) tests
- Centralized dashboards
- Deployment alerts
- Automated remediation (for example, VM Scale Set automatic instance repairs)
