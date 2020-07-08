output "update_fw_trigger_url" {
  value = google_cloudfunctions_function.update_fw.https_trigger_url
  description = "CloudFunction trigger url"
}