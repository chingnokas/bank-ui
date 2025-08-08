# Banking App DigitalOcean Kubernetes Cluster
# Clean OpenTofu configuration to create a Kubernetes cluster

terraform {
  required_version = ">= 1.6.0"
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

variable "k8s_version" {
  description = "Kubernetes version slug supported by DigitalOcean (e.g., 1.30.2-do.0)"
  type        = string
  default     = "1.30.2-do.0"
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create the Kubernetes cluster
resource "digitalocean_kubernetes_cluster" "banking_cluster" {
  name    = var.cluster_name
  region  = var.region
  version = var.k8s_version

  # Node pool configuration
  node_pool {
    name       = "${var.cluster_name}-worker-pool"
    size       = var.node_size
    node_count = var.node_count

    # Auto-scaling configuration
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 5

    # Node labels
    labels = {
      environment = "production"
      app         = "banking-app"
      managed-by  = "opentofu"
    }
  }

  # Maintenance window
  maintenance_policy {
    start_time = "04:00"
    day        = "sunday"
  }

  # Cluster features
  auto_upgrade   = true
  surge_upgrade  = true
  ha             = false  # Set to true for high availability (costs more)
}

# Outputs
output "cluster_id" {
  description = "ID of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.banking_cluster.id
}

output "cluster_name" {
  description = "Name of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.banking_cluster.name
}

output "cluster_endpoint" {
  description = "Endpoint of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.banking_cluster.endpoint
  sensitive   = true
}

output "cluster_status" {
  description = "Status of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.banking_cluster.status
}

output "cluster_region" {
  description = "Region of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.banking_cluster.region
}

output "cluster_version" {
  description = "Version of the Kubernetes cluster"
  value       = digitalocean_kubernetes_cluster.banking_cluster.version
}

output "kubeconfig" {
  description = "Kubeconfig for the cluster"
  value       = digitalocean_kubernetes_cluster.banking_cluster.kube_config[0].raw_config
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
