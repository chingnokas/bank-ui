#!/bin/bash

# Peoples Bank - Initial Setup Script
# This script sets up the development environment and generates secure secrets

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏦 Peoples Bank - Initial Setup${NC}"
echo -e "${BLUE}===============================${NC}"

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

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    print_error "Please do not run this script as root for security reasons"
    exit 1
fi

# Create necessary directories
print_status "Creating directory structure..."
mkdir -p secrets
mkdir -p build-logs
mkdir -p database/init
mkdir -p nginx/ssl

# Generate secure secrets
print_status "Generating secure secrets..."

# Generate database password
if [ ! -f "secrets/db_password.txt" ]; then
    openssl rand -base64 32 > secrets/db_password.txt
    print_status "✅ Database password generated"
else
    print_warning "Database password already exists, skipping..."
fi

# Generate JWT secret
if [ ! -f "secrets/jwt_secret.txt" ]; then
    openssl rand -hex 64 > secrets/jwt_secret.txt
    print_status "✅ JWT secret generated"
else
    print_warning "JWT secret already exists, skipping..."
fi

# Generate Redis password
if [ ! -f "secrets/redis_password.txt" ]; then
    openssl rand -base64 32 > secrets/redis_password.txt
    print_status "✅ Redis password generated"
else
    print_warning "Redis password already exists, skipping..."
fi

# Set proper permissions on secrets
chmod 600 secrets/*
print_status "✅ Secret file permissions set"

# Update environment files with generated secrets
print_status "Updating environment configuration..."

# Read generated passwords
DB_PASSWORD=$(cat secrets/db_password.txt)
REDIS_PASSWORD=$(cat secrets/redis_password.txt)
JWT_SECRET=$(cat secrets/jwt_secret.txt)

# Update .env file
cat > .env << EOF
# Docker Compose Environment Variables
DB_PASSWORD=${DB_PASSWORD}
REDIS_PASSWORD=${REDIS_PASSWORD}

# Application Configuration
COMPOSE_PROJECT_NAME=peoples-bank
COMPOSE_FILE=docker-compose.yml

# Network Configuration
FRONTEND_PORT=80
BACKEND_PORT=8000
POSTGRES_PORT=5432
REDIS_PORT=6379
EOF

# Update backend .env file
cat > backend/.env << EOF
# Database Configuration
DATABASE_URL=postgresql://bankuser:${DB_PASSWORD}@postgres:5432/bankdb

# Security Configuration
SECRET_KEY=${JWT_SECRET}
ACCESS_TOKEN_EXPIRE_MINUTES=30

# CORS Configuration
ALLOWED_ORIGINS=http://localhost:3000,http://frontend

# Application Configuration
APP_NAME=Peoples Bank API
APP_VERSION=1.0.0
DEBUG=false
EOF

print_status "✅ Environment files updated"

# Make scripts executable
chmod +x scripts/*.sh
print_status "✅ Scripts made executable"

# Check dependencies
print_status "Checking dependencies..."

# Check for nerdctl
if command -v nerdctl &> /dev/null; then
    print_status "✅ nerdctl found: $(nerdctl version --short)"
else
    print_warning "⚠️  nerdctl not found. Please install nerdctl:"
    echo "  Visit: https://github.com/containerd/nerdctl"
fi

# Check for openssl
if command -v openssl &> /dev/null; then
    print_status "✅ openssl found"
else
    print_error "❌ openssl not found. Please install openssl"
fi

# Check for curl
if command -v curl &> /dev/null; then
    print_status "✅ curl found"
else
    print_warning "⚠️  curl not found. Install curl for health checks"
fi

# Optional: Check for Trivy security scanner
if command -v trivy &> /dev/null; then
    print_status "✅ trivy found for security scanning"
else
    print_warning "⚠️  trivy not found. Install for security scanning:"
    echo "  Visit: https://trivy.dev/"
fi

print_status "🎉 Setup completed successfully!"
echo -e "${GREEN}Next steps:${NC}"
echo -e "  1. Review the generated secrets in the secrets/ directory"
echo -e "  2. Run: ${BLUE}./scripts/build.sh${NC} to build container images"
echo -e "  3. Run: ${BLUE}./scripts/deploy.sh development${NC} to start the application"
echo -e "  4. Access the application at ${BLUE}http://localhost:3000${NC}"

echo -e "${YELLOW}Security Notes:${NC}"
echo -e "  • Secrets have been generated with secure random values"
echo -e "  • Secret files have restricted permissions (600)"
echo -e "  • Change default secrets before production deployment"
echo -e "  • Review all configuration files before deployment"
