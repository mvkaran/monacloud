terraform {

  backend "remote" {
    organization = "mvkaran"

    workspaces {
      name = "monacloud-gcp"
    }
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }

  required_version = ">= 0.14"
}
