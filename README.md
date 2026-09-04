# Hardened DevSecOps Pipeline & Cloud Architecture

An enterprise-grade, end-to-end DevSecOps reference pipeline enforcing zero-trust principles, shift-left static analysis, container runtime hardening, and keyless multi-cloud federation.

---

## Core Security Architecture

* **Cryptographic Provenance:** Enforces GPG/SSH commit signature verification via GitHub branch rulesets.
* **Shift-Left Interception:** Pre-commit hooks block hardcoded secrets, private keys, and lint violations locally prior to commit staging.
* **Static Application & IaC SAST:** Automated PR gates run Python linting (Ruff), test coverage (>90% threshold), Dockerfile auditing (Hadolint), and Terraform compliance analysis (Checkov and Trivy).
* **Runtime Lockdown:** Application runs under an unprivileged user (`UID 10001:10001`) within a hardened container image deployed to Kubernetes with `readOnlyRootFilesystem: true`.
* **Zero Static Secrets:** Cloud deployments leverage Keyless OpenID Connect (OIDC) through AWS IAM Identity Providers, strictly scoping role assumptions to repository branches.
* **Data Governance & Immutability:** Cloud storage mandates AWS KMS encryption with HTTPS-only enforcement, paired with immutable Amazon ECR image tag policies.

---

## Production Security Validation Matrix

The controls below are audited and verified against the production security baseline:

| Domain | Control Mechanism | Target / Enforcement Point | Verification Status |
| :--- | :--- | :--- | :--- |
| **Git Integrity** | SSH / GPG Commit Signing | Branch rulesets & local Git configuration | **VERIFIED** |
| **Pre-Commit** | Shift-Left Secret Interception | `.pre-commit-config.yaml` (`detect-secrets`, `hadolint`) | **VERIFIED** |
| **Container Runtime** | Hardened Non-Root Context | `Dockerfile` (`USER 10001:10001`) | **VERIFIED** |
| **Kubernetes Security** | Immutable Root Filesystem | `infra/k8s/base/deployment.yaml` (`readOnlyRootFilesystem`) | **VERIFIED** |
| **Cloud Storage** | Enforce KMS Encryption & TLS | `infra/terraform/modules/s3_storage` (`aws:kms`, HTTPS deny) | **VERIFIED** |
| **Container Registry** | Immutable Image Tags | `infra/terraform/modules/ecr` (`IMMUTABLE` tag retention) | **VERIFIED** |
| **Identity Federation** | Keyless GitHub Actions OIDC | `infra/terraform/modules/github_oidc` (`sub`/`aud` scoping) | **VERIFIED** |
| **SAST Integration** | Checkov & Trivy SARIF Exports | `.github/workflows/ci-security-lint.yml` (Code Scanning) | **VERIFIED** |

Full verification details and command evidence are maintained in [SECURITY_VALIDATION.md](SECURITY_VALIDATION.md).

---

## Repository Layout

    ├── .github/
    │   └── workflows/
    │       ├── ci-security-lint.yml   # CI linting, unit tests, SAST, container scans
    │       └── release-please.yml     # Automated semantic releases and changelogs
    ├── infra/
    │   ├── k8s/base/                  # Hardened Kubernetes base manifests
    │   └── terraform/                 # Terraform modules (ECR, S3, OIDC, VPC)
    ├── src/                           # Application source code and unit tests
    ├── .pre-commit-config.yaml        # Local shift-left hook definitions
    ├── Dockerfile                     # Multi-stage hardened non-root container build
    └── SECURITY_VALIDATION.md         # Audited control verification records

---

## Local Development & Validation

### 1. Prerequisites
* Python 3.12+
* Docker Engine
* Terraform 1.5+
* Pre-commit framework

### 2. Pre-Commit Hooks
    pip install pre-commit
    pre-commit install
    pre-commit run --all-files

### 3. Local Container Build & Security Audit
    docker build -t devsecops-api:latest .
    docker inspect devsecops-api:latest --format '{{.Config.User}}'

### 4. Running Unit Tests & Static Analysis
    pytest --cov=src --cov-fail-under=90
    ruff check .
    hadolint Dockerfile
