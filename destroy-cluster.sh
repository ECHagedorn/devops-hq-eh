#!/bin/bash
#
# !!!!!!!!!
#
# Take note that this script is destructive and may cause loss of work if used carelessly.
#
# !!!!!!!!!
#
# --- 1. Cleanup Existing K3s Setup ---
echo "--- Cleaning up existing K3s installation and its configuration files ---"

# 1.1 Stop K3s service gracefully
echo "Stopping K3s service if active..."
if sudo systemctl is-active --quiet k3s; then
    sudo systemctl stop k3s
    echo "K3s service stopped."
else
    echo "K3s service not active or not installed, skipping stop."
fi

# 1.2 Run the official K3s uninstall script
# This script handles the removal of K3s binaries, service files, and more.
if command -v k3s-uninstall.sh &> /dev/null; then
    echo "Running K3s uninstall script..."
    sudo /usr/local/bin/k3s-uninstall.sh
    echo "K3s uninstalled."
else
    echo "K3s uninstall script not found. Assuming K3s was not fully installed or already removed."
fi

# 1.3 Clean up K3s specific configuration files and persistent data
# This ensures a truly fresh start for K3s.
echo "Cleaning up K3s specific configuration files and data directories..."
sudo rm -f /etc/rancher/k3s/registries.yaml # Your custom registry config for K3s
sudo rm -f /etc/rancher/k3s/config.yaml    # K3s main configuration file
sudo rm -rf /var/lib/rancher/k3s/data      # K3s's persistent data directory (includes local etcd, volumes, etc.)
echo "K3s configuration and data cleaned."

echo "K3s cleanup phase complete. Tekton and local registry resources remain untouched."
sleep 5 # Give the system a moment
