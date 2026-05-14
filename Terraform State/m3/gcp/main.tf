# Replace the `name` value below with the bucket name emitted by
# ./create-bucket.ps1 or ./create-bucket.sh, then run `terraform plan` to
# generate the import configuration.

resource "google_storage_bucket" "logs" {
  name                        = "tf-import-demo-ff75b536"
  location                    = "US"
  force_destroy               = true
  uniform_bucket_level_access = true
  storage_class               = "STANDARD"
}
