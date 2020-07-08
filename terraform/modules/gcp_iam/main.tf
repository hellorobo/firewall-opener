data "google_project" "project" {}

resource "google_service_account" "sa-cloudfunction-update-fw" {
  account_id   = "sa-cloudfunction-update-fw"
  display_name = "Service account for Cloud Function update_fw "
}

resource "google_project_iam_custom_role" "firewall_updater" {
  role_id     = "firewall_updater"
  title       = "firewall_updater"
  description = "Firewall updater custom role"
  permissions = [
    "compute.firewalls.get",
    "compute.firewalls.update",
    "compute.networks.updatePolicy"
  ]
}

resource "google_project_iam_binding" "cloudfunction_update_fw_to_firewal_updater" {
  role = "projects/${data.google_project.project.project_id}/roles/${google_project_iam_custom_role.firewall_updater.role_id}"

  members = [
    "serviceAccount:${google_service_account.sa-cloudfunction-update-fw.email}",
  ]
}
