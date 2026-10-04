# IAM Trust Policy for AWS EKS Pod Identity Agent (pods.eks.amazonaws.com)
resource "aws_iam_role" "kyverno_ecr" {
  name = "${var.environment}-kyverno-ecr-reader-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.environment}-kyverno-ecr-reader"
    Environment = var.environment
  })
}

# Attach standard ECR Read-Only policy to allow Kyverno signature/digest verification
resource "aws_iam_role_policy_attachment" "kyverno_ecr_ro" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.kyverno_ecr.name
}

# Native EKS Pod Identity Association
resource "aws_eks_pod_identity_association" "kyverno" {
  cluster_name    = var.cluster_name
  namespace       = var.namespace
  service_account = var.service_account
  role_arn        = aws_iam_role.kyverno_ecr.arn

  tags = merge(var.tags, {
    Name        = "${var.environment}-kyverno-pod-identity"
    Environment = var.environment
  })
}
