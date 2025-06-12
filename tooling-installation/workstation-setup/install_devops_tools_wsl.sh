#!/bin/bash

# --- Configuration Variables (UPDATE THESE!) ---
# Check GitHub releases for the latest versions
K9S_VERSION="0.32.4"    # Example: Check https://github.com/derailed/k9s/releases
NERDCTL_VERSION="1.7.0" # Example: Check https://github.com/containerd/nerdctl/releases
TF_VERSION="1.8.5"      # Example: Check https://developer.hashicorp.com/terraform/downloads

# --- Helper Function for Error Handling ---
check_command() {
    if [ $? -ne 0 ]; then
        echo "ERROR: $1 failed. Exiting."
        exit 1
    fi
}

echo "--- Starting DevOps Tools Installation in WSL Ubuntu ---"

# Step 1: Update Ubuntu System Packages
echo "1. Updating Ubuntu system packages..."
sudo apt update -y
check_command "apt update"
sudo apt upgrade -y
check_command "apt upgrade"

# Step 2: Install k3s (includes containerd and kubectl)
echo "2. Installing k3s (this includes containerd and kubectl)..."
curl -sfL https://get.k3s.io | sh -
check_command "k3s installation"
echo "Waiting for k3s service to start (60 seconds)..."
sleep 60
sudo systemctl status k3s --no-pager || echo "k3s service status check may fail if still starting, verify later."
check_command "k3s service status check" # This might be flaky, but good to have a check.

# Step 2: Install k3s (includes containerd and kubectl)
echo "2. Installing k3s (this includes containerd and kubectl)..."
curl -sfL https://get.k3s.io | sh -
check_command "k3s installation"
echo "Waiting for k3s service to start (60 seconds)..."
sleep 60
sudo systemctl status k3s --no-pager || echo "k3s service status check may fail if still starting, verify later."
check_command "k3s service status check" # This might be flaky, but good to have a check.

# FIX: Adjust Kubeconfig Permissions for kubectl
echo "Adjusting k3s.yaml permissions for current user..."
# Make the kubeconfig file readable by the owner (which is usually root by default, but we'll use sudo)
sudo chmod 644 /etc/rancher/k3s/k3s.yaml
# Ensure the KUBECONFIG environment variable is set for the current session
# and also for future sessions in .bashrc if it's not already handled by k3s installer
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
# Optionally, add to .bashrc for persistence (k3s installer often does this, but good to ensure)
grep -qxF 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' ~/.bashrc || echo 'export KUBECONFIG=/etc/rancher/k3s/k3s.yaml' >> ~/.bashrc
echo "KUBECONFIG environment variable set to: $KUBECONFIG"

# Verify kubectl is working now
kubectl get nodes
check_command "kubectl get nodes after permissions fix"


# Step 3: Install k9s
echo "3. Installing k9s (version ${K9S_VERSION})..."
K9S_TAR="k9s_Linux_amd64.tar.gz"
K9S_URL="https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/${K9S_TAR}"
wget -q "${K9S_URL}" -O "/tmp/${K9S_TAR}"
check_command "k9s download"
tar -xzf "/tmp/${K9S_TAR}" -C /tmp
check_command "k9s extract"
sudo mv /tmp/k9s /usr/local/bin/
check_command "move k9s to /usr/local/bin"
rm "/tmp/${K9S_TAR}"
echo "k9s version:"
k9s version
check_command "k9s version check"

# Step 4: Install nerdctl
echo "4. Installing nerdctl (version ${NERDCTL_VERSION})..."
#NERDCTL_TAR="nerdctl-full-${NERDCTL_VERSION}-linux-amd64.tar.gz"
#NERDCTL_URL="https://github.com/containerd/nerdctl/releases/download/v${NERDCTL_VERSION}/${NERDCTL_TAR}"
#wget -q "${NERDCTL_URL}" -O "/tmp/${NERDCTL_TAR}"
#check_command "nerdctl download"
## CORRECTED LINE BELOW: Added space after -C
#sudo tar -C /usr/local -xzf "/tmp/${NERDCTL_TAR}"
#check_command "nerdctl extract"
#rm "/tmp/${NERDCTL_TAR}"
#echo "nerdctl version:"
nerdctl --version
check_command "nerdctl version check"

