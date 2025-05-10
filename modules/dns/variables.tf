variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "dns_zone_name" {
  description = "Cloud DNS zone name"
  type        = string
}

variable "domain_name" {
  description = "Domain name for DNS zone"
  type        = string
}

variable "lb_ip_address" {
  description = "Load balancer IP address"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "labels" {
  description = "Labels to apply to resources"
  type        = map(string)
  default     = {}
}

variable "mx_records" {
  description = "MX records for the domain"
  type        = list(string)
  default = [
    "10 mail.example.com."
  ]
}

variable "txt_records" {
  description = "TXT records for the domain"
  type        = map(string)
  default = {
    "@" = "v=spf1 include:_spf.google.com ~all"
  }
}