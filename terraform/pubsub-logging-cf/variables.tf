variable "project_id" {
  type = string
}

variable "region" {
  type = string
}

variable "function_name" {
  description = "Pub/Sub logging function name"
  type        = string
}

variable "service_account" {
  description = "Pub/Sub logging function service account"
  type        = string
}

variable "bucket_name" {
  description = "Cloud Storage bucket name for cloud function sources"
  type        = string
}

variable "bucket_location" {
  description = "Cloud Storage bucket location for cloud function sources"
  type        = string
}

variable "pubsub_topic" {
  description = "Pub/Sub topic to subscribe to"
  type        = string
}

variable "function_timeout" {
  type        = number
  description = "Cloud Function timeout (maximum 540 seconds)"
  default     = 240
}