#!/bin/bash

# Peoples Bank - Container Build Script using nerdctl
# This script builds all container images using nerdctl with Chainguard security images

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FRONTEND_IMAGE="chingnokas/cg-bank"
BACKEND_IMAGE="chingnokas/cg-backbank"
TAG="${1:-latest}"

echo -e "${BLUE}🏦 Peoples Bank - Container Build Script${NC}"
echo -e "${BLUE}======================================${NC}"

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
    echo "Visit: https://github.com/containerd/nerdctl"
    exit 1
fi

print_status "Using nerdctl version: $(nerdctl version --short)"

# Create build directory if it doesn't exist
mkdir -p build-logs

# Build backend image
print_status "Building backend image..."
nerdctl build \
    --tag "${BACKEND_IMAGE}:${TAG}" \
    --tag "${BACKEND_IMAGE}:latest" \
    --file backend/Dockerfile \
    --progress=plain \
    backend/ 2>&1 | tee build-logs/backend-build.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    print_status "✅ Backend image built successfully"
else
    print_error "❌ Backend image build failed"
    exit 1
fi

# Build frontend image
print_status "Building frontend image..."
nerdctl build \
    --tag "${FRONTEND_IMAGE}:${TAG}" \
    --tag "${FRONTEND_IMAGE}:latest" \
    --file frontend/Dockerfile \
    --progress=plain \
    frontend/ 2>&1 | tee build-logs/frontend-build.log

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    print_status "✅ Frontend image built successfully"
else
    print_error "❌ Frontend image build failed"
    exit 1
fi

# List built images
print_status "Built images:"
nerdctl images | grep "chingnokas"

# Security scan (if available)
if command -v trivy &> /dev/null; then
    print_status "Running security scans with Trivy..."
    
    print_status "Scanning backend image..."
    trivy image "${BACKEND_IMAGE}:${TAG}" --exit-code 1 --severity HIGH,CRITICAL || print_warning "Security issues found in backend image"

    print_status "Scanning frontend image..."
    trivy image "${FRONTEND_IMAGE}:${TAG}" --exit-code 1 --severity HIGH,CRITICAL || print_warning "Security issues found in frontend image"
else
    print_warning "Trivy not found. Skipping security scans."
    print_warning "Install Trivy for security scanning: https://trivy.dev/"
fi

print_status "🎉 Build completed successfully!"
print_status "Images tagged with: ${TAG}"

# Optional: Push to registry
if [ "$2" = "--push" ]; then
    print_status "Pushing images to registry..."
    nerdctl push "${BACKEND_IMAGE}:${TAG}"
    nerdctl push "${FRONTEND_IMAGE}:${TAG}"
    print_status "✅ Images pushed to registry"
fi

echo -e "${GREEN}Build process completed!${NC}"
