output "service_account_fw_update" {
  value = google_service_account.sa-cloudfunction-update-fw
  description = "Service account for firewall update CloudFunction"
}