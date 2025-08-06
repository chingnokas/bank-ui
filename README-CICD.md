# Banking Application CI/CD Pipeline

This repository contains a comprehensive CI/CD pipeline for deploying a secure banking application on DigitalOcean Kubernetes using OpenTofu, Argo CD, and monitoring with Prometheus/Grafana.

## 🏗️ Architecture Overview

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   GitHub        │    │  DigitalOcean   │    │   Kubernetes    │
│   Repository    │───▶│   Infrastructure │───▶│    Cluster      │
│                 │    │   (OpenTofu)    │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                                              │
         ▼                                              ▼
┌─────────────────┐                            ┌─────────────────┐
│  GitHub Actions │                            │    Argo CD      │
│   CI/CD Pipeline│                            │   GitOps        │
└─────────────────┘                            └─────────────────┘
         │                                              │
         ▼                                              ▼
┌─────────────────┐                            ┌─────────────────┐
│  Container      │                            │   Application   │
│  Registry       │                            │   Deployment    │
│  (GHCR)         │                            │                 │
└─────────────────┘                            └─────────────────┘
```

## 🚀 Features

### Infrastructure as Code
- **OpenTofu**: Provisions DigitalOcean Kubernetes cluster, VPC, database, and load balancers
- **Automated provisioning**: Only runs when infrastructure files change
- **State management**: Remote state storage in DigitalOcean Spaces

### CI/CD Pipeline
- **Smart change detection**: Only builds/deploys when app code changes
- **Multi-stage Docker builds**: Optimized for security and performance
- **Container registry**: Pushes to GitHub Container Registry (GHCR)
- **Health checks**: Comprehensive validation after deployment

### GitOps with Argo CD
- **Selective sync**: Only syncs when frontend/backend code changes
- **Ignores infrastructure**: Infrastructure changes don't trigger app deployments
- **Automated rollbacks**: Self-healing deployments
- **RBAC**: Role-based access control for different teams

### Security
- **Chainguard images**: Distroless, security-hardened base images
- **Non-root containers**: All services run as unprivileged users
- **Network policies**: Isolated network communication
- **Secrets management**: Kubernetes secrets for sensitive data

### Monitoring & Observability
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Visualization dashboards
- **Custom alerts**: Banking-specific monitoring rules
- **Health checks**: Application and infrastructure monitoring

## 📁 Project Structure

```
.
├── .github/workflows/
│   └── ci.yml                    # Main CI/CD pipeline
├── infra/
│   ├── main.tf                   # OpenTofu infrastructure
│   └── versions.tf               # Provider versions
├── k8s/
│   ├── namespace.yaml            # Kubernetes namespaces
│   ├── backend/
│   │   └── deployment.yaml       # Backend deployment
│   ├── frontend/
│   │   └── deployment.yaml       # Frontend deployment
│   ├── database/
│   │   └── postgres.yaml         # PostgreSQL StatefulSet
│   ├── monitoring/
│   │   ├── prometheus/           # Prometheus configuration
│   │   ├── grafana/              # Grafana configuration
│   │   └── dashboards/           # Custom dashboards
│   ├── argocd/
│   │   ├── applications.yaml     # Argo CD applications
│   │   └── repository.yaml       # Repository configuration
│   └── secrets/
│       └── banking-secrets.yaml  # Application secrets
├── frontend/
│   ├── Dockerfile               # Frontend container
│   └── nginx.conf               # Nginx configuration
├── backend/
│   ├── Dockerfile               # Backend container
│   └── requirements.txt         # Python dependencies
└── scripts/
    └── build.sh                 # Local build script
```

## 🔧 Setup Instructions

### Prerequisites

1. **DigitalOcean Account**: With API token
2. **GitHub Repository**: With Actions enabled
3. **Domain** (optional): For custom URLs

### 1. Configure GitHub Secrets

Add these secrets to your GitHub repository:

```bash
DIGITALOCEAN_TOKEN=your_do_token_here
KUBE_CONFIG_DATA=base64_encoded_kubeconfig
GITHUB_TOKEN=automatically_provided
```

### 2. Update Configuration

1. **Repository URLs**: Update in `k8s/argocd/applications.yaml`
2. **Image names**: Update in `.github/workflows/ci.yml`
3. **Domain names**: Update in Kubernetes manifests

### 3. Initialize Infrastructure

```bash
# Clone repository
git clone https://github.com/your-org/bank-ui.git
cd bank-ui

