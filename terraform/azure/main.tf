
# Configure AzureRM provider with Service Principal credentials
provider "azurerm" {
  features {}
  client_id = var.appId
  client_secret = var.password
  tenant_id = var.tenantId
  subscription_id = var.subscriptionId
}

# Configure the GitHub Provider with GITHUB_TOKEN environment variable
provider "github" {}

# Create a resource group to hold Kubernetes resources
resource "azurerm_resource_group" "default" {
  name     = "rg-${local.cluster_name}"
  location = "West US 2"

  tags = {
    Environment = "demo"
    GitHubOrg   = "mvkaran"
    GitHubRepo  = "monacloud"
    ProvisionedBy = "terraform"
  }
}

# Create Kubernetes cluster with a configured node pool
resource "azurerm_kubernetes_cluster" "default" {
  name                = local.cluster_name
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  dns_prefix          = local.cluster_name
  kubernetes_version  = local.cluster_version

  default_node_pool {
    name            = "workers"
    node_count      = 2
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = var.appId
    client_secret = var.password
  }

  role_based_access_control {
    enabled = true
  }

  tags = {
    Environment = "demo"
    GitHubOrg   = "mvkaran"
    GitHubRepo  = "monacloud"
    ProvisionedBy = "terraform"
  }
}

# Fetch the GitHub repository and Actions environment where secrets have to be updated for use by Actions workflows
resource "github_repository_environment" "repo_environment" {
  repository       = data.github_repository.repo.name
  environment      = local.github_env
}

# Upsert a secret named KUBECONFIG to hold the raw kubeconfig data
resource "github_actions_environment_secret" "kubeconfig" {
  repository       = data.github_repository.repo.name
  environment      = github_repository_environment.repo_environment.environment
  secret_name      = "KUBECONFIG"
  plaintext_value  = azurerm_kubernetes_cluster.default.kube_config_raw
}

# Upsert a secret named CLUSTER_NAME to hold the name of the cluster used for setting kubectl context
resource "github_actions_environment_secret" "cluster_name" {
  repository       = data.github_repository.repo.name
  environment      = github_repository_environment.repo_environment.environment
  secret_name      = "CLUSTER_NAME"
  plaintext_value  = azurerm_kubernetes_cluster.default.name
}
