#!/usr/bin/env bash
#
# Bootstrap script for BallotOnline VM Scale Set instances.
# Runs as root at first boot (passed to the scale set as custom data).
#
# Instances are built from 670PoCImage, which already contains Nginx,
# so this mainly makes sure the service is enabled and running.

set -euo pipefail

echo "Starting BallotOnline VMSS bootstrap..."

# Install Nginx only if the image does not already have it.
if ! command -v nginx >/dev/null 2>&1; then
    echo "Nginx not found. Installing..."
    # Refresh the package index first to avoid stale-index 404 errors.
    apt-get update
    apt-get install -y nginx
fi

# Start Nginx now and on every boot.
systemctl enable nginx
systemctl restart nginx

# Fail the bootstrap if Nginx is not running.
systemctl is-active --quiet nginx

echo "Nginx is running."
echo "BallotOnline VMSS bootstrap completed successfully."
