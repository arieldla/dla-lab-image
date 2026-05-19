# ─────────────────────────────────────────
# DLA Lab Image
# Multi-cloud toolkit for AWS and Azure labs
# ─────────────────────────────────────────

# Layer 1 - Base OS
FROM ubuntu:22.04

# Avoid interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# ─────────────────────────────────────────
# Layer 2 - Core utilities
# ─────────────────────────────────────────
RUN apt-get update && apt-get install -y \
    curl \
    git \
    vim \
    jq \
    wget \
    unzip \
    zip \
    python3 \
    python3-pip \
    bash \
    gnupg \
    software-properties-common \
    ca-certificates \
    apt-transport-https \
    lsb-release \
    ruby-full \
    && rm -rf /var/lib/apt/lists/*

# ─────────────────────────────────────────
# Layer 3 - AWS CLI v2
# ─────────────────────────────────────────
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws/

# ─────────────────────────────────────────
# Layer 3 - Azure CLI
# ─────────────────────────────────────────
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# ─────────────────────────────────────────
# Layer 4 - Terraform
# ─────────────────────────────────────────
RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/1.12.0/terraform_1.12.0_linux_amd64.zip \
    && unzip terraform.zip -d /usr/local/bin/ \
    && rm terraform.zip

# ─────────────────────────────────────────
# Layer 4 - Ansible
# ─────────────────────────────────────────
RUN pip3 install --no-cache-dir ansible

# ─────────────────────────────────────────
# Layer 5 - kubectl
# ─────────────────────────────────────────
RUN curl -LO "https://dl.k8s.io/release/$(curl -Ls https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" \
    && chmod +x kubectl \
    && mv kubectl /usr/local/bin/

# ─────────────────────────────────────────
# Layer 5 - Helm
# ─────────────────────────────────────────
RUN curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ─────────────────────────────────────────
# Layer 6 - Trivy
# ─────────────────────────────────────────
RUN curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sh -s -- -b /usr/local/bin

# ─────────────────────────────────────────
# Layer 7 - AWS SSM Agent
# ─────────────────────────────────────────
RUN wget https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/debian_amd64/amazon-ssm-agent.deb \
    && dpkg -i amazon-ssm-agent.deb \
    && rm amazon-ssm-agent.deb

# ─────────────────────────────────────────
# Layer 7 - AWS CloudWatch Agent
# ─────────────────────────────────────────
RUN wget https://s3.amazonaws.com/amazoncloudwatch-agent/debian/amd64/latest/amazon-cloudwatch-agent.deb \
    && dpkg -i amazon-cloudwatch-agent.deb \
    && rm amazon-cloudwatch-agent.deb

# ─────────────────────────────────────────
# Layer 8 - Python SDKs
# ─────────────────────────────────────────
RUN pip3 install --no-cache-dir \
    boto3 \
    azure-identity \
    azure-mgmt-compute \
    azure-mgmt-resource

# ─────────────────────────────────────────
# Entrypoint
# ─────────────────────────────────────────
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

WORKDIR /workspace
ENTRYPOINT ["/entrypoint.sh"]