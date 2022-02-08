resource "google_cloudbuild_worker_pool" "clouddeploy" {
  project  = var.cicd_project_id
  name     = "clouddeploy-pool"
  location = var.cicd_region
  worker_config {
    disk_size_gb   = 100
    machine_type   = "e2-standard-4"
    no_external_ip = false
  }

  network_config {
    peered_network = google_compute_network.cicd.id
  }
  depends_on = [google_service_networking_connection.clouddeploy-worker-conn]
}

resource "google_artifact_registry_repository" "golang" {
  provider      = google-beta
  project       = var.cicd_project_id
  location      = var.cicd_region
  repository_id = "go"
  description   = "Docker repository for Go"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository_iam_member" "golang-build" {
  provider   = google-beta
  project    = var.cicd_project_id
  location   = var.cicd_region
  repository = google_artifact_registry_repository.golang.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.build.email}"
}

resource "google_artifact_registry_repository_iam_member" "golang-gke" {
  for_each   = toset([for env in local.env_configs : env.env_name])
  provider   = google-beta
  project    = var.cicd_project_id
  location   = var.cicd_region
  repository = google_artifact_registry_repository.golang.name
  role       = "roles/artifactregistry.reader"
  member     = "serviceAccount:${google_service_account.gke-worker[each.key].email}"
}

resource "google_sourcerepo_repository" "go-sample-service" {
  project = var.cicd_project_id
  name    = "go-sample-service"
}

resource "google_cloudbuild_trigger" "go-sample-service-main" {
  project = var.cicd_project_id
  name    = "go-sample-service-main"
  trigger_template {
    branch_name = "main"
    repo_name   = google_sourcerepo_repository.go-sample-service.name
  }
  filename        = "cloudbuild.yaml"
  service_account = google_service_account.build.id
}