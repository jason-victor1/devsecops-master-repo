# Enterprise DevSecOps Platform Architecture & Security Runbook

## 1. Overview & Security Architecture
This document defines the multi-layered security controls implemented across the container lifecycle: supply chain provenance, Kubernetes admission enforcement, non-human identity credential rotation, and kernel-level runtime threat detection.

```text
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
|    - Forwards security alerts in real-time to Falcosidekick, Web UI, and Slack    |
+-----------------------------------------------------------------------------------+
```

---

## 2. Supply Chain Security & Provenance
* **Vulnerability Management**: Base container images are patched during multi-stage Docker builds, eliminating HIGH and CRITICAL CVEs prior to artifact registry publishing.
* **Software Bill of Materials (SBOM)**: Syft inspects package manifests during CI and generates standardized CycloneDX JSON SBOMs attached as release artifacts.
* **Keyless Artifact Signing**: Cosign binds the immutable image SHA256 digest to GitHub's OIDC issuer (`[https://token.actions.githubusercontent.com](https://token.actions.githubusercontent.com)`) and commits cryptographic transparency logs to Sigstore Rekor. Long-lived signing keys are strictly avoided.

---

## 3. Admission Control & Credential Rotation
* **Kyverno ClusterPolicy**:
  * Policy: `check-image-signatures`
  * Failure Action: `Enforce`
  * Validates identity and issuer against Rekor for all containers deployed from AWS ECR. Unsigned images are blocked before scheduling into etcd.
* **Non-Human Identity (NHI) Management**:
  * **Local / Kind**: An automated `CronJob` (`ecr-token-refresher`) rotates short-lived 12-hour AWS STS tokens into `regcred` secrets every 6 hours across the `kyverno` and `default` namespaces.
  * **Production AWS EKS**: Managed via `terraform/modules/eks-pod-identity`, binding `KyvernoEksPodIdentityRole` with `AmazonEC2ContainerRegistryReadOnly` directly to the `kyverno-admission-controller` ServiceAccount.

---

## 4. Runtime Threat Detection & Alert Routing (Falco)
* **Engine**: `modern_ebpf` driver (in-kernel tracing without host kernel headers or privileged module compilation).
* **Alert Routing Pipeline**: DaemonSet streams raw syscall events to `falco-falcosidekick`, which:
  1. Stores real-time event telemetry in an internal Redis instance.
  2. Renders an interactive operational dashboard on port `2802`.
  3. Dispatches structured cards for `Warning` and `Critical` priorities to Slack `#alerts` via incoming webhooks.
* **Active Detection Rules**:
  * `Terminal shell in container` (interactive shell spawned, MITRE ATT&CK T1059).
  * `Read sensitive file untrusted` (`/etc/shadow` credential inspection, MITRE ATT&CK T1555).
  * `Unauthorized K8s ServiceAccount Token Read` (injected ServiceAccount credential access, MITRE ATT&CK T1552).

---

## 5. Custom Falco Rule Configuration
Custom rules are mounted into `/etc/falco/rules.d/` via Helm value overrides:

```yaml
customRules:
  k8s-sa-token.yaml: |-
    - rule: Unauthorized K8s ServiceAccount Token Read
      desc: Detect attempts to read Kubernetes ServiceAccount credentials from within a container
      condition: >
        open_read and
        container and
        fd.name startswith "/var/run/secrets/kubernetes.io/serviceaccount"
      output: >
        K8s ServiceAccount Token read attempt (user=%user.name command=%proc.cmdline file=%fd.name container_id=%container.id container_name=%container.name image=%container.image.repository)
      priority: WARNING
      tags: [mitre_credential_access, T1552, kubernetes, token]
```

---

## 6. Verification & Attack Simulation Runbook

### 6.1 Admission Policy Enforcement
```bash
# Positive test: Verify signed image is admitted
kubectl run test-signed \
  --image=[478076837031.dkr.ecr.us-east-1.amazonaws.com/devsecops-api@sha256:459c793cb7b17b0405fc88454b6c5c013c80568408404411c2485d7b96575ea6](https://478076837031.dkr.ecr.us-east-1.amazonaws.com/devsecops-api@sha256:459c793cb7b17b0405fc88454b6c5c013c80568408404411c2485d7b96575ea6) \
  --dry-run=server

# Negative test: Verify unsigned public image is blocked
kubectl run test-unsigned --image=nginx:latest --dry-run=server
```

### 6.2 Runtime Syscall & Threat Detection
```bash
# MITRE T1059 / T1555: Interactive shell and credential access
kubectl run ui-test --image=busybox -it --rm -- /bin/sh -c "cat /etc/shadow 2>/dev/null || whoami; exit"

# MITRE T1552: Kubernetes ServiceAccount token exfiltration
kubectl run sa-token-test --image=busybox -it --rm -- /bin/sh -c "cat /var/run/secrets/kubernetes.io/serviceaccount/token 2>/dev/null; exit"
```

### 6.3 Telemetry & Forwarder Inspection
```bash
# Access Falcosidekick Web UI (admin/admin)
kubectl -n falco port-forward svc/falco-falcosidekick-ui 2802:2802

# Inspect engine detection logs
kubectl -n falco logs -l app.kubernetes.io/name=falco -c falco --tail=30

# Inspect Slack webhook dispatch status
kubectl -n falco logs deployment/falco-falcosidekick --tail=30 | grep -i "slack"
```

---

## 7. Cluster Teardown Runbook
When decommissioning the local test harness:

```bash
# 1. Stop background port-forwarding
pkill -f "port-forward.*2802" || true

# 2. Uninstall security Helm releases
helm uninstall falco -n falco 2>/dev/null || true
helm uninstall kyverno -n kyverno 2>/dev/null || true
kubectl delete namespace falco kyverno --timeout=30s 2>/dev/null || true

# 3. Destroy Kind cluster
kind delete cluster --name devsecops
rm -f custom-rules.yaml
```
