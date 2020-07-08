resource "google_kms_key_ring" "keyring" {
  name     = "${var.stack_name}-${var.project_number}-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "kmskey" {
  name            = "${var.stack_name}-${var.project_number}-kmskey"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "604800s"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_project_iam_member" "storage-access-kms" {
  role   = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member = "serviceAccount:service-${var.project_number}@gs-project-accounts.iam.gserviceaccount.com"
}
