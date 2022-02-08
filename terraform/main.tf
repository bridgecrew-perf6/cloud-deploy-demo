locals {
  network_name = "cloud-deploy-demo"
  env_configs = flatten([
    for env_name, env in var.gke_environments : {
      env_name          = env_name
      subnet            = env.subnet
      ip_range_nodes    = cidrsubnet(env.ip_range_base, 10, 0)
      ip_range_master   = cidrsubnet(env.ip_range_base, 12, 16)
      ip_range_pods     = cidrsubnet(env.ip_range_base, 2, 1)
      ip_range_services = cidrsubnet(env.ip_range_base, 4, 8)
      pods_per_node     = 110
      sa_name           = env.sa_name
    }
  ])
}

data "google_project" "cicd-project" {
  project_id = var.cicd_project_id
}
