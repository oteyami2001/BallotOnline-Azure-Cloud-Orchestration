#!/usr/bin/env bash
#
# Create the BallotOnline Azure App Service environment with Azure CLI:
# resource group, Linux App Service Plan, and a PHP web app with local
# Git deployment.
#
# Based on the Azure PaaS proof of concept (CCS670WebAppRG / CCS670WebAppTAO).
# No credentials are stored in this script. Sign in first with: az login
#
# Usage:
#   export WEB_APP_NAME=ballotonline-<your-unique-name>
#   ./deploy-app-service.sh
#
# Optional overrides: RESOURCE_GROUP, LOCATION, APP_SERVICE_PLAN, SKU, RUNTIME

set -euo pipefail

RESOURCE_GROUP="${RESOURCE_GROUP:-CCS670WebAppRG}"
LOCATION="${LOCATION:-westus3}"
APP_SERVICE_PLAN="${APP_SERVICE_PLAN:-CCS670WebAppPlan}"
SKU="${SKU:-B1}"
RUNTIME="${RUNTIME:-PHP:8.4}"
WEB_APP_NAME="${WEB_APP_NAME:-}"

if [ -z "$WEB_APP_NAME" ]; then
    echo "ERROR: WEB_APP_NAME must be set (it must be unique across Azure)." >&2
    echo "Example: export WEB_APP_NAME=ballotonline-your-unique-name" >&2
    exit 1
fi

if ! command -v az >/dev/null 2>&1; then
    echo "ERROR: Azure CLI (az) is not installed." >&2
    exit 1
fi

if ! az account show >/dev/null 2>&1; then
    echo "ERROR: Not signed in to Azure. Run 'az login' first." >&2
    exit 1
fi

echo "============================================"
echo " BallotOnline Azure App Service Deployment"
echo "============================================"

echo
echo "[1/4] Creating resource group $RESOURCE_GROUP in $LOCATION..."
az group create \
    --name "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --output none

echo
echo "[2/4] Creating Linux App Service Plan $APP_SERVICE_PLAN ($SKU)..."
az appservice plan create \
    --name "$APP_SERVICE_PLAN" \
    --resource-group "$RESOURCE_GROUP" \
    --location "$LOCATION" \
    --sku "$SKU" \
    --is-linux \
    --output none

echo
echo "[3/4] Creating web app $WEB_APP_NAME ($RUNTIME, local Git)..."
az webapp create \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --plan "$APP_SERVICE_PLAN" \
    --runtime "$RUNTIME" \
    --deployment-local-git \
    --output none

echo
echo "[4/4] Retrieving web app details..."
az webapp show \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query "{name:name, state:state, host:defaultHostName}" \
    --output table

GIT_URL="$(az webapp deployment source config-local-git \
    --name "$WEB_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --query url \
    --output tsv)"

echo
echo "============================================"
echo " Deployment completed."
echo "============================================"
echo
echo "Next steps:"
echo "1. Set deployment credentials (once per Azure account):"
echo "     az webapp deployment user set --user-name <unique-username>"
echo "2. Add the Git deployment remote:"
echo "     git remote add azure $GIT_URL"
echo "3. Push the application:"
echo "     git push azure main:master"
echo
echo "Site URL: https://$WEB_APP_NAME.azurewebsites.net"
