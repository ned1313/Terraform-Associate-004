# Replace the `BUCKET_NAME` value below with the bucket name emitted by
# ./create-bucket.ps1 or ./create-bucket.sh, then run `terraform plan` to
# generate the import configuration.

import {
  to = google_storage_bucket.logs
  id = "BUCKET_NAME"
}
