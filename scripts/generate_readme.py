#!/usr/bin/env python3

TICK = "```"

content = f"""# Enterprise DevSecOps Platform: Hardened EKS 1.31 Architecture

[![CI & Security Pipeline](https://github.com/jason-victor1/devsecops-master-repo/actions/workflows/ci-security-lint.yml/badge.svg)](https://github.com/jason-victor1/devsecops-master-repo/actions/workflows/ci-security-lint.yml)
[![Release Please](https://github.com/jason-victor1/devsecops-master-repo/actions/workflows/release-please.yml/badge.svg)](https://github.com/jason-victor1/devsecops-master-repo/actions/workflows/release-please.yml)
[![Zero-Trust Security](https://img.shields.io/badge/Security_Alerts-0_Open-brightgreen.svg)](#core-security-pillars)
[![Terraform 1.9+](https://img.shields.io/badge/IaC-Terraform_1.9+-623CE4.svg?logo=terraform)](#architecture-overview)
[![Kubernetes 1.31](https://img.shields.io/badge/Kubernetes-1.31-326CE5.svg?logo=kubernetes)](#architecture-overview)

A production-grade, zero-trust Amazon EKS (v1.31) infrastructure platform built with deterministic policy-as-code gates, kernel-level eBPF runtime threat detection, non-human identity (NHI) governance, and private Systems Manager (SSM) cluster connectivity.

---

## Architecture Overview

{TICK}
                                      AWS CLOUD (us-east-1)
                     ┌─────────────────────────────────────────────────────────┐
                     │ Multi-AZ VPC (Private & Public Subnets, NAT Gateways)   │
                     │                                                         │
  Workstation        │  ┌──────────────────────────────────────────────────┐  │
 ┌───────────┐       │  │ Private Management Subnet                        │  │
 │  kubectl  │       │  │   ┌──────────────────────────────────────────┐   │  │
 └─────┬─────┘       │  │   │ SSM Private Bastion (t4g.nano)           │   │  │
       │ (localhost) │  │   │ • Zero Public Ingress (No SSH Port 22)   │   │  │
       ▼             │  │   │ • IMDSv2 + Encrypted EBS (gp3)           │   │  │
 ┌───────────┐       │  │   └────────────────────┬─────────────────────┘   │  │
 │ AWS SSM   │───────┼──┼────────────────────────┼─────────────────────────┘  │
 │ WebSocket │       │                           │ (Port 443 Ingress)         │
 └───────────┘       │                           ▼                            │
                     │  ┌──────────────────────────────────────────────────┐  │
                     │  │ Amazon EKS Control Plane (v1.31)                 │  │
                     │  │ • Private API Server Only (0.0.0.0/0 Blocked)    │  │
                     │  │ • KMS Secrets Envelope Encryption                │  │
                     │  │ • Control Plane Audit & Authenticator Logs       │  │
                     │  └────────────────────────┬─────────────────────────┘  │
                     │                           │                            │
                     │  ┌────────────────────────▼─────────────────────────┐  │
                     │  │ Managed Node Group (Private Subnets)             │  │
                     │  │                                                  │  │
                     │  │   ┌──────────────────────────────────────────┐   │  │
                     │  │   │ Kyverno Admission Controller             │   │  │
                     │  │   │ • Non-Human Identity (EKS Pod Identity)  │   │  │
                     │  │   └──────────────────────────────────────────┘   │  │
                     │  │                                                  │  │
                     │  │   ┌──────────────────────────────────────────┐   │  │
                     │  │   │ Falco Modern eBPF Engine (Kernel Probe)  │   │  │
                     │  │   │ • Projected Token Tampering Detection    │   │  │
                     │  │   │ • Sensitive File Integrity (/etc/shadow) │   │  │
                     │  │   └────────────────────┬─────────────────────┘   │  │
                     │  └────────────────────────┼─────────────────────────┘  │
                     │                           ▼                            │
                     │  ┌──────────────────────────────────────────────────┐  │
                     │  │ Falcosidekick (v2.31.1 via IRSA)                 │  │
                     │  └────────────────────────┬─────────────────────────┘  │
                     └───────────────────────────┼────────────────────────────┘
                                                 ▼ (HTTP 200 Streaming)
                      ┌─────────────────────────────────────────────────────┐
                      │ AWS CloudWatch Logs                                 │
                      │ /aws/eks/devsecops-prod-eks/falco-security-alerts   │
                      └─────────────────────────────────────────────────────┘
{TICK}

---

## Core Security Pillars

### 1. Zero-Trust Network Perimeter
* **Private API Server:** Public endpoint access is disabled (`cluster_endpoint_public_access = false`). Ingress traffic from the internet to the Kubernetes control plane is blocked at the VPC boundary.
* **SSM Session Tunneling:** Operator access uses AWS Systems Manager WebSocket tunneling (`scripts/start-eks-private-tunnel.sh`) through a zero-ingress `t4g.nano` jump host, eliminating bastion public IP exposure and SSH port 22 attack surfaces.

### 2. Shift-Left Policy-as-Code
* **CI Static Analysis:** GitHub Actions enforces blocking PR status checks via **Checkov** and **Trivy**.
* **Zero Alerts:** All 22 initial static analysis alerts (including `CKV_AWS_38`, `CKV_AWS_39`, `AVD-AWS-0040`, and `AVD-AWS-0041`) have been resolved with zero open findings.

### 3. Non-Human Identity & Admission Control
* **EKS Pod Identity & IRSA:** Workloads obtain temporary, scoped AWS STS credentials directly via Kubernetes ServiceAccounts, eliminating static IAM access keys.
* **Kyverno Guardrails:** Validating admission policies block privileged pods, prevent host path mounts, and enforce secure container contexts.

### 4. Kernel-Level Runtime Detection (eBPF)
* **Modern eBPF Driver:** Falco monitors raw kernel syscalls without out-of-tree kernel modules.
* **EKS 1.31 Projected Path Tuning:** Custom macro rules account for Kubernetes symlinked token projection (`..data/token`), preventing false positives while catching active exfiltration attempts.
* **Telemetry Streaming:** Alerts stream over HTTPS to AWS CloudWatch (`/aws/eks/devsecops-prod-eks/falco-security-alerts`) via Falcosidekick `2.31.1`.

---

## Empirical Security Verification

Live threat simulations confirm real-time detection and logging:

### Scenario A: Unauthorized Credential Harvesting
* **Trigger:** Attempted read of `/etc/shadow` within a container.
* **Falco Detection:**
{TICK}json
{{
  "priority": "Warning",
  "rule": "Read sensitive file untrusted",
  "output": "Sensitive file opened for reading by non-trusted program (file=/etc/shadow program=cat)"
}}
{TICK}

### Scenario B: ServiceAccount Token Tampering
* **Trigger:** Access to the projected ServiceAccount token directory.
* **Falco Detection:**
{TICK}json
{{
  "priority": "Critical",
  "rule": "Read sensitive file untrusted",
  "output": "Access to projected serviceaccount token detected (file=/var/run/secrets/kubernetes.io/serviceaccount/..data/token)"
}}
{TICK}

---

## Repository Structure

{TICK}
├── .github/workflows/          # CI/CD: Checkov, Trivy, Linter, Release Please
├── docs/                       # Threat models and architectural ADRs
├── infra/terraform/
│   ├── modules/
│   │   ├── eks/                # EKS 1.31, KMS, CloudWatch logging
│   │   ├── ssm_bastion/        # Zero-ingress private SSM jump host
│   │   └── vpc/                # Multi-AZ VPC with private/public subnets
│   └── environments/prod/      # Production environment definition
├── k8s/                        # Helm values and Kyverno cluster policies
└── scripts/                    # SSM tunneling, verification harnesses, cost scripts
{TICK}

---

## Getting Started

### Prerequisites
* AWS CLI v2 configured with appropriate IAM permissions
* Terraform >= 1.9.0
* Session Manager Plugin for AWS CLI

### Connecting via Private SSM Tunnel
{TICK}bash
# 1. Start the encrypted SSM WebSocket tunnel to the private control plane
./scripts/start-eks-private-tunnel.sh

# 2. Access the cluster in a separate terminal
kubectl --server=https://localhost:6443 get nodes
{TICK}
"""

with open("README.md", "w") as f:
    f.write(content.strip() + "\n")

print("README.md generated successfully with valid code fences.")
