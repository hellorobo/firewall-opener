locals {
  source_object_file_name_prefix = "${var.region}/${var.project_id}/"
}

data "local_file" "update_fw_main" {
  filename = "${path.module}/../../../functions/update_fw/main.py"
}

data "local_file" "update_fw_requirements" {
  filename = "${path.module}/../../../functions/update_fw/requirements.txt"
}


data "archive_file" "update_fw" {
  type        = "zip"
  output_path = "${path.module}/files/update_fw.zip"

  source {
    content  = "${file("${data.local_file.update_fw_main.filename}")}"
    filename = "main.py"
  }
  source {
    content  = "${file("${data.local_file.update_fw_requirements.filename}")}"
    filename = "requirements.txt"
  }
}

resource "google_storage_bucket_object" "update_fw" {
  // we append hash to the filename as a temporary workaround for https://github.com/terraform-providers/terraform-provider-google/issues/1938
  name       = "${local.source_object_file_name_prefix}update_fw-${lower(replace(base64encode(data.archive_file.update_fw.output_md5), "=", ""))}.zip"
  bucket     = var.bucket_functions_name
  source     = data.archive_file.update_fw.output_path
  depends_on = [data.archive_file.update_fw]
}

resource "google_cloudfunctions_function" "update_fw" {
  name                  = "update_fw"
  description           = "Update firewall ingress cidr range"
  runtime               = "python37"
  timeout               = 10
  available_memory_mb   = 128
  trigger_http          = true
  entry_point           = "updateFw"
  source_archive_bucket = var.bucket_functions_name
  source_archive_object = google_storage_bucket_object.update_fw.name
  service_account_email = var.service_account_fw_update.email
  environment_variables = {
    AUTH_BEARER_TOKEN = var.token
    PROJECT = var.project
    FW_RULE = var.fw_rule
  }
  labels = var.common_tags
  region = var.function_region
}

resource "google_cloudfunctions_function_iam_member" "invoker-update_fw" {
  project        = google_cloudfunctions_function.update_fw.project
  region         = google_cloudfunctions_function.update_fw.region
  cloud_function = google_cloudfunctions_function.update_fw.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}