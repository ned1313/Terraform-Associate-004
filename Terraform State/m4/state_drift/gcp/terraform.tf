terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
}

provider "google" {
  # Project and region are read from the GOOGLE_PROJECT and GOOGLE_REGION
  # environment variables, or set them explicitly here.
  # project = "my-project-id"
  # region  = "us-central1"
}
