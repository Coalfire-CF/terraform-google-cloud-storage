/******************************************
  Bucket random id suffix configuration
 *****************************************/
resource "random_id" "bucket_suffix" {
  byte_length = 2
}

locals {
  suffix       = var.randomize_suffix ? random_id.bucket_suffix.hex : ""
  names_set    = toset(var.names)
  buckets_list = [for name in var.names : google_storage_bucket.buckets[name]]
  first_bucket = local.buckets_list[0]
}

resource "google_storage_bucket" "buckets" {
  for_each = local.names_set

  project                  = var.project_id
  name                     = join("-", compact([var.prefix, each.value, local.suffix]))
  location                 = var.location
  storage_class            = var.storage_class
  labels                   = merge(var.labels, { name = replace(join("-", compact([var.prefix, each.value])), ".", "-") })
  public_access_prevention = var.public_access_prevention

  force_destroy = lookup(
    var.force_destroy,
    lower(each.value),
    false,
  )
  uniform_bucket_level_access = lookup(
    var.bucket_policy_only,
    lower(each.value),
    true,
  )
  versioning {
    enabled = lookup(
      var.versioning,
      lower(each.value),
      false,
    )
  }
  default_event_based_hold = lookup(
    var.default_event_based_hold,
    lower(each.value),
    false,
  )
  dynamic "encryption" {
    for_each = trimspace(lookup(var.encryption_key_names, lower(each.value), "")) != "" ? [true] : []
    content {
      default_kms_key_name = trimspace(
        lookup(
          var.encryption_key_names,
          lower(each.value),
          "Error retrieving kms key name"
        )
      )
    }
  }

  dynamic "retention_policy" {
    for_each = lookup(var.retention_policy, each.value, {}) != {} ? [var.retention_policy[each.value]] : []
    content {
      is_locked        = lookup(retention_policy.value, "is_locked", null)
      retention_period = lookup(retention_policy.value, "retention_period", null)
    }
  }

  dynamic "lifecycle_rule" {
    for_each = setunion(var.lifecycle_rules, lookup(var.bucket_lifecycle_rules, each.value, toset([])))
    content {
      action {
        type          = lifecycle_rule.value.action.type
        storage_class = lookup(lifecycle_rule.value.action, "storage_class", null)
      }
      condition {
        age                        = lookup(lifecycle_rule.value.condition, "age", null)
        created_before             = lookup(lifecycle_rule.value.condition, "created_before", null)
        with_state                 = lookup(lifecycle_rule.value.condition, "with_state", lookup(lifecycle_rule.value.condition, "is_live", false) ? "LIVE" : null)
        matches_storage_class      = contains(keys(lifecycle_rule.value.condition), "matches_storage_class") ? split(",", lifecycle_rule.value.condition["matches_storage_class"]) : null
        matches_prefix             = contains(keys(lifecycle_rule.value.condition), "matches_prefix") ? split(",", lifecycle_rule.value.condition["matches_prefix"]) : null
        matches_suffix             = contains(keys(lifecycle_rule.value.condition), "matches_suffix") ? split(",", lifecycle_rule.value.condition["matches_suffix"]) : null
        num_newer_versions         = lookup(lifecycle_rule.value.condition, "num_newer_versions", null)
        custom_time_before         = lookup(lifecycle_rule.value.condition, "custom_time_before", null)
        days_since_custom_time     = lookup(lifecycle_rule.value.condition, "days_since_custom_time", null)
        days_since_noncurrent_time = lookup(lifecycle_rule.value.condition, "days_since_noncurrent_time", null)
        noncurrent_time_before     = lookup(lifecycle_rule.value.condition, "noncurrent_time_before", null)
      }
    }
  }

  dynamic "logging" {
    for_each = lookup(var.logging, each.value, {}) != {} ? { v = lookup(var.logging, each.value) } : {}
    content {
      log_bucket        = lookup(logging.value, "log_bucket", null)
      log_object_prefix = lookup(logging.value, "log_object_prefix", null)
    }
  }
}

resource "google_storage_bucket_iam_binding" "admins" {
  for_each = var.set_admin_roles ? local.names_set : []

  bucket = google_storage_bucket.buckets[each.value].name
  role   = "roles/storage.objectAdmin"
  members = compact(
    concat(
      var.admins,
      split(
        ",",
        lookup(var.bucket_admins, each.value, ""),
      ),
    ),
  )
}

resource "google_storage_bucket_iam_binding" "storage_admins" {
  for_each = var.set_storage_admin_roles ? local.names_set : toset([])

  bucket = google_storage_bucket.buckets[each.value].name
  role   = "roles/storage.admin"
  members = compact(
    concat(
      var.storage_admins,
      split(
        ",",
        lookup(var.bucket_storage_admins, each.value, ""),
      ),
    ),
  )
}
