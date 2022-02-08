locals {
  clouddeploy_topics = ["resources", "operations", "approvals"]
}

resource "google_pubsub_topic" "clouddeploy" {
  for_each = toset(local.clouddeploy_topics)
  project  = var.cicd_project_id
  name     = "clouddeploy-${each.key}"
}

module "clouddeploy-logging" {
  for_each        = toset(local.clouddeploy_topics)
  source          = "./pubsub-logging-cf"
  project_id      = var.cicd_project_id
  region          = var.cicd_region
  function_name   = "clouddeploy-logging-${each.key}"
  service_account = "clouddeploy-logging-${each.key}"
  pubsub_topic    = google_pubsub_topic.clouddeploy[each.key].id
  bucket_name     = "clouddeploy-logging-cf-${each.key}"
  bucket_location = "EU"
}