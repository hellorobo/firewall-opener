provider "google" {
  version = "3.5.0"
  project = var.project
  region  = var.region
  zone    = var.zone
}

data "google_project" "current" {}