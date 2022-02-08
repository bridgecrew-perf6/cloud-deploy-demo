resource "google_storage_bucket" "clouddeploy" {
  for_each                    = toset([for env in local.env_configs : env.env_name])
  project                     = var.cicd_project_id
  name                        = "${var.cicd_project_id}-clouddeploy-${each.key}"
  location                    = "EU"
  force_destroy               = true
  uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "clouddeploy" {
  for_each = toset([for env in local.env_configs : env.env_name])
  bucket   = google_storage_bucket.clouddeploy[each.key].name
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.clouddeploy[each.key].email}"
}