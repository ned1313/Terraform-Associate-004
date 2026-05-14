resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = false
}

# Note: we intentionally do NOT specify a soft_delete_policy block. The
# block is marked Optional+Computed by the provider, so the server-side
# default (7-day soft delete) is what ends up in state on first apply.
# The drift script then changes that retention duration out-of-band; the
# next refresh will record the new value in state but `terraform plan`
# will propose no changes because nothing in config manages the policy.
resource "google_storage_bucket" "logs" {
  name                        = "tf-state-drift-${random_string.suffix.result}"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
}

output "bucket_name" {
  value = google_storage_bucket.logs.name
}
