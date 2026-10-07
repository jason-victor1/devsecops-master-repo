#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="devsecops-prod-eks"
AWS_REGION="us-east-1"
LOCAL_PORT="6443"

echo "[1/3] Querying private EKS cluster endpoint..."
EKS_ENDPOINT=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" --query 'cluster.endpoint' --output text)
EKS_HOST=$(echo "$EKS_ENDPOINT" | sed -E 's|^https?://||')

echo "[2/3] Locating SSM Bastion Instance ID..."
BASTION_ID=$(aws ec2 describe-instances \
  --filters "Name=tag:Name,Values=devsecops-prod-ssm-bastion" "Name=instance-state-name,Values=running" \
  --region "$AWS_REGION" \
  --query 'Reservations[*].Instances[*].InstanceId' \
  --output text)

if [ -z "$BASTION_ID" ]; then
  echo "Error: Running SSM Bastion instance not found. Has it been provisioned?"
  exit 1
fi

echo "[3/3] Initiating secure SSM WebSocket tunnel to ${EKS_HOST}:443 via ${BASTION_ID}..."
echo "      Tunnel endpoint: https://localhost:${LOCAL_PORT}"
echo "      Press Ctrl+C to terminate session."

aws ssm start-session \
  --target "$BASTION_ID" \
  --region "$AWS_REGION" \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters host="$EKS_HOST",portNumber="443",localPortNumber="$LOCAL_PORT"
