resource "google_project_service" "gke-clusters" {
  project            = var.gke_project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}
