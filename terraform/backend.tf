terraform {
 backend "gcs" {
   bucket = "<<CHANGEME>>-backend"
   prefix = "tf/functions"
  }
  required_version = "~> 0.12.0"
}
