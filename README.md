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
| **Container Registry**| Immutable Image Tags | `infra/terraform/modules/ecr` (`IMMUTABLE` tag retention) | **VERIFIED** |
| **Identity Federation**| Keyless GitHub Actions OIDC | `infra/terraform/modules/github_oidc` (`sub`/`aud` scoping) | **VERIFIED** |
| **SAST Integration** | Checkov & Trivy SARIF Exports | `.github/workflows/ci-security-lint.yml` (Code Scanning) | **VERIFIED** |

Full verification details and command evidence are maintained in [SECURITY_VALIDATION.md](SECURITY_VALIDATION.md).

---

## Repository Layout

    devsecops-master-repo/
    ├── .editorconfig                      # Consistent editor configurations
    ├── .gitattributes                     # Git line-ending and diff behavior
    ├── .gitignore                         # Excluded local artifacts and caches
    ├── .pre-commit-config.yaml            # Shift-left pre-commit hook hooks
    ├── .tflint.hcl                        # TFLint ruleset and module configuration
    ├── CONTRIBUTING.md                    # Contribution guidelines and standards
    ├── Dockerfile                         # Multi-stage hardened non-root container
    ├── README.md                          # Repository documentation and matrix
    ├── SECURITY.md                        # Security policy and disclosure process
    ├── SECURITY_VALIDATION.md             # Audited production compliance records
    ├── .github/
    │   ├── CODEOWNERS                     # Mandatory code review requirements
    │   ├── dependabot.yml                 # Automated dependency updates
    │   ├── pull_request_template.md       # Standardized PR checklist
    │   ├── ISSUE_TEMPLATE/
    │   │   └── bug_report.yml             # Structured issue intake schema
    │   └── workflows/
    │       ├── ci-security-lint.yml       # Linting, unit tests, SAST, Trivy scans
    │       └── release-please.yml         # Automated changelog and semantic release
    ├── infra/
    │   ├── k8s/
    │   │   ├── base/                      # Base manifests (deployment, service, kustomization)
    │   │   │   ├── deployment.yaml
    │   │   │   ├── kustomization.yaml
    │   │   │   └── service.yaml
    │   │   └── overlays/                  # Environment-specific overlays
    │   │       ├── dev/
    │   │       │   └── kustomization.yaml
    │   │       └── prod/
    │   │           └── kustomization.yaml
    │   └── terraform/
    │       ├── environments/              # Root deployment configurations
    │       │   ├── dev/
    │       │   │   ├── backend.tf
    │       │   │   ├── main.tf
    │       │   │   ├── outputs.tf
    │       │   │   ├── variables.tf
    │       │   │   └── versions.tf
    │       │   └── prod/
    │       │       ├── backend.tf
    │       │       ├── main.tf
    │       │       ├── outputs.tf
    │       │       ├── variables.tf
    │       │       └── versions.tf
    │       └── modules/                   # Reusable infrastructure modules
    │           ├── ecr/
    │           │   ├── main.tf
    │           │   ├── outputs.tf
    │           │   └── variables.tf
    │           ├── github_oidc/
    │           │   ├── main.tf
    │           │   ├── outputs.tf
    │           │   └── variables.tf
    │           └── s3_storage/
    │               ├── main.tf
    │               ├── outputs.tf
    │               └── variables.tf
    └── src/
        ├── requirements.txt               # Pinned Python dependencies
        ├── app/
        │   ├── __init__.py
        │   └── main.py                    # Application entrypoint
        └── tests/
            ├── __init__.py
            └── test_main.py               # Unit test suites (90%+ coverage)

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
