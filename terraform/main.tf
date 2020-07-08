locals {
  common_tags = {
    creator     = var.TagTechnicalReponsible
    environment = var.TagEnvironment
    cost_center = var.TagCostCenter
  }
}


# module "terraform_state_backend" {
#   source     = "./modules/terraform_backend"

#   stack_name     = var.stack_name
#   project_number = data.google_project.current.number
#   project_id     = data.google_project.current.id
#   region         = var.region
#   kmskey         = module.terraform_state_backend.kmskey.id
# }

module "gcp_storage" {
  source = "./modules/gcp_storage"

  region         = var.region
  stack_name     = var.stack_name
  common_tags    = local.common_tags
}

module "gcp_iam" {
  source = "./modules/gcp_iam"
}

module "gcp_cloudfunctions" {
  source = "./modules/gcp_cloudfunctions"

  fw_rule        = var.fw_rule
  token          = var.token
  rest_method    = var.rest_method
  project        = var.project
  project_id     = data.google_project.current.id
  region         = var.region
  common_tags    = local.common_tags
  function_region = var.function_region
  bucket_functions_name = module.gcp_storage.bucket_functions.name
  service_account_fw_update = module.gcp_iam.service_account_fw_update
}