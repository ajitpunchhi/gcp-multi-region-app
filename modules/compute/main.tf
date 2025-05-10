# Instance template for each instance group type
resource "google_compute_instance_template" "default" {
  for_each = var.instance_group_configs

  name_prefix  = "${each.key}-template-"
  machine_type = each.value.machine_type
  project      = var.project_id

  disk {
    source_image = "${each.value.image_project}/${each.value.image_family}"
    auto_delete  = true
    boot         = true
    disk_size_gb = each.value.disk_size
    disk_type    = each.value.disk_type
  }

  network_interface {
    network    = var.network
    subnetwork = var.subnetworks[var.primary_region].self_link
    
    # No external IP by default - instances will use Cloud NAT
    # access_config {} # Uncomment to add external IP
  }

  # Allow HTTP/HTTPS traffic
  tags = ["http-server", "https-server", "ssh"]

  # Instance metadata
  metadata = {
    environment     = var.environment
    instance_group  = each.key
    startup-script  = each.key == "web" ? local.web_startup_script : local.app_startup_script
  }

  # Service account with minimal permissions
  service_account {
    scopes = [
      "https://www.googleapis.com/auth/devstorage.read_only",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring.write"
    ]
  }

  labels = merge(var.labels, {
    instance-group-type = each.key
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Managed Instance Groups for each region and type
resource "google_compute_region_instance_group_manager" "default" {
  for_each = local.instance_group_combinations

  name               = "${each.value.type}-ig-${each.value.region}"
  base_instance_name = "${each.value.type}-instance"
  region             = each.value.region
  target_size        = var.instance_group_configs[each.value.type].instances_count
  project            = var.project_id

  version {
    instance_template = google_compute_instance_template.default[each.value.type].id
  }

  # Named ports for load balancing
  named_port {
    name = "http"
    port = 80
  }

  # Auto healing policy
  auto_healing_policies {
    health_check      = google_compute_health_check.instance_group[each.value.type].id
    initial_delay_sec = 300
  }

  # Update policy
  update_policy {
    type                         = "PROACTIVE"
    instance_redistribution_type = "PROACTIVE"
    minimal_action               = "REPLACE"
    max_surge_fixed              = 2
    max_unavailable_fixed        = 0
  }
}

# Auto-scaler for each instance group
resource "google_compute_region_autoscaler" "default" {
  for_each = local.instance_group_combinations

  name   = "${each.value.type}-autoscaler-${each.value.region}"
  region = each.value.region
  target = google_compute_region_instance_group_manager.default[each.key].id
  project = var.project_id

  autoscaling_policy {
    max_replicas    = var.instance_group_configs[each.value.type].instances_count * 3
    min_replicas    = var.instance_group_configs[each.value.type].instances_count
    cooldown_period = 60

    cpu_utilization {
      target = 0.7
    }

    metric {
      name   = "compute.googleapis.com/instance/network/received_bytes_count"
      target = 100000
      type   = "GAUGE"
    }
  }
}

# Health checks for instance groups
resource "google_compute_health_check" "instance_group" {
  for_each = var.instance_group_configs

  name               = "${each.key}-health-check"
  check_interval_sec = 10
  timeout_sec        = 5
  healthy_threshold  = 2
  unhealthy_threshold = 3
  project            = var.project_id

  http_health_check {
    port               = 80
    request_path       = "/health"
    proxy_header       = "PROXY_V1"
  }
}

# Local variables for instance group combinations
locals {
  instance_group_combinations = {
    for combo in setproduct(keys(var.instance_group_configs), var.zones) :
    "${combo[0]}-${combo[1]}" => {
      type   = combo[0]
      region = combo[1]
    }
  }

  web_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y nginx
    
    # Simple health check endpoint
    echo "server {
      listen 80;
      location /health {
        access_log off;
        return 200 'healthy\n';
        add_header Content-Type text/plain;
      }
      location / {
        root /var/www/html;
        index index.html;
      }
    }" > /etc/nginx/sites-available/default
    
    systemctl restart nginx
    systemctl enable nginx
  EOT

  app_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y docker.io
    
    # Start Docker
    systemctl start docker
    systemctl enable docker
    
    # Simple health check container
    docker run -d -p 80:80 --name health-check nginx
  EOT
}