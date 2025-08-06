#!/bin/bash

# Banking App Deployment Validation Script
# This script validates that the CI/CD pipeline and deployment are working correctly

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
NAMESPACE="banking-app"
MONITORING_NAMESPACE="monitoring"
ARGOCD_NAMESPACE="argocd"

echo -e "${BLUE}🔍 Banking Application Deployment Validation${NC}"
echo "=============================================="

# Check cluster connectivity
check_cluster() {
    echo -e "${YELLOW}☸️  Checking cluster connectivity...${NC}"
    
    if kubectl cluster-info &> /dev/null; then
        echo -e "${GREEN}✅ Cluster is accessible${NC}"
        kubectl get nodes
    else
        echo -e "${RED}❌ Cannot connect to cluster${NC}"
        exit 1
    fi
}

# Check namespaces
check_namespaces() {
    echo -e "${YELLOW}📁 Checking namespaces...${NC}"
    
    local namespaces=("$NAMESPACE" "$MONITORING_NAMESPACE" "$ARGOCD_NAMESPACE")
    for ns in "${namespaces[@]}"; do
        if kubectl get namespace $ns &> /dev/null; then
            echo -e "${GREEN}✅ Namespace $ns exists${NC}"
        else
            echo -e "${RED}❌ Namespace $ns does not exist${NC}"
        fi
    done
}

