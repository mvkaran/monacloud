terraform {
  
  backend "remote" {
    organization = "mvkaran"

    workspaces {
      name = "monacloud-azure"
    }
  }
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "2.66.0"
    }

    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }

  required_version = ">= 0.14"
}
