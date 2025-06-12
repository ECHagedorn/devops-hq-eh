# Dockerfile for the Alpine Debug Pod

FROM alpine:3.20 # Using a recent stable Alpine version

LABEL maintainer="Emmanuel Hagedorn"
LABEL description="Alpine-based debug pod with DevOps tools"

# Set non-interactive mode for apt installs
ENV DEBIAN_FRONTEND=noninteractive

# Install common utilities
RUN apk update && \
    apk add --no-cache \
    bash \
    curl \
    wget \
    git \
    jq \
    ca-certificates \
    openssh-client \
    vim \
    gnupg \
    coreutils && \
    rm -rf /var/cache/apk/*

# --- Install Python3, pip, and pipx for Ansible ---
RUN apk add --no-cache python3 py3-pip && \
    python3 -m ensurepip --default-pip && \
    pip install --no-cache-dir pipx && \
    python3 -m pipx ensurepath && \
    ln -s /usr/bin/python3 /usr/bin/python # Symlink python to python3 for compatibility

# --- Install Ansible via pipx ---
# We use a specific version that maps to ansible-community for consistency
RUN pipx install ansible==11.6.0 && \
    pipx ensurepath # Ensure ansible-community is in PATH within the image

# --- Install Golang ---
ARG GO_VERSION="1.22.4" # Latest stable Go version as of current knowledge
RUN wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# --- Install Terraform ---
ARG TERRAFORM_VERSION="1.8.5" # Latest stable Terraform version as of current knowledge
RUN wget -q "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -O /tmp/terraform.zip && \
    unzip /tmp/terraform.zip -d /usr/local/bin && \
    rm /tmp/terraform.zip

# --- Install kubectl ---
ARG KUBECTL_VERSION="1.30.2" # Latest stable kubectl version as of current knowledge
RUN curl -LO "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/

# --- Install tkn (Tekton CLI) ---
ARG TKN_VERSION="0.37.0" # Matches your workstation tkn version
RUN wget -q "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -O /tmp/tkn.tar.gz && \
    tar -xzf /tmp/tkn.tar.gz -C /tmp/ && \
    mv /tmp/tkn /usr/local/bin/ && \
    rm /tmp/tkn.tar.gz

# Set default command (e.g., to keep container running for debugging)
CMD ["tail", "-f", "/dev/null"]
