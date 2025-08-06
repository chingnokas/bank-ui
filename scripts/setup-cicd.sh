#!/bin/bash

# Banking App CI/CD Setup Script
# This script helps set up the CI/CD pipeline for the banking application

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CLUSTER_NAME="banking-app-k8s"
REGION="nyc1"
NAMESPACE="banking-app"
MONITORING_NAMESPACE="monitoring"

echo -e "${BLUE}🏦 Banking Application CI/CD Setup${NC}"
echo "=================================="

# Check prerequisites
check_prerequisites() {
    echo -e "${YELLOW}📋 Checking prerequisites...${NC}"
    
    # Check if required tools are installed
    local tools=("kubectl" "doctl" "gh" "tofu")
    for tool in "${tools[@]}"; do
        if ! command -v $tool &> /dev/null; then
            echo -e "${RED}❌ $tool is not installed${NC}"
            exit 1
        else
            echo -e "${GREEN}✅ $tool is installed${NC}"
        fi
    done
    
    # Check if GitHub CLI is authenticated
    if ! gh auth status &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI is not authenticated${NC}"
        echo "Please run: gh auth login"
        exit 1
    else
        echo -e "${GREEN}✅ GitHub CLI is authenticated${NC}"
    fi
    
    # Check if DigitalOcean CLI is authenticated
    if ! doctl account get &> /dev/null; then
        echo -e "${RED}❌ DigitalOcean CLI is not authenticated${NC}"
        echo "Please run: doctl auth init"
        exit 1
    else
        echo -e "${GREEN}✅ DigitalOcean CLI is authenticated${NC}"
    fi
}

# Setup GitHub secrets
setup_github_secrets() {
    echo -e "${YELLOW}🔐 Setting up GitHub secrets...${NC}"
    
    # Get DigitalOcean token
    DO_TOKEN=$(doctl auth list --format Token --no-header | head -1)
    if [ -z "$DO_TOKEN" ]; then
        echo -e "${RED}❌ Could not retrieve DigitalOcean token${NC}"
        exit 1
    fi
    
    # Set GitHub secrets
    echo "$DO_TOKEN" | gh secret set DIGITALOCEAN_TOKEN
    echo -e "${GREEN}✅ Set DIGITALOCEAN_TOKEN secret${NC}"
    
    echo -e "${YELLOW}ℹ️  KUBE_CONFIG_DATA will be set after cluster creation${NC}"
}

# Initialize infrastructure
setup_infrastructure() {
    echo -e "${YELLOW}🏗️  Setting up infrastructure...${NC}"
    
    cd infra
    
    # Initialize OpenTofu
    echo -e "${BLUE}Initializing OpenTofu...${NC}"
    tofu init
    
    # Create workspace
    tofu workspace select production || tofu workspace new production
    
    # Plan infrastructure
    echo -e "${BLUE}Planning infrastructure...${NC}"
    tofu plan -var="do_token=$DO_TOKEN" \
              -var="cluster_name=$CLUSTER_NAME" \
              -var="region=$REGION" \
              -out=tfplan
    
    # Ask for confirmation
    echo -e "${YELLOW}Do you want to apply the infrastructure plan? (y/N)${NC}"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        echo -e "${BLUE}Applying infrastructure...${NC}"
        tofu apply -auto-approve tfplan
        echo -e "${GREEN}✅ Infrastructure created successfully${NC}"
    else
        echo -e "${YELLOW}⚠️  Infrastructure creation skipped${NC}"
        cd ..
        return
    fi
    
    cd ..
}

# Setup Kubernetes configuration
setup_kubernetes() {
    echo -e "${YELLOW}☸️  Setting up Kubernetes configuration...${NC}"
    
    # Get cluster credentials
    echo -e "${BLUE}Getting cluster credentials...${NC}"
    doctl kubernetes cluster kubeconfig save $CLUSTER_NAME
    
    # Wait for cluster to be ready
    echo -e "${BLUE}Waiting for cluster to be ready...${NC}"
    kubectl wait --for=condition=Ready nodes --all --timeout=300s
    
    # Create namespaces
    echo -e "${BLUE}Creating namespaces...${NC}"
    kubectl apply -f k8s/namespace.yaml
    
    # Apply secrets
    echo -e "${BLUE}Applying secrets...${NC}"
    kubectl apply -f k8s/secrets/
    
    # Set kubeconfig as GitHub secret
    KUBE_CONFIG_DATA=$(kubectl config view --raw --minify --flatten | base64 -w 0)
    echo "$KUBE_CONFIG_DATA" | gh secret set KUBE_CONFIG_DATA
    echo -e "${GREEN}✅ Set KUBE_CONFIG_DATA secret${NC}"
}

