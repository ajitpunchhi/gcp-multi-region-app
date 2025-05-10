output "instance_templates" {
  description = "Instance templates created"
  value = {
    for k, v in google_compute_instance_template.default : k => {
      id        = v.id
      self_link = v.self_link
    }
  }
}

output "instance_groups" {
  description = "Instance groups created"
  value = {
    for type in keys(var.instance_group_configs) : type => [
      for region in keys(var.zones) : google_compute_region_instance_group_manager.default["${type}-${region}"].instance_group
    ]
  }
}

output "instance_group_managers" {
  description = "Instance group managers created"
  value = {
    for k, v in google_compute_region_instance_group_manager.default : k => {
      id          = v.id
      self_link   = v.self_link
      region      = v.region
      target_size = v.target_size
    }
  }
}

output "autoscalers" {
  description = "Autoscalers created"
  value = {
    for k, v in google_compute_region_autoscaler.default : k => {
      id        = v.id
      target    = v.target
      region    = v.region
    }
  }
}

output "health_checks" {
  description = "Health checks created for instance groups"
  value = {
    for k, v in google_compute_health_check.instance_group : k => {
      id        = v.id
      self_link = v.self_link
    }
  }
}