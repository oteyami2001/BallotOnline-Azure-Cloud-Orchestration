#!/usr/bin/env bash
#
# Install and start Nginx on an Ubuntu Azure VM.
# Used for the BallotOnline BOWebServer deployment.
#
# Usage: ./install-nginx.sh

set -euo pipefail

echo "Updating Ubuntu package index..."
# Always refresh first: a stale index caused '404 Not Found' errors
# when installing Nginx during the original deployment.
sudo apt-get update

echo "Installing Nginx..."
sudo apt-get install -y nginx

echo "Enabling Nginx to start on boot..."
sudo systemctl enable nginx

echo "Starting Nginx..."
sudo systemctl start nginx

echo "Checking Nginx status..."
sudo systemctl --no-pager status nginx

echo "Nginx installation completed successfully."
