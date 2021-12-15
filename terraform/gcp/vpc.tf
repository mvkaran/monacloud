provider "google" {
  project = var.project_id
  region  = local.region
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = "vpc-${local.cluster_name}"
  auto_create_subnetworks = "false"
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = "subnet-${local.cluster_name}"
  network       = google_compute_network.vpc.name
  ip_cidr_range = "10.10.0.0/24"
}
