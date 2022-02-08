resource "google_container_cluster" "gke" {
  for_each = {
    for env in local.env_configs : env.env_name => env
  }

  project                  = var.gke_project_id
  name                     = each.key
  location                 = var.gke_region
  remove_default_node_pool = true
  initial_node_count       = 1

  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = true
    master_ipv4_cidr_block  = each.value.ip_range_master
  }

  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "${google_compute_global_address.clouddeploy-worker.address}/${google_compute_global_address.clouddeploy-worker.prefix_length}"
      display_name = "CloudDeploy private worker CIDR"
    }
    cidr_blocks {
      cidr_block   = var.cicd_subnet_cidr
      display_name = "CI/CD test subnet CIDR"
    }
  }

  network                   = google_compute_network.gke.id
  subnetwork                = google_compute_subnetwork.gke[each.key].id
  networking_mode           = "VPC_NATIVE"
  default_max_pods_per_node = 110
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = each.value.ip_range_pods
    services_ipv4_cidr_block = each.value.ip_range_services
  }
  release_channel {
    channel = "REGULAR"
  }
  addons_config {
    network_policy_config {
      disabled = false
    }
  }
  network_policy {
    enabled = true
  }
  workload_identity_config {
    workload_pool = "${var.gke_project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "gke-pool" {
  for_each           = toset([for env in local.env_configs : env.env_name])
  project            = var.gke_project_id
  name               = "primary-node-pool"
  cluster            = google_container_cluster.gke[each.key].name
  location           = var.gke_region
  initial_node_count = 1

  node_config {
    machine_type    = "n1-standard-2"
    service_account = google_service_account.gke-worker[each.key].email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    workload_metadata_config {
      mode = "GKE_METADATA"
    }
  }
}