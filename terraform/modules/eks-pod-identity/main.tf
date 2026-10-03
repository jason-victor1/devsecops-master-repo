# IAM Role for Kyverno Pod Identity
resource "aws_iam_role" "kyverno_pod_identity" {
  name = "KyvernoEksPodIdentityRole"

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

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
    Service     = "kyverno"
  }
}

# Attach ECR Read-Only Permissions
resource "aws_iam_role_policy_attachment" "kyverno_ecr_read" {
  role       = aws_iam_role.kyverno_pod_identity.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

# EKS Pod Identity Association
resource "aws_eks_pod_identity_association" "kyverno" {
  cluster_name    = var.eks_cluster_name
  namespace       = "kyverno"
  service_account = "kyverno-admission-controller"
  role_arn        = aws_iam_role.kyverno_pod_identity.arn
}
