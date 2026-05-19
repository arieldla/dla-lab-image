#!/bin/bash

# ─────────────────────────────────────────
# DLA Lab Image - Entrypoint
# Registers agents at container startup
# based on environment variables provided
# ─────────────────────────────────────────

echo "╔══════════════════════════════════════╗"
echo "║        DLA Lab Image Starting        ║"
echo "╚══════════════════════════════════════╝"

# ─────────────────────────────────────────
# AWS SSM Agent - Hybrid Activation
# Requires: SSM_ACTIVATION_CODE, SSM_ACTIVATION_ID
# ─────────────────────────────────────────
if [ -n "$SSM_ACTIVATION_CODE" ] && [ -n "$SSM_ACTIVATION_ID" ]; then
    echo "[+] Registering with AWS SSM..."
    amazon-ssm-agent -register \
        -code "$SSM_ACTIVATION_CODE" \
        -id "$SSM_ACTIVATION_ID" \
        -region "${AWS_REGION:-us-east-1}" \
        -y
    amazon-ssm-agent &
    echo "[+] SSM Agent started"
else
    echo "[-] SSM_ACTIVATION_CODE/ID not set - skipping SSM registration"
fi

# ─────────────────────────────────────────
# AWS CloudWatch Agent
# Requires: CW_CONFIG_PATH pointing to config file
# ─────────────────────────────────────────
if [ -f "${CW_CONFIG_PATH:-/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json}" ]; then
    echo "[+] Starting CloudWatch Agent..."
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a start -m onPrem \
        -c file:"${CW_CONFIG_PATH:-/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json}"
    echo "[+] CloudWatch Agent started"
else
    echo "[-] No CloudWatch config found - skipping"
fi

# ─────────────────────────────────────────
# Print tool versions on startup
# ─────────────────────────────────────────
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " Installed Tools:"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo " AWS CLI:    $(aws --version 2>&1 | cut -d' ' -f1)"
echo " Azure CLI:  $(az version --query '\"azure-cli\"' -o tsv 2>/dev/null)"
echo " Terraform:  $(terraform version -json 2>/dev/null | python3 -c 'import sys,json; print(json.load(sys.stdin)["terraform_version"])' 2>/dev/null)"
echo " kubectl:    $(kubectl version --client --short 2>/dev/null)"
echo " Helm:       $(helm version --short 2>/dev/null)"
echo " Trivy:      $(trivy --version 2>/dev/null | head -1)"
echo " Ansible:    $(ansible --version 2>/dev/null | head -1)"
echo " boto3:      $(python3 -c 'import boto3; print(boto3.__version__)' 2>/dev/null)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

exec /bin/bash