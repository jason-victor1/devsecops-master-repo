data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(var.tags, {
    Name        = "${var.environment}-vpc"
    Environment = var.environment
  })
}

# Restrict default security group ingress/egress (Checkov CKV_AWS_260)
resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name        = "${var.environment}-default-sg-restricted"
    Environment = var.environment
  })
}

# Public Subnets (Tagged for AWS Load Balancer Controller / Ingress)
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = merge(var.tags, {
    Name                                        = "${var.environment}-public-${var.availability_zones[count.index]}"
    Environment                                 = var.environment
    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# Private Subnets (EKS Worker Nodes & Workloads)
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = merge(var.tags, {
    Name                                        = "${var.environment}-private-${var.availability_zones[count.index]}"
    Environment                                 = var.environment
    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  })
}

# Internet Gateway for Outbound NAT & Ingress
resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(var.tags, {
    Name        = "${var.environment}-igw"
    Environment = var.environment
  })
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(var.tags, {
    Name        = "${var.environment}-nat-eip"
    Environment = var.environment
  })
}

# NAT Gateway in First Public Subnet
resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = merge(var.tags, {
    Name        = "${var.environment}-nat-gw"
    Environment = var.environment
  })

  depends_on = [aws_internet_gateway.this]
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge(var.tags, {
    Name        = "${var.environment}-public-rt"
    Environment = var.environment
  })
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private Route Table routing through NAT Gateway
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  tags = merge(var.tags, {
    Name        = "${var.environment}-private-rt"
    Environment = var.environment
  })
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# KMS CMK for VPC Flow Logs (Checkov CKV_AWS_158 & CKV_AWS_7)
resource "aws_kms_key" "flow_log" {
  description             = "KMS key for VPC flow logs CloudWatch Log Group"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnableRootManagement"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"
        Principal = {
          Service = "logs.${data.aws_region.current.region}.amazonaws.com"
        }
        Action = [
          "kms:Encrypt*",
          "kms:Decrypt*",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:Describe*"
        ]
        Resource = "*"
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.environment}-vpc-flow-log-kms"
    Environment = var.environment
  })
}

# CloudWatch Log Group for VPC Flow Logs (Checkov CKV_AWS_338: >= 365 days)
resource "aws_cloudwatch_log_group" "flow_log" {
  name              = "/aws/vpc-flow-logs/${var.environment}-vpc"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.flow_log.arn

  tags = merge(var.tags, {
    Name        = "${var.environment}-vpc-flow-log-group"
    Environment = var.environment
  })
}

resource "aws_iam_role" "flow_log" {
  name = "${var.environment}-vpc-flow-log-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = merge(var.tags, {
    Name        = "${var.environment}-vpc-flow-log-role"
    Environment = var.environment
  })
}

resource "aws_iam_role_policy" "flow_log" {
  name = "${var.environment}-vpc-flow-log-policy"
  role = aws_iam_role.flow_log.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "${aws_cloudwatch_log_group.flow_log.arn}:*"
      }
    ]
  })
}

resource "aws_flow_log" "this" {
  iam_role_arn    = aws_iam_role.flow_log.arn
  log_destination = aws_cloudwatch_log_group.flow_log.arn
  traffic_type    = "ALL"
  vpc_id          = aws_vpc.this.id

  tags = merge(var.tags, {
    Name        = "${var.environment}-vpc-flow-logs"
    Environment = var.environment
  })
}
