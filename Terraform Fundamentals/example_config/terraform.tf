terraform {
  required_providers {
    random = {
      source = "hashicorp/random"
      version = "3.8.1"
    }

    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}