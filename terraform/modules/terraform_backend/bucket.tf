resource "google_storage_bucket" "tf_backend" {
  name          = "${var.stack_name}-${var.project_number}-backend"
  location      = var.region
  storage_class = "REGIONAL"
  force_destroy = true
  versioning    {
    enabled = true
  }
  encryption {
    default_kms_key_name = var.kmskey
  }
}
