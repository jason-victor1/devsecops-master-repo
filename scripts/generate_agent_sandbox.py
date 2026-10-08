#!/usr/bin/env python3
import os

os.makedirs("k8s/sandboxes", exist_ok=True)
os.makedirs("policies", exist_ok=True)

# 1. Hardened Agentic Pod Deployment
agent_deployment = """apiVersion: apps/v1
kind: Deployment
metadata:
  name: agent-worker
  namespace: prod
  labels:
    app.kubernetes.io/name: agent-worker
    app.kubernetes.io/part-of: autonomous-sandbox
    security.kubernetes.io/tier: untrusted-workload
spec:
  replicas: 1
  selector:
    matchLabels:
      app.kubernetes.io/name: agent-worker
  template:
    metadata:
      labels:
        app.kubernetes.io/name: agent-worker
        security.kubernetes.io/tier: untrusted-workload
    spec:
      serviceAccountName: default
      automountServiceAccountToken: false
      securityContext:
        runAsNonRoot: true
        runAsUser: 10001
        runAsGroup: 10001
        fsGroup: 10001
        seccompProfile:
          type: RuntimeDefault
      containers:
        - name: worker
          image: 478076837031.dkr.ecr.us-east-1.amazonaws.com/agent-worker:latest
          imagePullPolicy: IfNotPresent
          securityContext:
            allowPrivilegeEscalation: false
            readOnlyRootFilesystem: true
            capabilities:
              drop:
                - ALL
          resources:
            limits:
              cpu: "500m"
              memory: "512Mi"
            requests:
              cpu: "100m"
              memory: "128Mi"
          volumeMounts:
            - name: ephemeral-storage
              mountPath: /tmp
      volumes:
        - name: ephemeral-storage
          emptyDir:
            sizeLimit: 128Mi
"""

# 2. Network Isolation & IMDS Lockdown Policy
agent_netpol = """apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: agent-sandbox-isolation
  namespace: prod
  labels:
    security.kubernetes.io/tier: agent-sandbox
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: agent-worker
  policyTypes:
    - Ingress
    - Egress
  ingress:
    # Allow incoming job orchestrations only from authorized controller pods
    - from:
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: devsecops-api
      ports:
        - protocol: TCP
          port: 8080
  egress:
    # 1. DNS Resolution inside kube-system
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: UDP
          port: 53
    # 2. Restrict external egress: permit standard HTTPS (443) but strictly blackhole IMDS and internal VPC
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
              - 169.254.169.254/32
              - 10.0.0.0/8
      ports:
        - protocol: TCP
          port: 443
"""

# 3. Deterministic Policy-as-Code Tool Gate (Conftest / OPA Rego)
rego_gate = """package agent.tools

import future.keywords.in

default allow = false

# Allow tool invocation only if all safety checks pass
allow {
    valid_tool
    not denied_command
    not illegal_target
}

# Whitelist allowed tool operations
valid_tool {
    input.tool_name in ["read_file", "search_docs", "run_sandbox_command"]
}

# Block destructive shell patterns in agent command execution
denied_command {
    input.tool_name == "run_sandbox_command"
    regex.match("(rm -rf|mkfs|chmod \\+x|curl.*\\|.*sh|wget|nc -e|sudo)", input.tool_args.command)
}

# Prevent file access outside ephemeral workspace
illegal_target {
    input.tool_name in ["read_file", "write_file"]
    not startswith(input.tool_args.path, "/tmp/")
}
"""

with open("k8s/sandboxes/agent-worker-deployment.yaml", "w") as f:
    f.write(agent_deployment.strip() + "\n")

with open("k8s/sandboxes/agent-sandbox-netpol.yaml", "w") as f:
    f.write(agent_netpol.strip() + "\n")

with open("policies/agent_tools.rego", "w") as f:
    f.write(rego_gate.strip() + "\n")

print("Phase 3 Agentic AI Sandbox resources generated successfully.")
