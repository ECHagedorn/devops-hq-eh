#!/bin/bash

# --- Configuration ---
K3S_KUBECONFIG_PATH="/etc/rancher/k3s/k3s.yaml"
USER_KUBECONFIG_DIR="/home/emmanuel/.kube"
USER_KUBECONFIG_PATH="/home/emmanuel/.kube/config" # Corrected line

TKN_VERSION="0.37.0"
TEKTON_PIPELINE_VERSION="0.60.0"
TEKTON_DASHBOARD_VERSION="0.45.0"
DASHBOARD_PORT="9097"

# --- Helper Function for Error Checking ---
check_command() {
    if [ $? -ne 0 ]; then
        echo "ERROR: $1 failed. Exiting."
        exit 1
    fi
}

# --- Cleanup Phase ---
echo "--- Starting Tekton Cleanup ---"
echo "1. Uninstalling Tekton Dashboard..."
kubectl delete --ignore-not-found -f "https://storage.googleapis.com/tekton-releases/dashboard/previous/v${TEKTON_DASHBOARD_VERSION}/release.yaml" &>/dev/null
# Give it a moment to start deletion
sleep 5
kubectl delete namespace tekton-pipelines --force --grace-period=0 --ignore-not-found &>/dev/null
echo "Dashboard uninstall commands sent. Namespace will be cleaned up."

echo "2. Uninstalling Tekton Pipelines core components..."
kubectl delete --ignore-not-found -f "https://storage.googleapis.com/tekton-releases/pipeline/previous/v${TEKTON_PIPELINE_VERSION}/release.yaml" &>/dev/null
# Give it a moment to start deletion
sleep 5
# Clean up any remaining CRDs related to Tekton if the namespace delete didn't get them all (less common for clean state)
# Note: Deleting CRDs will delete all associated custom resources (Pipelines, TaskRuns, etc.)
kubectl get crd -o name | grep "tekton.dev" | xargs -r kubectl delete &>/dev/null
echo "Pipelines uninstall commands sent. CRDs will be cleaned up."

echo "3. Removing tkn CLI binary..."
sudo rm -f /usr/local/bin/tkn
sudo rm -f /tmp/tkn # Ensure no leftover temporary files
echo "tkn CLI binary removed."

echo "4. Removing user's Kubeconfig file (if it exists)..."
rm -f "${USER_KUBECONFIG_PATH}"
echo "User's Kubeconfig removed."
echo "Cleanup complete. Waiting for resources to terminate (if any)."
# Give the cluster some time to clean up
sleep 10
echo "--- Cleanup Phase Complete ---"

# --- Installation Phase ---
echo "--- Starting Tekton Installation ---"
# Step 1: Ensure kubectl can access k3s (Re-establishing after potential kubeconfig removal)
echo "1. Configuring kubectl for k3s access..."
mkdir -p "${USER_KUBECONFIG_DIR}"
check_command "create ~/.kube directory"

# Copy k3s.yaml to user's config and set ownership/permissions
if [ -f "${K3S_KUBECONFIG_PATH}" ]; then
    sudo cp "${K3S_KUBECONFIG_PATH}" "${USER_KUBECONFIG_PATH}"
    check_command "copy k3s.yaml to user config"
    sudo chown "${USER}:${USER}" "${USER_KUBECONFIG_PATH}"
    check_command "change ownership of user kubeconfig"
    chmod 600 "${USER_KUBECONFIG_PATH}"
    check_command "set permissions on user kubeconfig"
    export KUBECONFIG="${USER_KUBECONFIG_PATH}"
    echo "KUBECONFIG set to ${KUBECONFIG}"
    hash -r # Clear kubectl cache

    echo "Verifying kubectl access to k3s..."
    kubectl get nodes
    check_command "kubectl get nodes check"
else
    echo "WARNING: k3s.yaml not found at ${K3S_KUBECONFIG_PATH}. K3s might not be installed or running."
    echo "Please ensure k3s is installed and running before proceeding."
    exit 1
fi

# Step 2: Install Tekton CLI (tkn)
echo "2. Installing Tekton CLI (tkn)..."
TKN_TARBALL_FILENAME="tkn_${TKN_VERSION}_Linux_x86_64.tar.gz"
TKN_DOWNLOAD_URL="https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/${TKN_TARBALL_FILENAME}"
TKN_LOCAL_PATH="/tmp/${TKN_TARBALL_FILENAME}"

