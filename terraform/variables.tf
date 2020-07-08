variable "project" {}
variable "region" {}
variable "stack_name" {}
variable "zone" {}

variable "token" {}
variable "rest_method" {}
variable "fw_rule" {}
variable "function_region" {}

variable "TagTechnicalReponsible" {
  type = string
}
variable "TagEnvironment" {
  type = string
}
variable "TagCostCenter" {
  type = string
}