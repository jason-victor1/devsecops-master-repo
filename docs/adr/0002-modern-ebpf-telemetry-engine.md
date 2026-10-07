# ADR 0002: Falco Modern eBPF Probe vs. Legacy Kernel Module

## Status
Accepted

## Context
Runtime container security monitoring on Amazon EKS requires low-overhead inspection of system calls (`openat`, `execve`, `ptrace`, `connect`). Traditional Falco deployments relied on out-of-tree kernel modules (`falco.ko`), which require matching Linux kernel headers, break during AMI transitions (such as EKS 1.31 Amazon Linux 2023 upgrades), and risk inducing kernel panics in multi-tenant production clusters.

## Decision
We adopted the Falco Modern eBPF driver (`modern-bpf`) leveraging BTF (BPF Type Format) embedded directly in contemporary Linux kernels:
* Pinned the telemetry driver engine to `modern-bpf` via Helm values (`k8s/helm-values/falco-values-prod.yaml`).
* Eliminated the init-container requirement for on-the-fly kernel header compiling and dynamic DKMS builds.
* Deployed Falcosidekick 2.31.1 using AWS IAM Roles for Service Accounts (IRSA) to ship structured JSON security alerts directly to Amazon CloudWatch Logs.

## Consequences
* **Positive:** Zero node recompilation across EKS node updates; deterministic, crash-safe kernel probe execution; native compatibility with minimal Amazon Linux 2023 and Bottlerocket AMIs.
* **Negative:** Requires Linux kernel >= 5.8 with `CONFIG_DEBUG_INFO_BTF=y` enabled (standard on AL2023, but incompatible with older custom Linux kernels).
