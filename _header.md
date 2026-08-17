![Coalfire](coalfire_logo.png)

# Google Cloud Storage Terraform Module

## Description

This module makes it easy to create one or more GCS buckets, and assign basic permissions on them to arbitrary users. Coalfire has tested this module with Terraform version 1.5.0 and the Hashicorp Google provider versions 4.70 - 5.0.

FedRAMP Compliance: High

### Usage

```
module "gcs" {
  source = "github.com/Coalfire-CF/terraform-gcp-cloud-storage"

  project_id = "project-id"
  names = [
    "tfstate",
    "backups",
    "installs"
  ]
  prefix          = var.bucket_prefix
  set_admin_roles = true
  admins          = ["group:${var.group_org_admins}"]

  encryption_key_names = {
    tfstate  = module.kms.keys["cloud-storage"]
    backups  = module.kms.keys["cloud-storage"]
    installs = module.kms.keys["cloud-storage"]
  }

  bucket_lifecycle_rules = {
    "tfstate" = [{
      action = {
        type = "Delete"
      }
      condition = {
        age = "365"
      }
    }]
  }

  versioning = {
    tfstate  = true
    backups  = true
    installs = true
  }

  location = var.region

  randomize_suffix = true
}
```

