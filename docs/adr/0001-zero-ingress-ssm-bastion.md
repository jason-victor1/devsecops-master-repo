# ADR 0001: Zero-Ingress SSM WebSocket Tunneling vs. Public SSH Bastion

## Status
Accepted

## Context
Operators require administrative kubectl access to the Amazon EKS 1.31 control plane. Exposing the EKS endpoint publicly (`cluster_endpoint_public_access = true`) exposes the Kubernetes API server directly to internet-wide reconnaissance and DDoS attacks. Conversely, conventional bastion jump hosts require public IPv4 allocations, Internet Gateway route tables, and open inbound SSH (port 22) security group rules, creating credential leakage risks and perpetual SSH brute-force attack surfaces.

## Decision
We implemented a zero-ingress private bastion architecture utilizing AWS Systems Manager (SSM) Session Manager:
* Provisioned an ARM64 `t4g.nano` EC2 instance residing exclusively within a private management subnet.
* Attached an ingress-free security group (`ingress = []`) with zero open listening ports.
* Configured a least-privilege egress rule restricted to outbound HTTPS (port 443) targeting AWS SSM regional VPC endpoints and AWS APIs.
* Enforced IMDSv2 (`http_tokens = "required"`, hop limit 1) and gp3 KMS/EBS volume encryption.
* Configured local developer workstations to establish an encrypted WebSocket tunnel via the SSM Session Manager Plugin (`aws ssm start-session --document-name AWS-StartPortForwardingSessionToRemoteHost`).

## Consequences
* **Positive:** Eliminates inbound port 22 exposure, public IP costs, and bastion SSH key management. Session connections and commands are auditable natively within AWS CloudTrail and Amazon CloudWatch Logs.
* **Negative:** Operators must install the AWS CLI Session Manager plugin locally. Control plane reachability depends on the availability of regional AWS Systems Manager APIs.