# Initialize OpenTofu
cd infra
tofu init
tofu plan
tofu apply
```

### 4. Deploy Application

Push changes to trigger the CI/CD pipeline:

```bash
git add .
git commit -m "Initial deployment"
git push origin main
```

## 🔄 CI/CD Workflow

### Pipeline Stages

1. **Change Detection**
   - Detects changes in infrastructure, frontend, backend, or monitoring
   - Only runs relevant stages based on changes

2. **Infrastructure Provisioning** (if infra changes)
   - Provisions DigitalOcean resources with OpenTofu
   - Waits for cluster to be ready

3. **Image Building** (if app changes)
   - Builds Docker images with multi-stage builds
   - Pushes to GitHub Container Registry
   - Supports multi-architecture builds

4. **Monitoring Deployment** (if monitoring changes)
   - Deploys Prometheus and Grafana
   - Configures dashboards and alerts

5. **Argo CD Deployment**
   - Installs/configures Argo CD
   - Syncs applications only when app code changes
   - Ignores infrastructure changes

6. **Health Checks**
   - Validates all services are running
   - Performs connectivity tests
   - Reports deployment status

### Change Detection Logic

```yaml
# Only builds frontend when these paths change:
frontend:
  - 'frontend/**'
  - 'Dockerfile.frontend'

# Only builds backend when these paths change:
backend:
  - 'backend/**'
  - 'Dockerfile.backend'

# Infrastructure changes trigger provisioning:
infrastructure:
  - 'infra/**'
  - 'terraform/**'

# Monitoring changes trigger monitoring deployment:
monitoring:
  - 'k8s/monitoring/**'
```

## 🎯 Argo CD Configuration

### Selective Sync Strategy

Argo CD is configured to:
- **Ignore infrastructure changes**: Changes to `infra/` don't trigger syncs
- **Sync on app changes**: Only frontend/backend changes trigger deployment
- **Auto-heal**: Automatically fixes configuration drift
- **Prune resources**: Removes deleted resources

### Application Structure

```yaml
# Frontend Application
- name: banking-app-frontend
  source: k8s/frontend
  syncPolicy: automated

# Backend Application  
- name: banking-app-backend
  source: k8s/backend
  syncPolicy: automated

# Database Application
- name: banking-app-database
  source: k8s/database
  syncPolicy: manual  # Requires manual approval
```

## 📊 Monitoring Setup

### Prometheus Metrics

- **Application metrics**: Request rate, response time, errors
- **Infrastructure metrics**: CPU, memory, disk usage
- **Database metrics**: Connections, query performance
- **Business metrics**: Transaction volume, user activity

### Grafana Dashboards

- **Application Overview**: Health, performance, errors
- **Infrastructure**: Kubernetes cluster metrics
- **Database**: PostgreSQL performance
- **Security**: Failed logins, suspicious activity

### Alerting Rules

- **Critical**: Service down, high error rate
- **Warning**: High resource usage, performance degradation
- **Info**: Business metrics, transaction volume

## 🔒 Security Features

### Container Security
- **Chainguard images**: Minimal, security-hardened
- **Non-root execution**: All containers run as unprivileged users
- **Read-only filesystems**: Prevents runtime modifications
- **Security contexts**: Drops all capabilities

### Network Security
- **Network policies**: Restricts pod-to-pod communication
- **Service mesh ready**: Compatible with Istio/Linkerd
- **TLS encryption**: End-to-end encryption support

### Secrets Management
- **Kubernetes secrets**: Encrypted at rest
- **RBAC**: Role-based access control
- **Service accounts**: Minimal permissions

## 🚀 Deployment

### Automatic Deployment

The pipeline automatically deploys when:
- Frontend code changes in `frontend/`
- Backend code changes in `backend/`
- Kubernetes manifests change in `k8s/`

### Manual Deployment

```bash
# Trigger manual deployment
gh workflow run ci.yml

# Deploy specific component
kubectl apply -f k8s/frontend/
kubectl apply -f k8s/backend/
```

### Rollback

```bash
# Argo CD rollback
argocd app rollback banking-app-frontend

# Kubernetes rollback
kubectl rollout undo deployment/banking-frontend -n banking-app
```

## 📈 Scaling

### Horizontal Pod Autoscaler

```yaml
# Automatically scales based on:
- CPU usage > 70%
- Memory usage > 80%
- Custom metrics (requests/second)
```

### Cluster Autoscaler

```yaml
# Node pool auto-scaling:
min_nodes: 2
max_nodes: 10
```

## 🔍 Troubleshooting

### Common Issues

1. **Pipeline fails on infrastructure**
   - Check DigitalOcean token permissions
   - Verify OpenTofu state access

2. **Argo CD not syncing**
   - Check repository credentials
   - Verify webhook configuration

3. **Pods not starting**
   - Check resource limits
   - Verify secrets and configmaps

### Debugging Commands

```bash
# Check pipeline status
gh run list

# Check Argo CD applications
argocd app list

# Check pod status
kubectl get pods -n banking-app

# Check logs
kubectl logs -f deployment/banking-backend -n banking-app
```

## 📞 Support

For issues and questions:
- Create GitHub issues for bugs
- Check documentation in `/docs`
- Review monitoring dashboards for operational issues

## 🤝 Contributing

1. Fork the repository
2. Create feature branch
3. Make changes
4. Test locally
5. Submit pull request

The CI/CD pipeline will automatically test and deploy approved changes.
