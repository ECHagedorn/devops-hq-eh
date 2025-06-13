FROM alpine:3.20

LABEL maintainer="Emmanuel Hagedorn"
LABEL description="Alpine-based debug pod with DevOps tools"

ENV DEBIAN_FRONTEND=noninteractive

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
    coreutils \
    mysql-client \
    postgresql-client \
    sqlite \
    mariadb-client \
    iputils \
    iproute2 \
    net-tools \
    bind-tools \
    nmap \
    tcpdump \
    ncurses \
    lsof \
    strace \
    htop \
    tree \
    less \
    tar \
    gzip \
    zip \
    unzip \
    busybox \
    openssl \
    && rm -rf /var/cache/apk/*

# --- Install Golang ---
ARG GO_VERSION="1.22.4" # Latest stable Go version as of current knowledge
RUN wget -q https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz -O /tmp/go.tar.gz && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz
ENV PATH="/usr/local/go/bin:${PATH}"

# --- Install tkn (Tekton CLI) ---
ARG TKN_VERSION="0.37.0" # Matches your workstation tkn version
RUN wget -q "https://github.com/tektoncd/cli/releases/download/v${TKN_VERSION}/tkn_${TKN_VERSION}_Linux_x86_64.tar.gz" -O /tmp/tkn.tar.gz && \
    tar -xzf /tmp/tkn.tar.gz -C /tmp/ && \
    mv /tmp/tkn /usr/local/bin/ && \
    rm /tmp/tkn.tar.gz

# Set default command (e.g., to keep container running for debugging)
CMD ["tail", "-f", "/dev/null"]