# Deploy monitoring stack
deploy_monitoring() {
    echo -e "${YELLOW}📊 Deploying monitoring stack...${NC}"
    
    # Deploy Prometheus
    echo -e "${BLUE}Deploying Prometheus...${NC}"
    kubectl apply -f k8s/monitoring/prometheus/
    
    # Wait for Prometheus to be ready
    kubectl rollout status deployment/prometheus-server -n $MONITORING_NAMESPACE --timeout=300s
    
    # Deploy Grafana
    echo -e "${BLUE}Deploying Grafana...${NC}"
    kubectl apply -f k8s/monitoring/grafana/
    
    # Wait for Grafana to be ready
    kubectl rollout status deployment/grafana -n $MONITORING_NAMESPACE --timeout=300s
    
    echo -e "${GREEN}✅ Monitoring stack deployed${NC}"
}

# Deploy Argo CD
deploy_argocd() {
    echo -e "${YELLOW}🔄 Deploying Argo CD...${NC}"
    
    # Create Argo CD namespace
    kubectl create namespace argocd --dry-run=client -o yaml | kubectl apply -f -
    
    # Install Argo CD
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    
    # Wait for Argo CD to be ready
    kubectl rollout status deployment/argocd-server -n argocd --timeout=300s
    
    # Apply Argo CD configuration
    kubectl apply -f k8s/argocd/
    
    echo -e "${GREEN}✅ Argo CD deployed${NC}"
}

# Get service URLs
get_service_urls() {
    echo -e "${YELLOW}🌐 Getting service URLs...${NC}"
    
    echo -e "${BLUE}Waiting for load balancers to be ready...${NC}"
    sleep 30
    
    # Get frontend URL
    FRONTEND_IP=$(kubectl get svc banking-frontend -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
    
    # Get Grafana URL
    GRAFANA_IP=$(kubectl get svc grafana -n $MONITORING_NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
    
    # Get Prometheus URL
    PROMETHEUS_IP=$(kubectl get svc prometheus-server -n $MONITORING_NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
    
    # Get Argo CD URL (port-forward required)
    echo -e "${GREEN}🎉 Deployment Complete!${NC}"
    echo "========================"
    echo -e "${BLUE}Service URLs:${NC}"
    echo "Frontend:    http://$FRONTEND_IP/"
    echo "Grafana:     http://$GRAFANA_IP:3000/ (admin/BankingGrafana2024!)"
    echo "Prometheus:  http://$PROMETHEUS_IP:9090/"
    echo ""
    echo -e "${YELLOW}Argo CD:${NC}"
    echo "Run: kubectl port-forward svc/argocd-server -n argocd 8080:443"
    echo "Then visit: https://localhost:8080/"
    echo "Username: admin"
    echo "Password: \$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath=\"{.data.password}\" | base64 -d)"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Update repository URLs in k8s/argocd/applications.yaml"
    echo "2. Push changes to trigger CI/CD pipeline"
    echo "3. Monitor deployments in Argo CD dashboard"
}

# Main execution
main() {
    echo -e "${BLUE}Starting setup process...${NC}"
    
    check_prerequisites
    setup_github_secrets
    setup_infrastructure
    setup_kubernetes
    deploy_monitoring
    deploy_argocd
    get_service_urls
    
    echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
}

# Handle script arguments
case "${1:-}" in
    "check")
        check_prerequisites
        ;;
    "secrets")
        setup_github_secrets
        ;;
    "infra")
        setup_infrastructure
        ;;
    "k8s")
        setup_kubernetes
        ;;
    "monitoring")
        deploy_monitoring
        ;;
    "argocd")
        deploy_argocd
        ;;
    "urls")
        get_service_urls
        ;;
    "")
        main
        ;;
    *)
        echo "Usage: $0 [check|secrets|infra|k8s|monitoring|argocd|urls]"
        echo ""
        echo "Commands:"
        echo "  check      - Check prerequisites"
        echo "  secrets    - Setup GitHub secrets"
        echo "  infra      - Setup infrastructure"
        echo "  k8s        - Setup Kubernetes"
        echo "  monitoring - Deploy monitoring"
        echo "  argocd     - Deploy Argo CD"
        echo "  urls       - Get service URLs"
        echo "  (no args)  - Run full setup"
        exit 1
        ;;
esac
