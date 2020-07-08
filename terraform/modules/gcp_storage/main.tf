resource "google_storage_bucket" "functions" {
  name          = "${var.stack_name}-functions"
  location      = var.region
  force_destroy = true

  versioning {
    enabled = "true"
  }
  labels = var.common_tags
}
