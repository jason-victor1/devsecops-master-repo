# Zero-Trust Kubernetes DevSecOps Platform: System Design & Threat Model

## 1. Executive Summary & Problem Statement
Modern container environments face three primary attack vectors:
1. **Supply Chain Poisoning**: Vulnerable or tampered container images injected during CI/CD.
2. **Static Non-Human Identity Compromise**: Long-lived IAM credentials or pull secrets leaked from source control or runner environments.
3. **Runtime Exploitation**: Post-exploitation privilege escalations, interactive container shells, and in-pod credential harvesting (e.g., Kubernetes ServiceAccount JWT exfiltration).

This platform implements an automated, immutable defense-in-depth architecture spanning build-time attestation, API server admission enforcement, ephemeral identity federation, and kernel-level runtime syscall inspection.

---

## 2. Architecture & Data Flow

```text
      [ Developer / CI Workflow ]
                   │
                   ▼ (1. Multi-Stage Build & CVE Patching)
          [ Docker Engine ] ──> [ Syft CycloneDX SBOM ]
                   │
                   ▼ (2. Keyless OIDC Signing)
       [ Cosign + Sigstore ] <──> [ AWS ECR ]
                   │
═══════════════════╪════════════════════════════════════
                   │ KUBERNETES CONTROL PLANE BOUNDARY
                   ▼
        [ Kube-API Server ]
                   │
                   ▼ (Admission Webhook)
          [ Kyverno Engine ] (Validates Rekor Signature)
                   │
                   ▼ (Admit)
           [ K8s Pod / App ]
                   │
                   ▼ (3. Syscall Interception via modern_ebpf)
           [ Falco Engine ] (T1552 / T1059 / T1555)
                   │
                   ▼
          [ Falcosidekick ]
            ├── [ Redis UI Dashboard ]
            └── [ Slack / SIEM Webhooks ]
```

---

## 3. Threat Model & Control Matrix

| Attack Vector | MITRE ATT&CK | Security Layer | Technical Control |
| :--- | :--- | :--- | :--- |
| Untrusted Base Image Injection | T1195 (Supply Chain) | Build / CI | Syft CycloneDX SBOM generation and multi-stage CVE remediation. |
| Artifact Tampering / Hijacking | T1553 (Subvert Trust) | Provenance | Cosign keyless signing via ephemeral GitHub Actions OIDC and Sigstore Rekor. |
| Unauthorized Image Deployment | T1610 (Deploy Container) | Admission | Kyverno `ClusterPolicy` (`check-image-signatures`) blocking unsigned digests at API boundary. |
| Leaked Registry Credentials | T1552 (Unsecured Credentials) | Identity (NHI) | Automated 6-hour AWS STS token rotation (Kind) and AWS EKS Pod Identity (AWS). |
| Interactive Container Intrusion | T1059 (Command Interpreter) | Runtime | Falco modern eBPF rule detecting interactive `/bin/sh` or `/bin/bash` spawns. |
| In-Pod Secret Exfiltration | T1552 (ServiceAccount Token) | Runtime | Custom Falco rule intercepting `open_read` on `/var/run/secrets/kubernetes.io/serviceaccount/token`. |

---

## 4. Architectural Trade-Offs & Decisions (ADRs)

### 4.1 Keyless Signing (Sigstore/Cosign) vs. Static Private Keys / AWS KMS
* **Decision**: Adopt Cosign keyless signing using GitHub OIDC.
* **Rationale**: Eliminates long-lived private key management and rotation overhead. Transparency logs in Rekor provide immutable auditability without requiring dedicated Hardware Security Modules (HSMs).

### 4.2 Admission Controller: Kyverno vs. Open Policy Agent (OPA/Gatekeeper)
* **Decision**: Deploy Kyverno.
* **Rationale**: Kyverno policies are native Kubernetes custom resources written in standard YAML, eliminating the need to maintain specialized Rego policy parsers. Native Cosign/Sigstore image verification is supported out of the box.

### 4.3 Runtime Instrumentation: Modern eBPF vs. Kernel Modules
* **Decision**: Modern eBPF (`modern_ebpf`).
* **Rationale**: Traditional kernel modules (`falco-probe.ko`) risk kernel panics and require host-matched kernel headers on every worker node. Modern eBPF leverages the in-kernel BPF verifier for safety and executes without dynamic compilation overhead.

---

## 5. Production Transition Roadmap (Phase 2)
1. **Infrastructure as Code**: Provision multi-AZ VPC and AWS EKS 1.31 using Terraform in `infra/terraform/environments/prod`.
2. **Native Identity Federation**: Transition from the local `ecr-token-refresher` CronJob to AWS EKS Pod Identity.
3. **GitOps Bootstrapping**: Deploy Kyverno and Falco via Helm/ArgoCD with production PodDisruptionBudgets and HA replicas.
4. **Automated SIEM Routing**: Route Falcosidekick alerts to Amazon EventBridge and AWS Security Hub.
