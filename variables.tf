variable "project_id" {
  description = "Bucket project id."
  type        = string
}

variable "prefix" {
  description = "Prefix used to generate the bucket name."
  type        = string
  default     = ""
}

variable "names" {
  description = "Bucket name suffixes."
  type        = list(string)
}

variable "randomize_suffix" {
  description = "Adds an identical, but randomized 4-character suffix to all bucket names"
  type        = bool
  default     = false
}

variable "location" {
  description = "Bucket location."
  type        = string
  default     = "US"
}

variable "storage_class" {
  description = "Bucket storage class."
  type        = string
  default     = "STANDARD"
}

variable "labels" {
  description = "Labels to be attached to the buckets"
  type        = map(string)
  default     = {}
}

variable "public_access_prevention" {
  description = "Prevents public access to a bucket. Acceptable values are inherited or enforced. If inherited, the bucket uses public access prevention, only if the bucket is subject to the public access prevention organization policy constraint."
  type        = string
  default     = "inherited"
}

variable "force_destroy" {
  description = "Optional map of lowercase unprefixed name => boolean, defaults to false."
  type        = map(bool)
  default     = {}
}

variable "bucket_policy_only" {
  description = "Disable ad-hoc ACLs on specified buckets. Defaults to true. Map of lowercase unprefixed name => boolean"
  type        = map(bool)
  default     = {}
}

variable "versioning" {
  description = "Optional map of lowercase unprefixed name => boolean, defaults to false."
  type        = map(bool)
  default     = {}
}

variable "default_event_based_hold" {
  description = "Enable event based hold to new objects added to specific bucket. Defaults to false. Map of lowercase unprefixed name => boolean"
  type        = map(bool)
  default     = {}
}

variable "encryption_key_names" {
  description = "Optional map of lowercase unprefixed name => string, empty strings are ignored."
  type        = map(string)
  default     = {}
}

variable "retention_policy" {
  type        = any
  default     = {}
  description = "Map of retention policy values. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket#retention_policy"
}

variable "lifecycle_rules" {
  type = set(object({
    action    = map(string)
    condition = map(string)
  }))
  description = "List of lifecycle rules to configure. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#lifecycle_rule except condition.matches_storage_class should be a comma delimited string."
  default     = []
}

variable "bucket_lifecycle_rules" {
  type = map(set(object({
    action    = map(string)
    condition = map(string)
  })))
  description = "Additional lifecycle_rules for specific buckets. Map of lowercase unprefixed name => list of lifecycle rules to configure."
  default     = {}
}

variable "logging" {
  description = "Map of lowercase unprefixed name => bucket logging config object. Format is the same as described in provider documentation https://www.terraform.io/docs/providers/google/r/storage_bucket.html#logging"
  type        = any
  default     = {}
}

variable "admins" {
  description = "IAM-style members who will be granted roles/storage.objectAdmin on all buckets."
  type        = list(string)
  default     = []
}

variable "storage_admins" {
  description = "IAM-style members who will be granted roles/storage.admin on all buckets."
  type        = list(string)
  default     = []
}

variable "bucket_admins" {
  description = "Map of lowercase unprefixed name => comma-delimited IAM-style per-bucket admins."
  type        = map(string)
  default     = {}
}

variable "bucket_storage_admins" {
  description = "Map of lowercase unprefixed name => comma-delimited IAM-style per-bucket storage admins."
  type        = map(string)
  default     = {}
}

variable "set_admin_roles" {
  description = "Grant roles/storage.objectAdmin role to admins and bucket_admins."
  type        = bool
  default     = false
}

variable "set_storage_admin_roles" {
  description = "Grant roles/storage.admin role to storage_admins and bucket_storage_admins."
  type        = bool
  default     = false
}