# Step 5: Deploy Local Image Registry to k3s
echo "5. Deploying local image registry to k3s..."
mkdir -p ~/k3s-manifests
cat <<EOF > ~/k3s-manifests/local-registry.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: registry
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: registry
  template:
    metadata:
      labels:
        app: registry
    spec:
      containers:
      - name: registry
        image: registry:2
        ports:
        - containerPort: 5000
---
apiVersion: v1
kind: Service
metadata:
  name: registry
  namespace: default
spec:
  selector:
    app: registry
  ports:
    - protocol: TCP
      port: 5000
      targetPort: 5000
  type: ClusterIP
EOF
kubectl apply -f ~/k3s-manifests/local-registry.yaml
check_command "local registry deployment"
echo "Verifying local registry deployment..."
kubectl get pods -l app=registry
kubectl get svc registry

# Step 6: Install Terraform
echo "6. Installing Terraform (version ${TF_VERSION})..."
TF_ZIP="terraform_${TF_VERSION}_linux_amd64.zip"
TF_URL="https://releases.hashicorp.com/terraform/${TF_VERSION}/${TF_ZIP}"
sudo apt install -y unzip # Ensure unzip is present
check_command "install unzip"
wget -q "${TF_URL}" -O "/tmp/${TF_ZIP}"
check_command "terraform download"
unzip -o "/tmp/${TF_ZIP}" -d /tmp # -o to overwrite existing files
check_command "terraform extract"
sudo mv /tmp/terraform /usr/local/bin/
check_command "move terraform to /usr/local/bin"
rm "/tmp/${TF_ZIP}"
echo "Terraform version:"
terraform --version
check_command "terraform version check"

# ... (previous script content) ...

# Step 7: Install Ansible

echo "7. Installing Python3, pip, and pipx (for Ansible)..."
sudo apt update # Ensure apt cache is updated for new packages
sudo apt install -y python3 python3-pip pipx
check_command "install python3, pip, and pipx"

# Ensure pipx's installed applications are in PATH
python3 -m pipx ensurepath
check_command "pipx ensurepath"

# Source the bashrc or pipx-generated path file to update PATH in the current session
# pipx ensurepath typically adds to ~/.bashrc or ~/.profile
if [ -f "$HOME/.bashrc" ]; then
    echo "Sourcing ~/.bashrc to update PATH..."
    source "$HOME/.bashrc"
elif [ -f "$HOME/.profile" ]; then
    echo "Sourcing ~/.profile to update PATH..."
    source "$HOME/.profile"
fi

# IMPORTANT: Clear shell's command hash cache to recognize new binaries in PATH
echo "Clearing shell command cache (hash -r)..."
hash -r # Clears the shell's internal command hash table

echo "Installing Ansible via pipx..."
# Use --force if Ansible is already detected as installed (as per your output)
# This prevents the script from stopping if it runs multiple times
pipx install ansible --force
check_command "ansible installation via pipx"
echo "Ansible version:"
# CHANGED: Using ansible-community instead of ansible
ansible-community --version
check_command "ansible version check"

# Step 8: Install Golang
echo "8. Installing Golang..."
sudo apt install -y golang-go
check_command "golang installation"
echo "Go version:"
go version
check_command "go version check"

echo "--- DevOps Tools Installation Complete ---"
echo "Verification:"
echo "k3s nodes: " && kubectl get nodes
echo "k9s version: " && k9s version
echo "nerdctl version: " && nerdctl --version
echo "Local registry pods: " && kubectl get pods -l app=registry
echo "Local registry service: " && kubectl get svc registry
echo "Terraform version: " && terraform --version
echo "Ansible version: " && ansible --version
echo "Go version: " && go version

echo "--- Final Steps on Windows Host ---"
echo "Remember to install the 'Remote - WSL' extension in VS Code on your Windows host if you haven't already."
echo "Launch VS Code, go to Extensions (Ctrl+Shift+X), search for 'Remote - WSL', and install it."
echo "Then, click the green remote button in VS Code bottom-left to connect to your WSL Ubuntu instance."
