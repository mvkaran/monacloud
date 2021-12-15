resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper = false
  special = false
}

variable "gke_num_nodes" {
  default     = 1
  description = "number of gke nodes"
}

variable "project_id" {
  description = "project id"
}


data "github_repository" "repo" {
  full_name = "mvkaran/monacloud"
}

locals {
  cluster_name = "tf-monacloud-${random_string.suffix.result}"
  region = "us-central1"
  zone = "us-central1-a"
  github_env = "google-cloud"
}
