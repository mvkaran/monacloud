terraform {

  backend "remote" {
    organization = "mvkaran"

    workspaces {
      name = "monacloud-aws"
    }
  }
  
  required_providers {

    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.1.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}
