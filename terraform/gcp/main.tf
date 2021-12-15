
# Configure the GitHub Provider with GITHUB_TOKEN environment variable
provider "github" {}

# GKE cluster
resource "google_container_cluster" "primary" {
  name     = local.cluster_name
  location = local.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = google_compute_network.vpc.name
  subnetwork = google_compute_subnetwork.subnet.name
}

# Separately Managed Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "node-pool-${local.cluster_name}"
  location   = local.region
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_num_nodes
  node_locations = [local.zone]

  node_config {
    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]

    labels = {
      env = var.project_id
    }

    # preemptible  = true
    machine_type = "e2-standard-2"
    tags         = ["gke-node", "${var.project_id}-gke"]
    metadata = {
      disable-legacy-endpoints = "true"
    }
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
