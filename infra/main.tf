terraform {
  required_version = ">= 1.0"
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
  }

  # Configure remote state storage (optional - can use local state for testing)
  # Uncomment and configure for production use:
  # backend "s3" {
  #   endpoint                    = "nyc3.digitaloceanspaces.com"
  #   key                        = "banking-app/terraform.tfstate"
  #   bucket                     = "banking-app-terraform-state"
  #   region                     = "us-east-1"
  #   skip_credentials_validation = true
  #   skip_metadata_api_check     = true
  # }
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
  default     = 3
}

variable "node_size" {
  description = "Size of worker nodes"
  type        = string
  default     = "s-2vcpu-4gb"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28.2-do.0"
}

# Configure providers
provider "digitalocean" {
  token = var.do_token
}

# Data sources
data "digitalocean_kubernetes_versions" "available" {
  version_prefix = "1.28."
}

# VPC for the cluster
resource "digitalocean_vpc" "banking_vpc" {
  name     = "${var.cluster_name}-vpc"
  region   = var.region
  ip_range = "10.10.0.0/16"

  # Tags are not supported for VPC in DigitalOcean provider
}

# Kubernetes cluster
resource "digitalocean_kubernetes_cluster" "banking_cluster" {
  name     = var.cluster_name
  region   = var.region
  version  = var.kubernetes_version
  vpc_uuid = digitalocean_vpc.banking_vpc.id

  # Enable maintenance window
  maintenance_policy {
    start_time = "04:00"
    day        = "sunday"
  }

  # Enable auto-upgrade
  auto_upgrade = true

  # Enable surge upgrades for faster updates
  surge_upgrade = true

  # Destroy associated load balancers on cluster deletion
  destroy_all_associated_resources = true

  node_pool {
    name       = "${var.cluster_name}-worker-pool"
    size       = var.node_size
    node_count = var.node_count
    auto_scale = true
    min_nodes  = 2
    max_nodes  = 10

    # Auto-upgrade is enabled at cluster level

    tags = [
      "banking-app",
      "worker-nodes",
      "production"
    ]

    labels = {
      environment = "production"
      app         = "banking-app"
    }

    # Taint nodes for specific workloads if needed
    # taint {
    #   key    = "workload-type"
    #   value  = "banking-app"
    #   effect = "NoSchedule"
    # }
  }

  tags = [
    "banking-app",
    "kubernetes",
    "production"
  ]
}

# Database cluster for PostgreSQL
resource "digitalocean_database_cluster" "banking_postgres" {
  name       = "${var.cluster_name}-postgres"
  engine     = "pg"
  version    = "15"
  size       = "db-s-1vcpu-1gb"
  region     = var.region
  node_count = 1

  # Enable private networking
  private_network_uuid = digitalocean_vpc.banking_vpc.id

  # Maintenance window
  maintenance_window {
    day  = "sunday"
    hour = "04:00:00"
  }

  tags = [
    "banking-app",
    "database",
    "production"
  ]
}

# Database for the banking application
resource "digitalocean_database_db" "banking_db" {
  cluster_id = digitalocean_database_cluster.banking_postgres.id
  name       = "bankdb"
}

# Database user
resource "digitalocean_database_user" "banking_user" {
  cluster_id = digitalocean_database_cluster.banking_postgres.id
  name       = "bankuser"
}

# Load balancer for ingress
resource "digitalocean_loadbalancer" "banking_lb" {
  name   = "${var.cluster_name}-lb"
  region = var.region
  vpc_uuid = digitalocean_vpc.banking_vpc.id

  forwarding_rule {
    entry_protocol  = "http"
    entry_port      = 80
    target_protocol = "http"
    target_port     = 80
  }

  forwarding_rule {
    entry_protocol  = "https"
    entry_port      = 443
    target_protocol = "http"
    target_port     = 80
    tls_passthrough = false
  }

  healthcheck {
    protocol               = "http"
    port                   = 80
    path                   = "/health"
    check_interval_seconds = 10
    response_timeout_seconds = 5
    unhealthy_threshold    = 3
    healthy_threshold      = 2
  }

  # Tags are not supported for load balancer in DigitalOcean provider
}

# Spaces bucket for backups and static assets
resource "digitalocean_spaces_bucket" "banking_assets" {
  name   = "${var.cluster_name}-assets"
  region = var.region
  acl    = "private"

  versioning {
    enabled = true
  }

  lifecycle_rule {
    id      = "delete_old_versions"
    enabled = true

    noncurrent_version_expiration {
      days = 30
    }
  }
}

# Container registry
resource "digitalocean_container_registry" "banking_registry" {
  name                   = replace(var.cluster_name, "-", "")
  subscription_tier_slug = "basic"
  region                 = var.region
}

# Firewall rules
resource "digitalocean_firewall" "banking_firewall" {
  name = "${var.cluster_name}-firewall"

  tags = [digitalocean_kubernetes_cluster.banking_cluster.id]

  # Allow HTTP/HTTPS from anywhere
  inbound_rule {
    protocol         = "tcp"
    port_range       = "80"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  inbound_rule {
    protocol         = "tcp"
    port_range       = "443"
    source_addresses = ["0.0.0.0/0", "::/0"]
  }

  # Allow SSH from specific IPs (add your IPs here)
  inbound_rule {
    protocol         = "tcp"
    port_range       = "22"
    source_addresses = ["0.0.0.0/0"]  # Restrict this in production
  }

  # Allow all outbound traffic
  outbound_rule {
    protocol              = "tcp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "udp"
    port_range            = "1-65535"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0", "::/0"]
  }
}

# Configure Kubernetes provider
provider "kubernetes" {
  host  = digitalocean_kubernetes_cluster.banking_cluster.endpoint
  token = digitalocean_kubernetes_cluster.banking_cluster.kube_config[0].token
  cluster_ca_certificate = base64decode(
    digitalocean_kubernetes_cluster.banking_cluster.kube_config[0].cluster_ca_certificate
  )
}

# Helm provider configuration
# provider "helm" {
#   kubernetes {
#     host  = digitalocean_kubernetes_cluster.banking_cluster.endpoint
#     token = digitalocean_kubernetes_cluster.banking_cluster.kube_config[0].token
#     cluster_ca_certificate = base64decode(
#       digitalocean_kubernetes_cluster.banking_cluster.kube_config[0].cluster_ca_certificate
#     )
#   }
# }

# Create namespaces
resource "kubernetes_namespace" "banking_app" {
  metadata {
    name = "banking-app"
    labels = {
      name        = "banking-app"
      environment = "production"
    }
  }
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
    labels = {
      name        = "monitoring"
      environment = "production"
    }
  }
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      name        = "argocd"
      environment = "production"
    }
  }
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

output "database_host" {
  description = "Database host"
  value       = digitalocean_database_cluster.banking_postgres.host
  sensitive   = true
}

output "database_port" {
  description = "Database port"
  value       = digitalocean_database_cluster.banking_postgres.port
}

output "database_user" {
  description = "Database user"
  value       = digitalocean_database_user.banking_user.name
}

output "database_password" {
  description = "Database password"
  value       = digitalocean_database_user.banking_user.password
  sensitive   = true
}

output "load_balancer_ip" {
  description = "Load balancer IP"
  value       = digitalocean_loadbalancer.banking_lb.ip
}

output "container_registry_endpoint" {
  description = "Container registry endpoint"
  value       = digitalocean_container_registry.banking_registry.endpoint
}

output "spaces_bucket_name" {
  description = "Spaces bucket name"
  value       = digitalocean_spaces_bucket.banking_assets.name
}
