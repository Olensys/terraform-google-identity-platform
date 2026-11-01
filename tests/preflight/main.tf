# Helper for tests/complete.tftest.hcl: reads the test project so the plan-only
# integration run proves that the workflow's credentials reach Google Cloud.
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = { source = "hashicorp/google", version = ">= 6.0, < 8.0" }
  }
}

variable "project_id" {
  description = "GCP project the integration run targets."
  type        = string
}

data "google_project" "this" {
  project_id = var.project_id
}

output "project_number" {
  description = "Numeric id of the project, read during plan."
  value       = data.google_project.this.number
}
