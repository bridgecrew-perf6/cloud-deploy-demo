resource "google_compute_router" "gke" {
  project = var.gke_project_id
  name    = "gke"
  region  = var.gke_region
  network = google_compute_network.gke.name
  bgp {
    asn = 64515
  }
}

resource "google_compute_ha_vpn_gateway" "gke-vpn" {
  project = var.gke_project_id
  region  = var.gke_region
  name    = "gke-vpn"
  network = google_compute_network.gke.id
}

resource "google_compute_vpn_tunnel" "gke-0" {
  project               = var.gke_project_id
  name                  = "gke-0"
  region                = var.gke_region
  vpn_gateway           = google_compute_ha_vpn_gateway.gke-vpn.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.cicd-vpn.id
  shared_secret         = "qwerty123"
  router                = google_compute_router.gke.id
  vpn_gateway_interface = 0
}

resource "google_compute_vpn_tunnel" "gke-1" {
  project               = var.gke_project_id
  name                  = "gke-1"
  region                = var.gke_region
  vpn_gateway           = google_compute_ha_vpn_gateway.gke-vpn.id
  peer_gcp_gateway      = google_compute_ha_vpn_gateway.cicd-vpn.id
  shared_secret         = "qwerty123"
  router                = google_compute_router.gke.id
  vpn_gateway_interface = 1
}

resource "google_compute_router_interface" "gke-if0" {
  project    = var.gke_project_id
  name       = "gke-if0"
  router     = google_compute_router.gke.name
  region     = var.gke_region
  ip_range   = "169.254.0.2/30"
  vpn_tunnel = google_compute_vpn_tunnel.gke-0.name
}

resource "google_compute_router_interface" "gke-if1" {
  project    = var.gke_project_id
  name       = "gke-if1"
  router     = google_compute_router.gke.name
  region     = var.gke_region
  ip_range   = "169.254.1.2/30"
  vpn_tunnel = google_compute_vpn_tunnel.gke-1.name
}

resource "google_compute_router_peer" "gke-peer0" {
  project                   = var.gke_project_id
  name                      = "gke-peer0"
  router                    = google_compute_router.gke.name
  region                    = var.gke_region
  peer_ip_address           = "169.254.0.1"
  peer_asn                  = 64514
  advertised_route_priority = 100
  advertise_mode            = "CUSTOM"
  advertised_groups         = ["ALL_SUBNETS"]
  dynamic "advertised_ip_ranges" {
    for_each = {
      for env in local.env_configs : env.env_name => env
    }
    content {
      range       = advertised_ip_ranges.value.ip_range_master
      description = "Maser CIDR range for ${advertised_ip_ranges.key} cluster"
    }
  }
  interface = google_compute_router_interface.gke-if0.name
}

resource "google_compute_router_peer" "gke-peer1" {
  project                   = var.gke_project_id
  name                      = "gke-peer1"
  router                    = google_compute_router.gke.name
  region                    = var.gke_region
  peer_ip_address           = "169.254.1.1"
  peer_asn                  = 64514
  advertised_route_priority = 100
  advertise_mode            = "CUSTOM"
  advertised_groups         = ["ALL_SUBNETS"]
  dynamic "advertised_ip_ranges" {
    for_each = {
      for env in local.env_configs : env.env_name => env
    }
    content {
      range       = advertised_ip_ranges.value.ip_range_master
      description = "Maser CIDR range for ${advertised_ip_ranges.key} cluster"
    }
  }
  interface = google_compute_router_interface.gke-if1.name
}