echo "Downloading tkn CLI version ${TKN_VERSION} from: ${TKN_DOWNLOAD_URL}"
wget --quiet --show-progress "${TKN_DOWNLOAD_URL}" -O "${TKN_LOCAL_PATH}"
check_command "download tkn tarball"
if [ ! -s "${TKN_LOCAL_PATH}" ]; then
    echo "ERROR: Downloaded tkn tarball is empty or does not exist. Check URL or network."
    exit 1
else
    echo "tkn tarball downloaded. Size:"
    ls -lh "${TKN_LOCAL_PATH}"
fi
echo "Extracting tkn binary from tarball..."
tar -xzf "${TKN_LOCAL_PATH}" -C /tmp/
check_command "extract tkn binary"

if [ ! -f "/tmp/tkn" ]; then
    echo "ERROR: 'tkn' binary not found in extracted tarball. Extraction might have failed."
    exit 1
else
    echo "tkn binary extracted to /tmp/tkn. Size:"
    ls -lh /tmp/tkn
fi

chmod +x /tmp/tkn
check_command "chmod +x /tmp/tkn"

sudo mv /tmp/tkn /usr/local/bin/
check_command "mv /tmp/tkn /usr/local/bin/"

echo "Verifying tkn CLI installation..."
hash -r # Clear command hash cache
tkn version
check_command "tkn version check"
echo "tkn CLI installation complete. Version:"
tkn version | grep "Client version"
if ! command -v tkn &> /dev/null; then
    echo "ERROR: tkn CLI is not in the PATH. Please check the installation."
    exit 1
else
    echo "tkn CLI is successfully installed and in the PATH."
fi
echo "tkn CLI installation complete. Version:"
tkn version | grep "Client version"
echo "tkn CLI is successfully installed and in the PATH."
echo "tkn CLI installation complete. Version:"

# Step 3: Install Tekton Pipelines Core Components
echo "3. Installing Tekton Pipelines core components version ${TEKTON_PIPELINE_VERSION}..."
kubectl apply -f "https://storage.googleapis.com/tekton-releases/pipeline/previous/v${TEKTON_PIPELINE_VERSION}/release.yaml"
check_command "Tekton Pipelines core installation"

echo "Waiting for Tekton Pipelines pods to become ready (up to 5 minutes)..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/part-of=tekton-pipelines -n tekton-pipelines --timeout=300s
check_command "Tekton Pipelines pods ready check"

echo "Tekton Pipelines installation complete. Checking pods:"
kubectl get pods -n tekton-pipelines
check_command "kubectl get pods tekton-pipelines namespace"

echo "Verifying tkn client and pipeline versions:"
tkn version
check_command "tkn client and pipeline version check"

# Step 4: Install Tekton Dashboard (Optional but Recommended)
echo "4. Installing Tekton Dashboard version ${TEKTON_DASHBOARD_VERSION}..."
kubectl apply -f "https://storage.googleapis.com/tekton-releases/dashboard/previous/v${TEKTON_DASHBOARD_VERSION}/release.yaml"
check_command "Tekton Dashboard installation"

echo "Waiting for Tekton Dashboard pods to become ready (up to 5 minutes)..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/component=dashboard -n tekton-pipelines --timeout=300s
check_command "Tekton Dashboard pods ready check"

echo "Applying Pod Security Standards exemption to tekton-pipelines namespace..."
kubectl label namespace tekton-pipelines pod-security.kubernetes.io/enforce=privileged \
pod-security.kubernetes.io/enforce-version=latest \
pod-security.kubernetes.io/warn=privileged \
pod-security.kubernetes.io/warn-version=latest \
pod-security.kubernetes.io/audit=privileged \
pod-security.kubernetes.io/audit-version=latest --overwrite

echo "Tekton Dashboard installation complete. Checking pods:"
kubectl get pods -n tekton-pipelines -l app.kubernetes.io/component=dashboard
check_command "kubectl get pods tekton-pipelines dashboard"

echo "--- Tekton Installation Complete ---"

echo ""
echo "--- Accessing Tekton Dashboard ---"
echo "To access the Tekton Dashboard, open a new WSL 2 Ubuntu terminal (do NOT close this one)."
echo "In the NEW terminal, run the following command to forward the port:"
echo ""
echo "    kubectl port-forward svc/tekton-dashboard ${DASHBOARD_PORT}:${DASHBOARD_PORT} -n tekton-pipelines --address 0.0.0.0"
echo ""
echo "Then, open your web browser on Windows and navigate to: http://localhost:${DASHBOARD_PORT}"
echo ""
echo "Note: The port-forward command will keep the new terminal busy. Press Ctrl+C in that terminal to stop it."
echo "If you restart WSL, you will need to re-run this entire script, or at least the port-forward command in a new terminal."
