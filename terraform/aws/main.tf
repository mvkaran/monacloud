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

# Configure the GitHub Provider with GITHUB_TOKEN environment variable
provider "github" {}

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

# Fetch the GitHub repository and Actions environment where secrets have to be updated for use by Actions workflows
resource "github_repository_environment" "repo_environment" {
  repository       = data.github_repository.repo.name
  environment      = local.github_env
}


# Upsert a secret named CLUSTER_NAME to hold the name of the cluster used for setting kubectl context
resource "github_actions_environment_secret" "cluster_name" {
  repository       = data.github_repository.repo.name
  environment      = github_repository_environment.repo_environment.environment
  secret_name      = "CLUSTER_NAME"
  plaintext_value  = local.cluster_name
}
