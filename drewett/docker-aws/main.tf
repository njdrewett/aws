provider "aws" {
  region = "eu-west-2"
}

module "eks_cluster" {
  source = "./modules/services/eks-cluster"

  name         = "drewett_eks_cluster"
  min_size     = 1
  max_size     = 2
  desired_size = 1

  # Due to the resources required for the system resource for Kubernates,
  # "small" instance size is the smallest we can go without issues
  instance_types = ["t3.small"]
}

provider "kubernetes" {
  host = module.eks_cluster.cluster_endpoint
  cluster_ca_certificate = base64decode(
    module.eks_cluster.cluster_certificate_authority[0].data
  )
  token = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_name
}

module "simple_webapp" {
  source = "../docker/modules/services/k8s-app"

  name           = "simple-webapp"
  image          = "training/webapp"
  replicas       = 2
  container_port = 5000

  ## Provider replaces world in he hello world string
  environment_variables = {
    PROVIDER = "Neil"
  }

  depends_on = [
    module.eks_cluster
  ]
}