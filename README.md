# DLA Lab Image 🐳

A multi-cloud lab toolkit container image for AWS and Azure labs.
Built and maintained by [Ariel De Los Angeles](https://github.com/arieldla) under DLA Group Inc.

## Overview

Instead of hunting for the right base image per lab, this image comes pre-loaded
with every tool needed for AWS and Azure labs — ready to drop into ECS, EKS, AKS,
or run locally.

## What's Inside

| Layer | Tools |
|---|---|
| Base OS | Ubuntu 22.04 LTS |
| Core Utilities | curl, git, vim, jq, wget, unzip, python3, bash |
| Cloud CLIs | AWS CLI v2, Azure CLI |
| IaC | Terraform 1.12.2, Ansible |
| Container & K8s | kubectl, Helm |
| Security | Trivy |
| AWS Agents | SSM Agent, CloudWatch Agent |
| Python SDKs | boto3, azure-identity, azure-mgmt-compute, azure-mgmt-resource |

## Registries

| Registry | Image |
|---|---|
| GHCR | `ghcr.io/arieldla/dla-lab-image:latest` |
| AWS ECR | `640168421612.dkr.ecr.us-east-1.amazonaws.com/dla-lab-image:latest` |
| Azure ACR | `dlagroupacr.azurecr.io/dla-lab-image:latest` |

## Usage

### Pull and run locally
```bash
docker pull ghcr.io/arieldla/dla-lab-image:latest

docker run -it \
  -v ~/.aws:/root/.aws \
  -v ~/.azure:/root/.azure \
  -v $(pwd):/workspace \
  ghcr.io/arieldla/dla-lab-image:latest
```

### Use in ECS Task Definition
```json
{
  "image": "640168421612.dkr.ecr.us-east-1.amazonaws.com/dla-lab-image:latest"
}
```

### Use in Kubernetes Pod
```yaml
spec:
  containers:
    - name: lab-toolkit
      image: ghcr.io/arieldla/dla-lab-image:latest
```

## CI/CD Pipeline

Every push to `main` triggers a GitHub Actions workflow that:

1. Builds the image
2. Scans with Trivy — blocks on CRITICAL vulnerabilities
3. Pushes to GHCR, ECR, and ACR simultaneously

## Security

- Images are scanned with Trivy on every build
- ECR has `scanOnPush` enabled for additional scanning
- Credentials are never baked into the image — always mounted at runtime
- See `.trivyignore` for documented accepted upstream CVEs

## AWS SSM Hybrid Activation

To register the container with AWS Systems Manager:

```bash
docker run -it \
  -e SSM_ACTIVATION_CODE=your-code \
  -e SSM_ACTIVATION_ID=your-id \
  -e AWS_REGION=us-east-1 \
  ghcr.io/arieldla/dla-lab-image:latest
```