# Enterprise DevSecOps & Hardened Agentic AI Platform

[![Release](https://img.shields.io/badge/release-v0.9.0-blue.svg)](https://github.com/jason-victor1/devsecops-master-repo/releases)
[![Kubernetes](https://img.shields.io/badge/EKS-1.31-326CE5?logo=kubernetes&logoColor=white)](https://aws.amazon.com/eks/)
[![Terraform](https://img.shields.io/badge/Terraform-1.9-844FBA?logo=terraform&logoColor=white)](https://www.terraform.io/)
[![Falco](https://img.shields.io/badge/Falco-modern--ebpf-00A98F?logo=falco&logoColor=white)](https://falco.org/)
[![Kyverno](https://img.shields.io/badge/Kyverno-1.12-19B5FE?logo=cncf&logoColor=white)](https://kyverno.io/)
[![Supply Chain](https://img.shields.io/badge/Cosign-Keyless-4A90E2)](https://sigstore.dev)
[![Policy-as-Code](https://img.shields.io/badge/OPA-Rego-7D42BC?logo=open-policy-agent&logoColor=white)](https://openpolicyagent.org)
[![Checkov](https://img.shields.io/badge/Checkov-23%2F23_Passed-brightgreen)](https://www.checkov.io/)

Production-grade, zero-trust cloud infrastructure and application security platform on Amazon EKS 1.31. Engineered with zero public API ingress, kernel-level eBPF runtime threat detection, keyless supply-chain admission gates, and an isolated execution sandbox runtime for untrusted Agentic AI workloads.

---

## 1. Architectural Topology

```text
                        ZERO-TRUST WORKSTATION ACCESS
                                     │
                 aws ssm start-session (WebSocket Tunnel)
                                     │
                                     ▼
 ┌─────────────────────── AWS VPC (us-east-1) ───────────────────────────────┐
 │                                                                           │
 │  PRIVATE MANAGEMENT SUBNET                                                │
 │  ┌─────────────────────────────────────────────────────────────────────┐  │
 │  │ SSM Jump Host (ARM64 t4g.nano)                                      │  │
 │  │ • Ingress: NONE (Zero open ports, no public IP)                     │  │
 │  │ • Egress: HTTPS:443 to AWS SSM endpoints                            │  │
 │  │ • Security: IMDSv2 Required, KMS gp3 Encrypted                      │  │
 │  └──────────────────────────────────┬──────────────────────────────────┘  │
 │                                     │ Internal VPC Transit                │
 │                                     ▼ (Port 443)                          │
 │  PRIVATE EKS CONTROL PLANE                                                │
 │  ┌─────────────────────────────────────────────────────────────────────┐  │
 │  │ Amazon EKS 1.31 API Server (cluster_endpoint_public_access = false) │  │
 │  └──────────────────────────────────┬──────────────────────────────────┘  │
 │                                     │ Admission Webhooks / Pod Identity   │
 │                                     ▼                                     │
 │  PRIVATE WORKER COMPUTE NODES                                             │
 │  ┌─────────────────────────────────────────────────────────────────────┐  │
 │  │ Runtime & Admission Controls                                        │  │
 │  │ • Falco (Modern eBPF BTF) ──> Falcosidekick ──> AWS CloudWatch      │  │
 │  │ • Kyverno: Dual-gate Keyless Cosign Signatures & CycloneDX SBOMs    │  │
 │  │ • Pod Identity: Scoped temporary STS tokens via pods.eks.amazonaws  │  │
 │  └──────────────────────────────────┬──────────────────────────────────┘  │
 │                                     │                                     │
 │                                     ▼                                     │
 │  UNTRUSTED WORKLOAD ISOLATION                                             │
 │  ┌─────────────────────────────────────────────────────────────────────┐  │
 │  │ Hardened Agentic AI Sandbox Pod (agent-worker)                      │  │
 │  │ • Compute: drop: [ALL], readOnlyRootFilesystem, non-root uid:10001  │  │
 │  │ • NetworkPolicy: L4 ingress from API only; IMDS (169.254...) DROP  │  │
 │  │ • Execution Gate: OPA/Conftest Rego blocks destructive shell tasks  │  │
 │  └─────────────────────────────────────────────────────────────────────┘  │
 │                                                                           │
 └───────────────────────────────────────────────────────────────────────────┘
```

---

## 2. Core Security Pillars & Architectural Decisions

| Pillar | Engineering Solution | Architecture Record |
| :--- | :--- | :--- |
| **Zero-Ingress Management** | Eliminated SSH port 22 and public bastions via ARM64 SSM WebSocket port forwarding. | [`ADR-0001`](docs/adr/0001-zero-ingress-ssm-bastion.md) |
| **Kernel Threat Telemetry** | Modern eBPF BTF probe replaces kernel modules, preventing node rebuild panics on EKS 1.31. | [`ADR-0002`](docs/adr/0002-modern-ebpf-telemetry-engine.md) |
| **Credential Path Normalization** | Resolved projected token symlink blind spots (`..data/token`) without alert storms. | [`ADR-0003`](docs/adr/0003-projected-token-tampering-normalization.md) |
| **Supply Chain Admission** | Kyverno gates in-cluster deployment on Cosign keyless signatures and CycloneDX SBOM schemas. | [`check-image-signatures-prod.yaml`](k8s/policies/check-image-signatures-prod.yaml) |
| **Agentic AI Isolation** | Non-root ephemeral sandbox runtime with IMDS blackholing and Rego-enforced tool execution gates. | [`policies/agent_tools.rego`](policies/agent_tools.rego) |

---

## 3. Empirical Security Validation Matrix

Full verification steps and live CloudWatch event streams are cataloged in [`SECURITY_VALIDATION.md`](SECURITY_VALIDATION.md).

| Validation ID | Target / Attack Simulation | Detection / Mitigation Mechanism | Audit Telemetry | Result |
| :--- | :--- | :--- | :--- | :--- |
| **VAL-001** | Host Credential Access (`cat /etc/shadow`) | Falco Modern eBPF (`openat`) | CloudWatch Logs (`Critical`) | **BLOCKED & LOGGED** |
| **VAL-002** | Projected SA Token Theft (`..data/token`) | Falco Normalized Macro Regex | CloudWatch Logs (`Critical`) | **ALERT STREAMED** |
| **VAL-003** | Public Control Plane Reconnaissance | Security Group Zero-Ingress Baseline | VPC Flow Logs (Drop) | **CONNECTION TIMED OUT** |
| **VAL-004** | Deployment of Unsigned Container Image | Kyverno Admission Controller | Webhook Rejection (HTTP 403) | **ADMISSION DENIED** |
| **VAL-005** | Destructive Agent Shell Invocation (`rm -rf`) | Open Policy Agent / Conftest Gate | Rego Evaluation Failure | **EXECUTION BLOCKED** |

---

## 4. Repository Structure

```text
.
├── docs/
│   ├── adr/                      # Formal Architectural Decision Records (0001 - 0003)
│   ├── DEVSECOPS_ARCHITECTURE_RUNBOOK.md
│   └── SYSTEM_DESIGN.md
├── infra/
│   ├── k8s/                      # Base & multi-environment Kustomize manifests
│   └── terraform/                # Modular IaC (VPC, EKS 1.31, SSM Bastion, Pod Identity)
├── k8s/
│   ├── helm-values/              # Hardened values (Falco modern-bpf, Falcosidekick, Kyverno)
│   ├── policies/                 # Kyverno supply chain & zero-trust network policies
│   └── sandboxes/                # Hardened Agentic AI execution pod & isolation netpol
├── policies/
│   └── agent_tools.rego          # Deterministic Conftest/OPA tool-calling guardrails
├── scripts/                      # Tunneling, validation, and generation automation
├── SECURITY_VALIDATION.md        # Empirical validation ledger with CloudWatch logs
└── SECURITY.md                   # Coordinated vulnerability disclosure policy
```

---

## 5. Cost & Lifecycle Governance

Infrastructure is orchestrated for strict cost control:
* **Active Compute & Networking:** All EKS clusters, node groups, and NAT gateways are fully deprovisioned ($0.00/hr active compute spend).
* **Audit Persistence:** Container signatures, CycloneDX SBOMs, and sandbox base layers are preserved in AWS ECR for verification.
