resource "google_project_service" "cicd-servicenetworking" {
  project            = var.cicd_project_id
  service            = "servicenetworking.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "cicd-clouddeploy" {
  project            = var.cicd_project_id
  service            = "clouddeploy.googleapis.com"
  disable_on_destroy = false
}