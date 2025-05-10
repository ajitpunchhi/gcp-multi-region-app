output "network_id" {
  description = "The ID of the VPC network"
  value       = google_compute_network.main.id
}

output "network_self_link" {
  description = "The URI of the VPC network"
  value       = google_compute_network.main.self_link
}

output "subnetworks" {
  description = "Map of subnetworks"
  value = {
    for k, v in google_compute_subnetwork.regional : k => {
      id        = v.id
      self_link = v.self_link
      region    = v.region
      cidr      = v.ip_cidr_range
    }
  }
}

output "cloud_routers" {
  description = "Map of Cloud Routers"
  value = {
    for k, v in google_compute_router.regional : k => {
      id     = v.id
      region = v.region
    }
  }
}

output "nat_gateways" {
  description = "Map of Cloud NAT gateways"
  value = {
    for k, v in google_compute_router_nat.regional : k => {
      id     = v.id
      region = v.region
    }
  }
}