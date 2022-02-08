resource "google_service_account" "gke-worker" {
  for_each     = toset([for env in local.env_configs : env.env_name])
  project      = var.gke_project_id
  account_id   = "gke-${each.key}"
  display_name = "GKE worker for ${each.key}"
}

resource "google_project_iam_member" "gke-worker-metrics" {
  for_each = toset([for env in local.env_configs : env.env_name])
  project  = var.gke_project_id
  role     = "roles/monitoring.metricWriter"
  member   = "serviceAccount:${google_service_account.gke-worker[each.key].email}"
}

resource "google_project_iam_member" "gke-worker-logs" {
  for_each = toset([for env in local.env_configs : env.env_name])
  project  = var.gke_project_id
  role     = "roles/logging.logWriter"
  member   = "serviceAccount:${google_service_account.gke-worker[each.key].email}"
}

resource "google_project_iam_member" "clouddeploy-gke" {
  for_each = toset([for env in local.env_configs : env.env_name])
  project  = var.gke_project_id
  role     = "roles/container.developer"
  member   = "serviceAccount:${google_service_account.clouddeploy[each.key].email}"
}

resource "google_project_iam_member" "test-server-gke" {
  project = var.gke_project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.test-server.email}"
}