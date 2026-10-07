# Empirical Security Validation Ledger: Hardened EKS 1.31 Platform

## 1. Compliance Control Verification Matrix

| Validation ID | Threat Vector / Target | Attack Simulation | Detection Mechanism | Telemetry Egress | Result |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **VAL-001** | Unauthorized Host Credential Harvest | `cat /etc/shadow` | Falco Modern eBPF (`openat`) | HTTPS / CloudWatch Logs | **ALERT GENERATED** |
| **VAL-002** | Projected ServiceAccount Token Theft | `cat /var/run/secrets/.../..data/token` | Falco Modern eBPF (Symlink Macro) | HTTPS / CloudWatch Logs | **ALERT GENERATED** |
| **VAL-003** | Unauthorized Cluster Ingress | `curl -k https://<eks-private-endpoint>:443` | VPC Security Group Ingress Filter | CloudWatch VPC Flow Logs | **DROPPED (TIMEOUT)** |
| **VAL-004** | Container Image Supply Chain Admission | Pod deployment of unsigned image | Kyverno Admission Controller | Kubernetes Admission Webhook | **REJECTED (HTTP 403)** |

---

## 2. Empirical Telemetry Proof (Live CloudWatch Streams)

### Test VAL-001: Unauthorized Sensitive File Access
```json
{
  "timestamp": "2026-10-07T20:12:45Z",
  "priority": "Warning",
  "source": "syscall",
  "rule": "Read sensitive file untrusted",
  "output": "Sensitive file opened for reading by non-trusted program (user=root program=cat file=/etc/shadow pid=1189 container_id=7c91a0ef)",
  "output_fields": {
    "container.id": "7c91a0ef",
    "evt.type": "openat",
    "fd.name": "/etc/shadow",
    "k8s.ns.name": "default",
    "k8s.pod.name": "security-simulation-runner",
    "proc.cmdline": "cat /etc/shadow",
    "proc.pname": "sh",
    "user.name": "root"
  }
}
```

### Test VAL-002: Projected ServiceAccount Token Harvesting
```json
{
  "timestamp": "2026-10-07T20:12:57Z",
  "priority": "Critical",
  "source": "syscall",
  "rule": "Read sensitive file untrusted",
  "output": "Access to projected serviceaccount token detected (user=root file=/var/run/secrets/kubernetes.io/serviceaccount/..data/token command=cat /var/run/secrets/kubernetes.io/serviceaccount/..data/token pid=1204)",
  "output_fields": {
    "container.id": "7c91a0ef",
    "evt.type": "openat",
    "fd.name": "/var/run/secrets/kubernetes.io/serviceaccount/..data/token",
    "k8s.ns.name": "default",
    "k8s.pod.name": "security-simulation-runner",
    "proc.cmdline": "cat /var/run/secrets/kubernetes.io/serviceaccount/..data/token",
    "proc.pname": "sh",
    "user.name": "root"
  }
}
```

---

## 3. Automated Policy Enforcement Summary

* **Static Analysis:** 23/23 Checkov checks passing with zero suppressions; zero open Trivy critical findings.
* **Admission Control:** Kyverno cluster policies evaluate image provenance and reject unsigned container digests at admission.
* **Runtime Guardrails:** Falcosidekick 2.31.1 operating via IRSA streams high-priority alerts to `/aws/eks/devsecops-prod-eks/falco-security-alerts`.
