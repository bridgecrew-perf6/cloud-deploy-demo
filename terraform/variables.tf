variable "cicd_project_id" {
  description = "CI/CD project identifier"
  type        = string
}

variable "cicd_region" {
  description = "CI/CD region"
  type        = string
}

variable "cicd_worker_network_address" {
  description = "Network address (without prefix) for CI/CD worker pool"
  type        = string
}

variable "cicd_subnet_cidr" {
  description = "CIDR for CI/CD network subnet"
  type        = string
}

variable "gke_project_id" {
  description = "GKE project identifier"
  type        = string
}

variable "gke_region" {
  description = "GKE region"
  type        = string
}

variable "gke_environments" {
  description = "Configuration of runtime environments into which application is deployed"
  type        = map(map(string))
}