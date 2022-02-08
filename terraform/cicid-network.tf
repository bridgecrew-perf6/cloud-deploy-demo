resource "google_compute_network" "cicd" {
  project                 = var.cicd_project_id
  name                    = "cicd"
  auto_create_subnetworks = false
  depends_on              = [google_project_service.cicd-servicenetworking]
}

resource "google_compute_subnetwork" "cicd-test" {
  project                  = var.cicd_project_id
  name                     = "cicd-test"
  ip_cidr_range            = var.cicd_subnet_cidr
  region                   = var.cicd_region
  network                  = google_compute_network.cicd.id
  private_ip_google_access = true
}

resource "google_compute_global_address" "clouddeploy-worker" {
  project       = var.cicd_project_id
  name          = "clouddeploy-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 24
  network       = google_compute_network.cicd.id
  address       = var.cicd_worker_network_address
}

resource "google_service_networking_connection" "clouddeploy-worker-conn" {
  network                 = google_compute_network.cicd.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.clouddeploy-worker.name]
  depends_on              = [google_project_service.cicd-servicenetworking]
}

resource "google_compute_firewall" "cicd-ssh-test" {
  project       = var.cicd_project_id
  name          = "cicd-ssh"
  source_ranges = ["0.0.0.0/0"]
  network       = google_compute_network.cicd.name
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  target_service_accounts = [google_service_account.test-server.email]
}

resource "google_compute_router_nat" "cicd-nat" {
  project                            = var.cicd_project_id
  name                               = "cicd-nat"
  router                             = google_compute_router.cicd.name
  region                             = google_compute_router.cicd.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"
  subnetwork {
    name                    = google_compute_subnetwork.cicd-test.id
    source_ip_ranges_to_nat = ["PRIMARY_IP_RANGE"]
  }
}