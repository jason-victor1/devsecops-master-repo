#!/usr/bin/env bash
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== EKS Security Posture Validation ===${NC}\n"

# ---------------------------------------------------------
# Test 1: Kyverno Admission Control
# ---------------------------------------------------------
echo -n "Testing Kyverno unsigned image rejection in 'prod'... "
kubectl create namespace prod --dry-run=client -o yaml | kubectl apply -f - > /dev/null 2>&1

OUTPUT=$(kubectl run unsigned-test \
  --image=478076837031.dkr.ecr.us-east-1.amazonaws.com/event-ingestion-api-prod:latest \
  -n prod \
  --restart=Never 2>&1 || true)

if echo "$OUTPUT" | grep -q "check-image-signatures-prod"; then
  echo -e "${GREEN}[PASS] Blocked by Kyverno${NC}"
else
  echo -e "${RED}[FAIL] Pod was admitted unexpectedly${NC}"
  echo "$OUTPUT"
fi

# ---------------------------------------------------------
# Test 2: Falco Runtime Threat Detection (MITRE T1552)
# ---------------------------------------------------------
echo -n "Testing Falco eBPF ServiceAccount token access detection... "

# Synchronously ensure any lingering test pod is removed
kubectl delete pod falco-test -n default --ignore-not-found=true --now > /dev/null 2>&1
kubectl wait --for=delete pod/falco-test -n default --timeout=15s > /dev/null 2>&1 || true

# Spawn fresh test workload
kubectl run falco-test --image=busybox -n default --restart=Never -- sleep 60 > /dev/null 2>&1
kubectl wait --for=condition=Ready pod/falco-test -n default --timeout=30s > /dev/null 2>&1

# Identify the node and target Falco pod
NODE_NAME=$(kubectl get pod falco-test -n default -o jsonpath='{.spec.nodeName}')
FALCO_POD=$(kubectl get pod -n falco -l app.kubernetes.io/name=falco --field-selector spec.nodeName="$NODE_NAME" -o jsonpath='{.items[0].metadata.name}')

# Trigger syscall event
kubectl exec falco-test -n default -- cat /var/run/secrets/kubernetes.io/serviceaccount/token > /dev/null 2>&1

# Allow modern_ebpf ring-buffer flush
sleep 3

# Query the targeted Falco pod
FALCO_LOG=$(kubectl logs -n falco "$FALCO_POD" -c falco --since=30s 2>&1 || true)

if echo "$FALCO_LOG" | grep -q "ServiceAccount token access"; then
  echo -e "${GREEN}[PASS] Detected by modern_ebpf on ${NODE_NAME}${NC}"
else
  echo -e "${RED}[FAIL] No alert found in Falco logs on ${NODE_NAME}${NC}"
  echo "$FALCO_LOG" | tail -n 10
fi

# ---------------------------------------------------------
# Cleanup
# ---------------------------------------------------------
echo -n "Cleaning up test workloads... "
kubectl delete namespace prod --ignore-not-found=true --wait=false > /dev/null 2>&1
kubectl delete pod falco-test -n default --ignore-not-found=true --now > /dev/null 2>&1
echo -e "${GREEN}[DONE]${NC}\n"

echo -e "${BLUE}=== Verification Complete ===${NC}"
