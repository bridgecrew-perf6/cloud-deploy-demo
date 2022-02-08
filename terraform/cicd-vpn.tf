resource "google_compute_router" "cicd" {
  project = var.cicd_project_id
  name    = "cicd"
  region  = var.cicd_region
  network = google_compute_network.cicd.name
  bgp {
    asn = 64514
  }
}

resource "google_compute_ha_vpn_gateway" "cicd-vpn" {
  project = var.cicd_project_id
  region  = var.cicd_region
  name    = "cicd-vpn"
  network = google_compute_network.cicd.id
}

resource "google_compute_vpn_tunnel" "cicd-0" {
  project               = var.cicd_project_id
  name                  = "cicd-0"
  region                = var.cicd_region
  vpn_gateway           = google_compute_ha_vpn_gateway.cicd-vpn.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.gke-vpn.id
  shared_secret         = "qwerty123"
  router                = google_compute_router.cicd.id
  vpn_gateway_interface = 0
}

resource "google_compute_vpn_tunnel" "cicd-1" {
  project               = var.cicd_project_id
  name                  = "cicd-1"
  region                = var.cicd_region
  vpn_gateway           = google_compute_ha_vpn_gateway.cicd-vpn.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.gke-vpn.id
  shared_secret         = "qwerty123"
  router                = google_compute_router.cicd.id
  vpn_gateway_interface = 1
}

resource "google_compute_router_interface" "cicd-if0" {
  project    = var.cicd_project_id
  name       = "cicd-if0"
  router     = google_compute_router.cicd.name
  region     = var.cicd_region
  ip_range   = "169.254.0.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.cicd-0.name
}

resource "google_compute_router_interface" "cicd-if1" {
  project    = var.cicd_project_id
  name       = "cicd-if1"
  router     = google_compute_router.cicd.name
  region     = var.cicd_region
  ip_range   = "169.254.1.1/30"
  vpn_tunnel = google_compute_vpn_tunnel.cicd-1.name
}

resource "google_compute_router_peer" "cicd-peer0" {
  project                   = var.cicd_project_id
  name                      = "cicd-peer0"
  router                    = google_compute_router.cicd.name
  region                    = var.cicd_region
  peer_ip_address           = "169.254.0.2"
  peer_asn                  = 64515
  advertised_route_priority = 100
  advertise_mode            = "CUSTOM"
  advertised_groups         = ["ALL_SUBNETS"]
  advertised_ip_ranges {
    range       = "${google_compute_global_address.clouddeploy-worker.address}/${google_compute_global_address.clouddeploy-worker.prefix_length}"
    description = "CloudDeploy private worker CIDR"
  }
  interface = google_compute_router_interface.cicd-if0.name
}

resource "google_compute_router_peer" "cicd-peer1" {
  project                   = var.cicd_project_id
  name                      = "cicd-peer1"
  router                    = google_compute_router.cicd.name
  region                    = var.cicd_region
  peer_ip_address           = "169.254.1.2"
  peer_asn                  = 64515
  advertised_route_priority = 100
  advertise_mode            = "CUSTOM"
  advertised_groups         = ["ALL_SUBNETS"]
  advertised_ip_ranges {
    range       = "${google_compute_global_address.clouddeploy-worker.address}/${google_compute_global_address.clouddeploy-worker.prefix_length}"
    description = "CloudDeploy private worker CIDR"
  }
  interface = google_compute_router_interface.cicd-if1.name
}