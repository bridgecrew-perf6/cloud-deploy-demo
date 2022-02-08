resource "google_service_account" "clouddeploy" {
  for_each     = toset([for env in local.env_configs : env.env_name])
  project      = var.cicd_project_id
  account_id   = "clouddeploy-${each.key}"
  display_name = "CloudDeploy SA for ${each.key}"
}

resource "google_project_iam_member" "clouddeploy-log" {
  for_each = toset([for env in local.env_configs : env.env_name])
  project  = var.cicd_project_id
  role     = "roles/logging.logWriter"
  member   = "serviceAccount:${google_service_account.clouddeploy[each.key].email}"
}

resource "google_project_iam_member" "clouddeploy-storage" {
  for_each = toset([for env in local.env_configs : env.env_name])
  project  = var.cicd_project_id
  role     = "roles/storage.objectViewer"
  member   = "serviceAccount:${google_service_account.clouddeploy[each.key].email}"
}

resource "google_service_account" "test-server" {
  project      = var.cicd_project_id
  account_id   = "test-server"
  display_name = "Test server"
}

resource "google_project_iam_binding" "clouddeploy" {
  project = var.cicd_project_id
  role    = "roles/clouddeploy.serviceAgent"
  members = [
    "serviceAccount:service-${data.google_project.cicd-project.number}@gcp-sa-clouddeploy.iam.gserviceaccount.com"
  ]
}

// CloudBuild for CI

resource "google_service_account" "build" {
  project      = var.cicd_project_id
  account_id   = "cloud-build"
  display_name = "CloudBuild SA"
}

resource "google_project_iam_member" "build-log" {
  project = var.cicd_project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.build.email}"
}

resource "google_project_iam_member" "build-storage" {
  project = var.cicd_project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.build.email}"
}

resource "google_project_iam_member" "build-source-repos" {
  project = var.cicd_project_id
  role    = "roles/source.reader"
  member  = "serviceAccount:${google_service_account.build.email}"
}

resource "google_project_iam_member" "build-releaser" {
  project = var.cicd_project_id
  role    = "roles/clouddeploy.releaser"
  member  = "serviceAccount:${google_service_account.build.email}"
}

resource "google_project_iam_member" "build-sauser" {
  project = var.cicd_project_id
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.build.email}"
}
