# Simplified OpenTofu configuration for DigitalOcean Kubernetes
# This version focuses on core functionality and avoids complex configurations

terraform {
  required_version = ">= 1.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.34"
    }
  }
}

# Variables
variable "do_token" {
  description = "DigitalOcean API Token"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Name of the Kubernetes cluster"
  type        = string
  default     = "banking-app-k8s"
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "node_count" {
  description = "Number of worker nodes"
  type        = number
  default     = 2
}

variable "node_size" {
  description = "Size of worker nodes"
  type        = string
  default     = "s-2vcpu-4gb"
}

# Configure provider
provider "digitalocean" {
  token = var.do_token
}

# Get available Kubernetes versions
data "digitalocean_kubernetes_versions" "available" {
  version_prefix = "1.28."
}

# Kubernetes cluster
resource "digitalocean_kubernetes_cluster" "banking_cluster" {
  name    = var.cluster_name
  region  = var.region
  version = data.digitalocean_kubernetes_versions.available.latest_version

  # Simple node pool
  node_pool {
    name       = "${var.cluster_name}-worker-pool"
    size       = var.node_size
    node_count = var.node_count
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 5

    labels = {
      environment = "production"
      app         = "banking-app"
    }
  }

  # Enable maintenance window
  maintenance_policy {
    start_time = "04:00"
    day        = "sunday"
  }

  # Enable auto-upgrade
  auto_upgrade = true
  surge_upgrade = true
}

# Outputs
output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.banking_cluster.id
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.banking_cluster.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "CA certificate of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.banking_cluster.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_token" {
  description = "Token for the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.banking_cluster.kube_config[0].token
  sensitive   = true
}

output "kubeconfig" {
  description = "Kubeconfig for the cluster"
  value       = digitalocean_kubernetes_cluster.banking_cluster.kube_config[0].raw_config
  sensitive   = true
}
