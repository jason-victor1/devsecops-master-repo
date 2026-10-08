#!/usr/bin/env python3

policy_content = """apiVersion: kyverno.io/v1
kind: ClusterPolicy
metadata:
  name: check-image-signatures-prod
  annotations:
    policies.kyverno.io/title: Verify Production Container Signatures & SBOM via Keyless Cosign
    policies.kyverno.io/category: Supply Chain Security
    policies.kyverno.io/severity: high
    policies.kyverno.io/subject: Pod
    policies.kyverno.io/description: >-
      Enforces that all container images deployed from AWS ECR must have a valid
      cryptographic signature and a verified CycloneDX SBOM attestation logged
      in Sigstore Rekor, signed by the authorized GitHub Actions workflow.
spec:
  validationFailureAction: Enforce
  webhookTimeoutSeconds: 30
  rules:
    - name: verify-ecr-cosign-signature-and-sbom
      match:
        any:
          - resources:
              kinds:
                - Pod
              namespaces:
                - default
                - prod
      verifyImages:
        - imageReferences:
            - "*.dkr.ecr.*.amazonaws.com/devsecops-api:*"
            - "*.dkr.ecr.*.amazonaws.com/devsecops-api@sha256:*"
            - "*.dkr.ecr.*.amazonaws.com/event-ingestion-api-prod:*"
            - "*.dkr.ecr.*.amazonaws.com/event-ingestion-api-prod@sha256:*"
          attestors:
            - entries:
                - keyless:
                    issuer: "https://token.actions.githubusercontent.com"
                    subjectRegExp: "^https://github.com/jason-victor1/.*"
                    rekor:
                      url: "https://rekor.sigstore.dev"
          attestations:
            - predicateType: https://cyclonedx.org/schema
              attestors:
                - entries:
                    - keyless:
                        issuer: "https://token.actions.githubusercontent.com"
                        subjectRegExp: "^https://github.com/jason-victor1/.*"
                        rekor:
                          url: "https://rekor.sigstore.dev"
"""

with open("k8s/policies/check-image-signatures-prod.yaml", "w") as f:
    f.write(policy_content.strip() + "\n")

print("Kyverno ClusterPolicy updated with dual Cosign signature and SBOM attestation verification.")
