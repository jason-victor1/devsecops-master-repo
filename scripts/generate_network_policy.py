#!/usr/bin/env python3

netpol_content = """apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: workload-zero-trust-egress
  namespace: prod
  labels:
    app.kubernetes.io/part-of: devsecops-platform
    security.kubernetes.io/tier: perimeter-lockdown
spec:
  podSelector:
    matchLabels: {}
  policyTypes:
    - Ingress
    - Egress
  ingress:
    # Restrict ingress to authorized in-cluster traffic over port 8080
    - from:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: prod
      ports:
        - protocol: TCP
          port: 8080
  egress:
    # 1. Allow CoreDNS traffic within kube-system
    - to:
        - namespaceSelector:
            matchLabels:
              kubernetes.io/metadata.name: kube-system
      ports:
        - protocol: UDP
          port: 53
        - protocol: TCP
          port: 53

    # 2. Allow outbound HTTPS (port 443) for AWS APIs while blocking IMDS (169.254.169.254/32)
    - to:
        - ipBlock:
            cidr: 0.0.0.0/0
            except:
              - 169.254.169.254/32
              - 10.0.0.0/8
      ports:
        - protocol: TCP
          port: 443
"""

with open("k8s/policies/workload-zero-trust-egress.yaml", "w") as f:
    f.write(netpol_content.strip() + "\n")

print("k8s/policies/workload-zero-trust-egress.yaml successfully created.")
