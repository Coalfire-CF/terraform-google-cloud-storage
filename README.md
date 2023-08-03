# Google Cloud Storage Terraform Module

## Description

This module makes it easy to create one or more GCS buckets, and assign basic permissions on them to arbitrary users. 

FedRAMP Compliance: High

### Usage

```
module "gcs" {
  source = "github.com/Coalfire-CF/ACE-GCP-Cloud-Storage"

  project_id = google_project.management.project_id
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

  depends_on = [google_kms_crypto_key_iam_member.gcs_account]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 4.42, < 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 2.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 4.42, < 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 2.1 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [google_storage_bucket.buckets](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource |
| [google_storage_bucket_iam_binding.admins](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [google_storage_bucket_iam_binding.storage_admins](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket_iam_binding) | resource |
| [random_id.bucket_suffix](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admins"></a> [admins](#input\_admins) | IAM-style members who will be granted roles/storage.objectAdmin on all buckets. | `list(string)` | `[]` | no |
| <a name="input_bucket_admins"></a> [bucket\_admins](#input\_bucket\_admins) | Map of lowercase unprefixed name => comma-delimited IAM-style per-bucket admins. | `map(string)` | `{}` | no |
| <a name="input_bucket_lifecycle_rules"></a> [bucket\_lifecycle\_rules](#input\_bucket\_lifecycle\_rules) | Additional lifecycle\_rules for specific buckets. Map of lowercase unprefixed name => list of lifecycle rules to configure. | <pre>map(set(object({<br>    action    = map(string)<br>    condition = map(string)<br>  })))</pre> | `{}` | no |
| <a name="input_bucket_policy_only"></a> [bucket\_policy\_only](#input\_bucket\_policy\_only) | Disable ad-hoc ACLs on specified buckets. Defaults to true. Map of lowercase unprefixed name => boolean | `map(bool)` | `{}` | no |
| <a name="input_bucket_storage_admins"></a> [bucket\_storage\_admins](#input\_bucket\_storage\_admins) | Map of lowercase unprefixed name => comma-delimited IAM-style per-bucket storage admins. | `map(string)` | `{}` | no |
| <a name="input_default_event_based_hold"></a> [default\_event\_based\_hold](#input\_default\_event\_based\_hold) | Enable event based hold to new objects added to specific bucket. Defaults to false. Map of lowercase unprefixed name => boolean | `map(bool)` | `{}` | no |
| <a name="input_encryption_key_names"></a> [encryption\_key\_names](#input\_encryption\_key\_names) | Optional map of lowercase unprefixed name => string, empty strings are ignored. | `map(string)` | `{}` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | Optional map of lowercase unprefixed name => boolean, defaults to false. | `map(bool)` | `{}` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels to be attached to the buckets | `map(string)` | `{}` | no |
| <a name="input_lifecycle_rules"></a> [lifecycle\_rules](#input\_lifecycle\_rules) | List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches\_storage\_class should be a comma delimited string. | <pre>set(object({<br>    action    = map(string)<br>    condition = map(string)<br>  }))</pre> | `[]` | no |
| <a name="input_location"></a> [location](#input\_location) | Bucket location. | `string` | `"US"` | no |
| <a name="input_logging"></a> [logging](#input\_logging) | Map of lowercase unprefixed name => bucket logging config object. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#logging | `any` | `{}` | no |
| <a name="input_names"></a> [names](#input\_names) | Bucket name suffixes. | `list(string)` | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix used to generate the bucket name. | `string` | `""` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | Bucket project id. | `string` | n/a | yes |
| <a name="input_public_access_prevention"></a> [public\_access\_prevention](#input\_public\_access\_prevention) | Prevents public access to a bucket. Acceptable values are inherited or enforced. If inherited, the bucket uses public access prevention, only if the bucket is subject to the public access prevention organization policy constraint. | `string` | `"inherited"` | no |
| <a name="input_randomize_suffix"></a> [randomize\_suffix](#input\_randomize\_suffix) | Adds an identical, but randomized 4-character suffix to all bucket names | `bool` | `false` | no |
| <a name="input_retention_policy"></a> [retention\_policy](#input\_retention\_policy) | Map of retention policy values. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket#retention_policy | `any` | `{}` | no |
| <a name="input_set_admin_roles"></a> [set\_admin\_roles](#input\_set\_admin\_roles) | Grant roles/storage.objectAdmin role to admins and bucket\_admins. | `bool` | `false` | no |
| <a name="input_set_storage_admin_roles"></a> [set\_storage\_admin\_roles](#input\_set\_storage\_admin\_roles) | Grant roles/storage.admin role to storage\_admins and bucket\_storage\_admins. | `bool` | `false` | no |
| <a name="input_storage_admins"></a> [storage\_admins](#input\_storage\_admins) | IAM-style members who will be granted roles/storage.admin on all buckets. | `list(string)` | `[]` | no |
| <a name="input_storage_class"></a> [storage\_class](#input\_storage\_class) | Bucket storage class. | `string` | `"STANDARD"` | no |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Optional map of lowercase unprefixed name => boolean, defaults to false. | `map(bool)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_bucket"></a> [bucket](#output\_bucket) | Bucket resource (for single use). |
| <a name="output_buckets"></a> [buckets](#output\_buckets) | Bucket resources as list. |
| <a name="output_buckets_map"></a> [buckets\_map](#output\_buckets\_map) | Bucket resources by name. |
| <a name="output_name"></a> [name](#output\_name) | Bucket name (for single use). |
| <a name="output_names"></a> [names](#output\_names) | Bucket names. |
| <a name="output_names_list"></a> [names\_list](#output\_names\_list) | List of bucket names. |
| <a name="output_url"></a> [url](#output\_url) | Bucket URL (for single use). |
| <a name="output_urls"></a> [urls](#output\_urls) | Bucket URLs. |
| <a name="output_urls_list"></a> [urls\_list](#output\_urls\_list) | List of bucket URLs. |
<!-- END_TF_DOCS -->