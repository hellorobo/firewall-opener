output "function_trigger_url" {
  value = module.gcp_cloudfunctions.update_fw_trigger_url
  description = "CloudFunction trigger url"
}