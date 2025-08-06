#!/bin/bash

# Peoples Bank - Deployment Script using nerdctl compose
# This script deploys the banking application with proper security configurations

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT="${1:-development}"
COMPOSE_FILE="docker-compose.yml"

echo -e "${BLUE}🏦 Peoples Bank - Deployment Script${NC}"
echo -e "${BLUE}===================================${NC}"

# Function to print status
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if nerdctl is installed
if ! command -v nerdctl &> /dev/null; then
    print_error "nerdctl is not installed. Please install nerdctl first."
    exit 1
fi

# Check environment and set compose files
case $ENVIRONMENT in
    "production")
        COMPOSE_FILES="-f ${COMPOSE_FILE} -f docker-compose.prod.yml"
        print_status "Deploying to PRODUCTION environment"
        print_warning "Make sure you have reviewed all security configurations!"
        ;;
    "development")
        COMPOSE_FILES="-f ${COMPOSE_FILE} -f docker-compose.override.yml"
        print_status "Deploying to DEVELOPMENT environment"
        ;;
    *)
        print_error "Invalid environment: $ENVIRONMENT"
        print_error "Valid environments: development, production"
        exit 1
        ;;
esac

# Pre-deployment checks
print_status "Running pre-deployment checks..."

# Check if required files exist
required_files=(".env" "secrets/db_password.txt" "secrets/jwt_secret.txt" "secrets/redis_password.txt")
for file in "${required_files[@]}"; do
    if [ ! -f "$file" ]; then
        print_error "Required file missing: $file"
        exit 1
    fi
done

# Check if secrets are not default values (security check)
if grep -q "your-super-secret-key-change-in-production" backend/.env; then
    print_error "Default secret key detected in backend/.env. Please change it!"
    exit 1
fi

print_status "✅ Pre-deployment checks passed"

# Stop existing containers
print_status "Stopping existing containers..."
nerdctl compose ${COMPOSE_FILES} down --remove-orphans || true

# Pull latest images (if using registry)
if [ "$ENVIRONMENT" = "production" ]; then
    print_status "Pulling latest images..."
    nerdctl compose ${COMPOSE_FILES} pull
fi

# Start services
print_status "Starting services..."
nerdctl compose ${COMPOSE_FILES} up -d

# Wait for services to be healthy
print_status "Waiting for services to be healthy..."
sleep 10

# Check service health
print_status "Checking service health..."
services=("postgres" "backend" "frontend" "redis")
for service in "${services[@]}"; do
    if nerdctl compose ${COMPOSE_FILES} ps | grep -q "${service}.*healthy"; then
        print_status "✅ $service is healthy"
    else
        print_warning "⚠️  $service health check pending or failed"
    fi
done

# Display running services
print_status "Running services:"
nerdctl compose ${COMPOSE_FILES} ps

# Display logs for troubleshooting
print_status "Recent logs (last 20 lines):"
nerdctl compose ${COMPOSE_FILES} logs --tail=20

# Display access information
print_status "🎉 Deployment completed!"
echo -e "${GREEN}Access Information:${NC}"
if [ "$ENVIRONMENT" = "development" ]; then
    echo -e "  Frontend: ${BLUE}http://localhost:3000${NC}"
    echo -e "  Backend API: ${BLUE}http://localhost:8000${NC}"
    echo -e "  API Docs: ${BLUE}http://localhost:8000/docs${NC}"
else
    echo -e "  Frontend: ${BLUE}http://localhost${NC}"
    echo -e "  Backend API: ${BLUE}http://localhost/api${NC}"
fi

echo -e "${GREEN}Deployment process completed!${NC}"

# Optional: Run basic smoke tests
if [ "$2" = "--test" ]; then
    print_status "Running smoke tests..."
    sleep 5
    
    # Test frontend
    if curl -f http://localhost:3000/ > /dev/null 2>&1; then
        print_status "✅ Frontend smoke test passed"
    else
        print_error "❌ Frontend smoke test failed"
    fi
    
    # Test backend API
    if curl -f http://localhost:8000/api/ > /dev/null 2>&1; then
        print_status "✅ Backend API smoke test passed"
    else
        print_error "❌ Backend API smoke test failed"
    fi
fi
