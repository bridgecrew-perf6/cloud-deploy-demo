data "google_compute_image" "centos8" {
  family  = "centos-stream-8"
  project = "centos-cloud"
}

data "google_compute_zones" "cicd-region-zones" {
  project = var.cicd_project_id
  region  = var.cicd_region
}

resource "google_compute_instance" "test-server" {
  project      = var.cicd_project_id
  name         = "test-server"
  machine_type = "g1-small"
  zone         = data.google_compute_zones.cicd-region-zones.names[0]
  boot_disk {
    initialize_params {
      image = data.google_compute_image.centos8.id
      size  = 20
    }
  }
  network_interface {
    subnetwork = google_compute_subnetwork.cicd-test.id
  }
  service_account {
    email  = google_service_account.test-server.email
    scopes = ["cloud-platform"]
  }
}