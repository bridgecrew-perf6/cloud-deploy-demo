output "golang_service_lb_ips" {
  value = [
      for env in local.env_configs : "${env.env_name} = ${google_compute_address.gke-echoheaders-service[env.env_name].address}"
  ]
}
