terraform {
  required_version = ">= 0.13.0"

  required_providers {
    google  = ">= 3.40.0"
    archive = ">= 2.2.0"
  }
}

resource "google_project_service" "service-account-apis" {
  for_each           = toset(["cloudfunctions.googleapis.com"])
  project            = var.project_id
  service            = each.value
  disable_on_destroy = false
}

resource "google_service_account" "service-account" {
  project      = var.project_id
  account_id   = var.service_account
  display_name = "${var.service_account} Service Account"
}

resource "google_cloudfunctions_function" "function" {
  project     = var.project_id
  region      = var.region
  name        = var.function_name
  description = "Logging function"
  runtime     = "python38"

  service_account_email = google_service_account.service-account.email

  available_memory_mb   = 128
  source_archive_bucket = google_storage_bucket.function-bucket.name
  source_archive_object = google_storage_bucket_object.function-archive.name
  entry_point           = "process_pubsub"
  timeout               = var.function_timeout

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = var.pubsub_topic
    failure_policy {
      retry = true
    }
  }
}

resource "google_storage_bucket" "function-bucket" {
  project                     = var.project_id
  name                        = var.bucket_name
  location                    = var.bucket_location
  uniform_bucket_level_access = true
}

locals {
  function_files       = ["main.py", "requirements.txt"]
  all_function_files   = setunion([for glob in local.function_files : fileset(path.module, glob)]...)
  function_file_hashes = [for file_path in local.all_function_files : filemd5(format("%s/%s", path.module, file_path))]
}

data "archive_file" "function-zip" {
  type        = "zip"
  output_path = "${path.module}/index.zip"
  dynamic "source" {
    for_each = local.all_function_files
    content {
      content  = file(format("%s/%s", path.module, source.value))
      filename = source.value
    }
  }
}

resource "google_storage_bucket_object" "function-archive" {
  name   = format("index-%s.zip", md5(join(",", local.function_file_hashes)))
  bucket = google_storage_bucket.function-bucket.name
  source = format("%s/index.zip", path.module)
  depends_on = [
    data.archive_file.function-zip
  ]
}
