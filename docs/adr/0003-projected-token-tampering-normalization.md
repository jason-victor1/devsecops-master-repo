# ADR 0003: Projected ServiceAccount Token Path Normalization

## Status
Accepted

## Context
Kubernetes 1.21+ uses projected ServiceAccount volume mounts where tokens are updated atomically via symlink directory structures (`..data/token -> ..<timestamp>/token`). Standard out-of-the-box Falco rules monitoring `Read sensitive file untrusted` look for literal static file paths (`/var/run/secrets/kubernetes.io/serviceaccount/token`), resulting in:
1. **Detection blind spots:** Adversaries traversing the atomic symlink directory tree (`..data/token`) bypassed literal path matching.
2. **Alert noise:** Background kubelet atomic token rotation cycles periodically triggered false-positive exfiltration alerts.

## Decision
We authored custom macro overrides within `k8s/helm-values/falco-values-prod.yaml`:
* Extended the sensitive file macro to evaluate `fd.name startswith /var/run/secrets/kubernetes.io/serviceaccount/` while explicitly capturing symlink patterns (`..data/token`).
* Whitelisted verified container runtime processes and entrypoint shims using `proc.pname` and container boundary criteria.

## Consequences
* **Positive:** Accurately catches unauthorized reads of projected ServiceAccount credentials while maintaining zero false-positive alerts during kubelet atomic token refreshes.
* **Negative:** Custom macro definitions require validation whenever container base OS images or upstream Kubernetes secret projection structures change.
