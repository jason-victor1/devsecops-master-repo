# -----------------------------------------------------------------------------
# Amazon Linux 2023 ARM64 AMI (Pre-installed AWS SSM Agent)
# -----------------------------------------------------------------------------
data "aws_ami" "al2023_arm64" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-arm64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# -----------------------------------------------------------------------------
# IAM Role & Instance Profile for SSM Managed Core
# -----------------------------------------------------------------------------
resource "aws_iam_role" "bastion" {
  name = "devsecops-${var.environment}-ssm-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_role_policy_attachment" "ssm_managed" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  role       = aws_iam_role.bastion.name
}

resource "aws_iam_instance_profile" "bastion" {
  name = "devsecops-${var.environment}-ssm-bastion-profile"
  role = aws_iam_role.bastion.name
}

# -----------------------------------------------------------------------------
# Security Group (Zero Ingress, Egress only to EKS & HTTPS endpoints)
# -----------------------------------------------------------------------------
resource "aws_security_group" "bastion" {
  name        = "devsecops-${var.environment}-ssm-bastion-sg"
  description = "Security group for SSM Session Manager private jump host"
  vpc_id      = var.vpc_id

  # Strict zero-ingress policy (no port 22 SSH, no inbound public traffic)
  ingress = []

  egress {
    description = "Allow HTTPS outbound for SSM agent communication and AWS APIs"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.tags, {
    Name = "devsecops-${var.environment}-ssm-bastion-sg"
  })
}

# Allow bastion security group ingress into EKS control plane on port 443
resource "aws_security_group_rule" "eks_ingress_from_bastion" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = var.eks_cluster_security_group_id
  description              = "Allow HTTPS management traffic from SSM bastion"
}

# -----------------------------------------------------------------------------
# EC2 Micro Instance
# -----------------------------------------------------------------------------
resource "aws_instance" "bastion" {
  ami                  = data.aws_ami.al2023_arm64.id
  instance_type        = "t4g.nano"
  subnet_id            = var.subnet_id
  iam_instance_profile = aws_iam_instance_profile.bastion.name

  vpc_security_group_ids = [aws_security_group.bastion.id]

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # IMDSv2 enforced (CKV_AWS_28)
    http_put_response_hop_limit = 1
  }

  root_block_device {
    encrypted   = true # KMS/EBS Encryption enforced (CKV_AWS_3)
    volume_type = "gp3"
    volume_size = 8
  }

  tags = merge(var.tags, {
    Name = "devsecops-${var.environment}-ssm-bastion"
  })
}
