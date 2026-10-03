# Enterprise DevSecOps Platform Architecture & Security Runbook

## 1. Overview & Security Architecture
This document details the multi-layered security controls implemented across the container lifecycle: supply chain provenance, Kubernetes admission enforcement, non-human identity credential rotation, and kernel-level runtime threat detection.

```
+-----------------------------------------------------------------------------------+
| 1. CI / Supply Chain (GitHub Actions)                                            |
|    - Base OS CVE remediation & multi-stage Docker build                           |
|    - Syft CycloneDX SBOM generation & artifact attestation                        |
|    - Cosign keyless image signing via Sigstore / GitHub OIDC                      |
|    - Publish immutable digest (@sha256:...) to AWS ECR                            |
+----------------------------------------+------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
| 2. Admission Control (Kyverno)                                                    |
|    - ClusterPolicy (check-image-signatures) enforces Cosign signature validity    |
|    - Rejects unsigned images at admission before scheduling into etcd             |
|    - Automatic 6-hour AWS ECR authentication token rotation (ecr-token-refresher) |
+----------------------------------------+------------------------------------------+
                                         |
                                         v
+-----------------------------------------------------------------------------------+
| 3. Runtime Observability & Threat Detection (Falco + Falcosidekick)               |
|    - modern_ebpf engine captures Linux kernel syscalls (execve, openat)           |
|    - Detects unauthorized terminal shells, privilege escalations, file tampering  |
|    - Forwards security alerts in real-time to Falcosidekick and Web UI            |
+-----------------------------------------------------------------------------------+
```

---

## 2. Supply Chain Security & Provenance
* **Vulnerability Management**: Base container images are patched in the runtime build stage, eliminating HIGH and CRITICAL vulnerabilities.
* **SBOM Generation**: Syft inspects package manifests and generates standard CycloneDX SBOMs attached as workflow artifacts.
* **Keyless Artifact Signing**: Cosign binds the immutable image SHA256 digest to GitHub's OIDC issuer (`https://token.actions.githubusercontent.com`) and commits cryptographic transparency logs to Sigstore Rekor.

---

## 3. Admission Control & Credential Rotation
* **Kyverno ClusterPolicy**:
  * Policy: `check-image-signatures`
  * Failure Action: `Enforce`
  * Validates identity and issuer against Rekor for all containers deployed from AWS ECR.
* **ECR Credential Management**:
  * **Local / Kind**: An automated `CronJob` (`ecr-token-refresher`) rotates short-lived 12-hour AWS STS tokens into `regcred` secrets every 6 hours across the `kyverno` and `default` namespaces.
  * **Production AWS EKS**: Managed via `terraform/modules/eks-pod-identity`, binding `KyvernoEksPodIdentityRole` with `AmazonEC2ContainerRegistryReadOnly` directly to the `kyverno-admission-controller` ServiceAccount.

---

## 4. Runtime Threat Detection (Falco)
* **Driver**: `modern_ebpf` (in-kernel tracing without host kernel headers).
* **Alert Routing**: DaemonSet streams alerts to `falco-falcosidekick`, which ingests events into a localized Redis store and serves a real-time web UI on port `2802`.
* **Verified Detection Rules**:
  * `Terminal shell in container` (interactive shell spawned)
  * `Read sensitive file untrusted` (`/etc/shadow` or credential inspection)

---

## 5. Verification Commands Runbook

### Admission Policy Verification
```bash
# Verify signed image is admitted:
kubectl run test-signed \
  --image=478076837031.dkr.ecr.us-east-1.amazonaws.com/devsecops-api@sha256:459c793cb7b17b0405fc88454b6c5c013c80568408404411c2485d7b96575ea6 \
  --dry-run=server

# Verify unsigned image is blocked:
kubectl run test-unsigned --image=nginx:latest --dry-run=server
```

### Runtime Detection Verification
```bash
# Spawn interactive container shell and test sensitive file access:
kubectl run ui-test --image=busybox -it --rm -- /bin/sh -c "cat /etc/shadow 2>/dev/null || whoami; exit"

# Forward and inspect Falcosidekick dashboard:
kubectl -n falco port-forward svc/falco-falcosidekick-ui 2802:2802
# URL: http://localhost:2802 (admin/admin)
```
