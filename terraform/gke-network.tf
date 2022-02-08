resource "google_compute_network" "gke" {
  project                 = var.gke_project_id
  name                    = "gke-clusters"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "gke" {
  for_each = {
    for env in local.env_configs : env.env_name => env
  }

  project                  = var.gke_project_id
  name                     = each.value.subnet
  ip_cidr_range            = each.value.ip_range_nodes
  region                   = var.gke_region
  network                  = google_compute_network.gke.id
  private_ip_google_access = true
}

resource "google_compute_firewall" "gke-worker-icmp" {
  project       = var.gke_project_id
  name          = "gke-worker-icmp"
  network       = google_compute_network.gke.name
  source_ranges = [var.cicd_subnet_cidr]
  allow {
    protocol = "icmp"
  }
  target_service_accounts = [for env_name, env in var.gke_environments : google_service_account.gke-worker[env_name].email]
}

resource "google_compute_address" "gke-echoheaders-service" {
  project = var.gke_project_id
  for_each = {
    for env in local.env_configs : env.env_name => env
  }
  name   = "echoheaders-service-${each.key}"
  region = var.gke_region
}
