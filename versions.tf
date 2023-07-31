terraform {
  required_version = ">= 0.13"
  required_providers {

    google = {
      source  = "hashicorp/google"
      version = ">= 4.42, < 5.0"
    }

    random = {
      source  = "hashicorp/random"
      version = ">= 2.1"
    }
  }

  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-cloud-storage/v4.0.0"
  }

}