# Check application deployments
check_applications() {
    echo -e "${YELLOW}🏦 Checking application deployments...${NC}"
    
    # Check backend
    if kubectl get deployment banking-backend -n $NAMESPACE &> /dev/null; then
        local backend_ready=$(kubectl get deployment banking-backend -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
        local backend_desired=$(kubectl get deployment banking-backend -n $NAMESPACE -o jsonpath='{.spec.replicas}')
        if [ "$backend_ready" = "$backend_desired" ]; then
            echo -e "${GREEN}✅ Backend deployment ready ($backend_ready/$backend_desired)${NC}"
        else
            echo -e "${YELLOW}⚠️  Backend deployment not ready ($backend_ready/$backend_desired)${NC}"
        fi
    else
        echo -e "${RED}❌ Backend deployment not found${NC}"
    fi
    
    # Check frontend
    if kubectl get deployment banking-frontend -n $NAMESPACE &> /dev/null; then
        local frontend_ready=$(kubectl get deployment banking-frontend -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
        local frontend_desired=$(kubectl get deployment banking-frontend -n $NAMESPACE -o jsonpath='{.spec.replicas}')
        if [ "$frontend_ready" = "$frontend_desired" ]; then
            echo -e "${GREEN}✅ Frontend deployment ready ($frontend_ready/$frontend_desired)${NC}"
        else
            echo -e "${YELLOW}⚠️  Frontend deployment not ready ($frontend_ready/$frontend_desired)${NC}"
        fi
    else
        echo -e "${RED}❌ Frontend deployment not found${NC}"
    fi
    
    # Check database
    if kubectl get statefulset postgres -n $NAMESPACE &> /dev/null; then
        local db_ready=$(kubectl get statefulset postgres -n $NAMESPACE -o jsonpath='{.status.readyReplicas}')
        local db_desired=$(kubectl get statefulset postgres -n $NAMESPACE -o jsonpath='{.spec.replicas}')
        if [ "$db_ready" = "$db_desired" ]; then
            echo -e "${GREEN}✅ Database ready ($db_ready/$db_desired)${NC}"
        else
            echo -e "${YELLOW}⚠️  Database not ready ($db_ready/$db_desired)${NC}"
        fi
    else
        echo -e "${RED}❌ Database StatefulSet not found${NC}"
    fi
}

# Check monitoring stack
check_monitoring() {
    echo -e "${YELLOW}📊 Checking monitoring stack...${NC}"
    
    # Check Prometheus
    if kubectl get deployment prometheus-server -n $MONITORING_NAMESPACE &> /dev/null; then
        local prom_ready=$(kubectl get deployment prometheus-server -n $MONITORING_NAMESPACE -o jsonpath='{.status.readyReplicas}')
        if [ "$prom_ready" = "1" ]; then
            echo -e "${GREEN}✅ Prometheus ready${NC}"
        else
            echo -e "${YELLOW}⚠️  Prometheus not ready${NC}"
        fi
    else
        echo -e "${RED}❌ Prometheus deployment not found${NC}"
    fi
    
    # Check Grafana
    if kubectl get deployment grafana -n $MONITORING_NAMESPACE &> /dev/null; then
        local grafana_ready=$(kubectl get deployment grafana -n $MONITORING_NAMESPACE -o jsonpath='{.status.readyReplicas}')
        if [ "$grafana_ready" = "1" ]; then
            echo -e "${GREEN}✅ Grafana ready${NC}"
        else
            echo -e "${YELLOW}⚠️  Grafana not ready${NC}"
        fi
    else
        echo -e "${RED}❌ Grafana deployment not found${NC}"
    fi
}

# Check Argo CD
check_argocd() {
    echo -e "${YELLOW}🔄 Checking Argo CD...${NC}"
    
    if kubectl get deployment argocd-server -n $ARGOCD_NAMESPACE &> /dev/null; then
        local argocd_ready=$(kubectl get deployment argocd-server -n $ARGOCD_NAMESPACE -o jsonpath='{.status.readyReplicas}')
        if [ "$argocd_ready" = "1" ]; then
            echo -e "${GREEN}✅ Argo CD server ready${NC}"
        else
            echo -e "${YELLOW}⚠️  Argo CD server not ready${NC}"
        fi
    else
        echo -e "${RED}❌ Argo CD server deployment not found${NC}"
    fi
    
    # Check Argo CD applications
    if command -v argocd &> /dev/null; then
        echo -e "${BLUE}Checking Argo CD applications...${NC}"
        # This would require Argo CD CLI setup and authentication
        # argocd app list
    fi
}

# Test application connectivity
test_connectivity() {
    echo -e "${YELLOW}🌐 Testing application connectivity...${NC}"
    
    # Get service IPs
    local backend_ip=$(kubectl get svc banking-backend -n $NAMESPACE -o jsonpath='{.spec.clusterIP}' 2>/dev/null || echo "")
    local frontend_ip=$(kubectl get svc banking-frontend -n $NAMESPACE -o jsonpath='{.spec.clusterIP}' 2>/dev/null || echo "")
    
    if [ -n "$backend_ip" ]; then
        echo -e "${BLUE}Testing backend API...${NC}"
        if kubectl run test-backend --rm -i --restart=Never --image=curlimages/curl -- curl -f http://$backend_ip:8000/api/ &> /dev/null; then
            echo -e "${GREEN}✅ Backend API responding${NC}"
        else
            echo -e "${RED}❌ Backend API not responding${NC}"
        fi
    fi
    
    if [ -n "$frontend_ip" ]; then
        echo -e "${BLUE}Testing frontend...${NC}"
        if kubectl run test-frontend --rm -i --restart=Never --image=curlimages/curl -- curl -f http://$frontend_ip/ &> /dev/null; then
            echo -e "${GREEN}✅ Frontend responding${NC}"
        else
            echo -e "${RED}❌ Frontend not responding${NC}"
        fi
    fi
}

# Get service URLs
get_service_urls() {
    echo -e "${YELLOW}🌐 Getting service URLs...${NC}"
    
    echo -e "${BLUE}External URLs:${NC}"
    
    # Frontend LoadBalancer
    local frontend_lb=$(kubectl get svc banking-frontend -n $NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
    echo "Frontend:    http://$frontend_lb/"
    
    # Grafana LoadBalancer
    local grafana_lb=$(kubectl get svc grafana -n $MONITORING_NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
    echo "Grafana:     http://$grafana_lb:3000/"
    
    # Prometheus LoadBalancer
    local prometheus_lb=$(kubectl get svc prometheus-server -n $MONITORING_NAMESPACE -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || echo "pending")
    echo "Prometheus:  http://$prometheus_lb:9090/"
    
    echo ""
    echo -e "${BLUE}Port-forward commands for local access:${NC}"
    echo "kubectl port-forward svc/banking-backend -n $NAMESPACE 8000:8000"
    echo "kubectl port-forward svc/banking-frontend -n $NAMESPACE 3000:80"
    echo "kubectl port-forward svc/grafana -n $MONITORING_NAMESPACE 3001:3000"
    echo "kubectl port-forward svc/prometheus-server -n $MONITORING_NAMESPACE 9090:9090"
    echo "kubectl port-forward svc/argocd-server -n $ARGOCD_NAMESPACE 8080:443"
}

# Check resource usage
check_resources() {
    echo -e "${YELLOW}📊 Checking resource usage...${NC}"
    
    echo -e "${BLUE}Node resource usage:${NC}"
    kubectl top nodes 2>/dev/null || echo "Metrics server not available"
    
    echo -e "${BLUE}Pod resource usage:${NC}"
    kubectl top pods -n $NAMESPACE 2>/dev/null || echo "Metrics server not available"
    kubectl top pods -n $MONITORING_NAMESPACE 2>/dev/null || echo "Metrics server not available"
}

# Generate deployment report
generate_report() {
    echo -e "${YELLOW}📋 Generating deployment report...${NC}"
    
    local report_file="deployment-report-$(date +%Y%m%d-%H%M%S).txt"
    
    {
        echo "Banking Application Deployment Report"
        echo "Generated: $(date)"
        echo "========================================"
        echo ""
        
        echo "CLUSTER INFORMATION:"
        kubectl cluster-info
        echo ""
        
        echo "NODES:"
        kubectl get nodes -o wide
        echo ""
        
        echo "NAMESPACES:"
        kubectl get namespaces
        echo ""
        
        echo "BANKING APP RESOURCES:"
        kubectl get all -n $NAMESPACE
        echo ""
        
        echo "MONITORING RESOURCES:"
        kubectl get all -n $MONITORING_NAMESPACE
        echo ""
        
        echo "ARGOCD RESOURCES:"
        kubectl get all -n $ARGOCD_NAMESPACE
        echo ""
        
        echo "PERSISTENT VOLUMES:"
        kubectl get pv,pvc --all-namespaces
        echo ""
        
        echo "INGRESS:"
        kubectl get ingress --all-namespaces
        echo ""
        
        echo "SECRETS:"
        kubectl get secrets --all-namespaces
        echo ""
        
    } > $report_file
    
    echo -e "${GREEN}✅ Report generated: $report_file${NC}"
}

# Main validation function
main() {
    echo -e "${BLUE}Starting validation process...${NC}"
    
    check_cluster
    echo ""
    
    check_namespaces
    echo ""
    
    check_applications
    echo ""
    
    check_monitoring
    echo ""
    
    check_argocd
    echo ""
    
    test_connectivity
    echo ""
    
    get_service_urls
    echo ""
    
    check_resources
    echo ""
    
    echo -e "${GREEN}🎉 Validation completed!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. Access the frontend application"
    echo "2. Check monitoring dashboards in Grafana"
    echo "3. Review Argo CD for deployment status"
    echo "4. Monitor alerts in Prometheus"
}

# Handle script arguments
case "${1:-}" in
    "cluster")
        check_cluster
        ;;
    "apps")
        check_applications
        ;;
    "monitoring")
        check_monitoring
        ;;
    "argocd")
        check_argocd
        ;;
    "connectivity")
        test_connectivity
        ;;
    "urls")
        get_service_urls
        ;;
    "resources")
        check_resources
        ;;
    "report")
        generate_report
        ;;
    "")
        main
        ;;
    *)
        echo "Usage: $0 [cluster|apps|monitoring|argocd|connectivity|urls|resources|report]"
        echo ""
        echo "Commands:"
        echo "  cluster      - Check cluster connectivity"
        echo "  apps         - Check application deployments"
        echo "  monitoring   - Check monitoring stack"
        echo "  argocd       - Check Argo CD"
        echo "  connectivity - Test application connectivity"
        echo "  urls         - Get service URLs"
        echo "  resources    - Check resource usage"
        echo "  report       - Generate deployment report"
        echo "  (no args)    - Run full validation"
        exit 1
        ;;
esac
