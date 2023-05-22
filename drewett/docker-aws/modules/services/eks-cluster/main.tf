# Allow EKS to assume the IAM role
data "aws_iam_policy_document" "cluster_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}


# Create an IAM role for the control plane
resource "aws_iam_role" "cluster" {
  name               = "${var.name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume_role.json
}

# Attach the permissions the IAM role needs
resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# Use default VPC, real-world should be a custom VPC and Subnets.
data "aws_vpc" "default" {
  default = "true"
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

# Create the AWS EKS Cluster 
resource "aws_eks_cluster" "eks_cluster" {
  name     = var.name
  role_arn = aws_iam_role.cluster.arn
  version  = "1.21"

  vpc_config {
    subnet_ids = data.aws_subnets.default.ids
  }

  ## Ensure the IAM Role Permissions are created before and deleted after
  ## the EKS cluster. Otherwise, EKS will not be able to properly delete 
  ## the EKS managed EC2 infrastructure such as Security Groups
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]
}

# Worker nodes setup

data "aws_iam_policy_document" "node_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Create an IAM Role for the node group
resource "aws_iam_role" "node_group_role" {
  name               = "${var.name}-node-group"
  assume_role_policy = data.aws_iam_policy_document.node_assume_role.json
}

# Attach permissions to node groups
resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node_group_role.name
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.name
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = data.aws_subnets.default.ids
  instance_types  = var.instance_types

  scaling_config {
    min_size     = var.min_size
    max_size     = var.max_size
    desired_size = var.desired_size
  }

  ## Ensure that the role permissions are created before and deleted after the EKS Group node, 
  ## Otherwise, EKS will not be able to properly delete the EC2 instances and Elastic Network Interfaces
  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
  ]

}