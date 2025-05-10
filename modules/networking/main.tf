# VPC Network
resource "google_compute_network" "main" {
  name                    = var.network_name
  auto_create_subnetworks = false
  project                 = var.project_id
  description             = "VPC network for ${var.network_name} in ${var.environment} environment"
  routing_mode            = "REGIONAL"
  

}

# Subnetworks for each region
resource "google_compute_subnetwork" "regional" {
  for_each = toset(var.regions)
  
  name          = "${var.network_name}-${each.value}"
  ip_cidr_range = local.subnet_cidrs[each.value]
  region        = each.value
  network       = google_compute_network.main.id
  project       = var.project_id

  # Enable Private Google Access for Cloud SQL and other services
  private_ip_google_access = true
  
  # Enable flow logs
  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

# Cloud Router for each region (needed for Cloud NAT)
resource "google_compute_router" "regional" {
  for_each = toset(var.regions)
  
  name    = "${var.network_name}-router-${each.value}"
  region  = each.value
  network = google_compute_network.main.id
  project = var.project_id
}

# Cloud NAT for outbound internet access
resource "google_compute_router_nat" "regional" {
  for_each = toset(var.regions)
  
  name                               = "${var.network_name}-nat-${each.value}"
  router                             = google_compute_router.regional[each.value].name
  region                             = each.value
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  project                            = var.project_id

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall rules
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.network_name}-allow-internal"
  network = google_compute_network.main.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [for subnet in google_compute_subnetwork.regional : subnet.ip_cidr_range]
  priority      = 1000
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.network_name}-allow-ssh"
  network = google_compute_network.main.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
  priority      = 1000
}

resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.network_name}-allow-http-https"
  network = google_compute_network.main.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["http-server", "https-server"]
  priority      = 1000
}

resource "google_compute_firewall" "allow_health_checks" {
  name    = "${var.network_name}-allow-health-checks"
  network = google_compute_network.main.name
  project = var.project_id

  allow {
    protocol = "tcp"
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16"
  ]
  priority = 1000
}

# Locals for subnet CIDR calculations
locals {
  subnet_cidrs = {
    "us-central1" = "10.0.0.0/16"
    "us-west1"    = "10.1.0.0/16"
    "us-east1"    = "10.2.0.0/16"
    "europe-west1" = "10.3.0.0/16"
    "asia-east1"   = "10.4.0.0/16"
  }
}