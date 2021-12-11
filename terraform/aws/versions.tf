terraform {

  backend "remote" {
    organization = "mvkaran"

    workspaces {
      name = "monacloud-demo"
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
  }
}
