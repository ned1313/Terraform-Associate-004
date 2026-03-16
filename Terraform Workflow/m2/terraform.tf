terraform {
  required_version = ">=1.12.0"

  required_providers {
    random = {
      source  = "hashicorp/random"
      version = "~>2.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "<2.0"
    }
  }
}