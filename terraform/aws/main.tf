data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  
  cluster_name    = local.cluster_name
  cluster_version = local.cluster_version
  
  vpc_id  = module.vpc.vpc_id
  subnets = module.vpc.private_subnets

  node_groups_defaults = {
    ami_type  = "AL2_x86_64"
    disk_size = 20
  }
  
  node_groups = {
    workers = {
      desired_capacity = 1
      max_capacity     = 3
      min_capacity     = 1

      instance_types = ["t2.medium"]
      k8s_labels = {
        Environment = "demo"
        GitHubRepo  = "monacloud"
        GitHubOrg   = "mvkaran"
        ProvisionedBy = "terraform"
      }
      additional_tags = {
        ProvisionedBy = "terraform"
      }

      update_config = {
        max_unavailable_percentage = 50 # or set `max_unavailable`
      }
    }
  }

  tags = {
    Environment = "demo"
    GitHubRepo  = "monacloud"
    GitHubOrg   = "mvkaran"
    ProvisionedBy = "terraform"
  }
}


