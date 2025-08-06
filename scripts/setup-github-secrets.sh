#!/bin/bash

# GitHub Secrets Setup Script for Banking App CI/CD
# This script helps you set up the required GitHub secrets

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

REPO="chingnokas/bank-ui"

echo -e "${BLUE}🔐 GitHub Secrets Setup for Banking App CI/CD${NC}"
echo "=================================================="

# Check if GitHub CLI is available
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        echo -e "${YELLOW}⚠️  GitHub CLI not found. Installing...${NC}"
        
        # Install GitHub CLI
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update
        sudo apt install gh -y
        
        echo -e "${GREEN}✅ GitHub CLI installed${NC}"
    else
        echo -e "${GREEN}✅ GitHub CLI is available${NC}"
    fi
}

# Check GitHub authentication
check_gh_auth() {
    echo -e "${YELLOW}🔍 Checking GitHub authentication...${NC}"
    
    if ! gh auth status &> /dev/null; then
        echo -e "${YELLOW}⚠️  Not authenticated with GitHub. Please login...${NC}"
        gh auth login
    else
        echo -e "${GREEN}✅ GitHub authentication verified${NC}"
    fi
}

# Get DigitalOcean token
get_do_token() {
    echo -e "${YELLOW}🌊 DigitalOcean Token Setup${NC}"
    echo "You need a DigitalOcean API token with read/write permissions."
    echo ""
    echo -e "${BLUE}To get your token:${NC}"
    echo "1. Go to: https://cloud.digitalocean.com/account/api/tokens"
    echo "2. Click 'Generate New Token'"
    echo "3. Name: 'banking-app-cicd'"
    echo "4. Scopes: 'Read and Write'"
    echo "5. Copy the token (starts with 'dop_v1_')"
    echo ""
    
    read -p "Enter your DigitalOcean API token: " DO_TOKEN
    
    if [[ -z "$DO_TOKEN" ]]; then
        echo -e "${RED}❌ Token cannot be empty${NC}"
        exit 1
    fi
    
    if [[ ! "$DO_TOKEN" =~ ^dop_v1_ ]]; then
        echo -e "${YELLOW}⚠️  Token doesn't look like a DigitalOcean token (should start with 'dop_v1_')${NC}"
        read -p "Continue anyway? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    echo -e "${GREEN}✅ DigitalOcean token received${NC}"
}

# Set GitHub secrets
set_github_secrets() {
    echo -e "${YELLOW}🔐 Setting GitHub secrets...${NC}"
    
    # Set DigitalOcean token
    echo "$DO_TOKEN" | gh secret set DIGITALOCEAN_TOKEN --repo $REPO
    echo -e "${GREEN}✅ Set DIGITALOCEAN_TOKEN${NC}"
    
    echo -e "${BLUE}ℹ️  KUBE_CONFIG_DATA will be set automatically after cluster creation${NC}"
    echo -e "${BLUE}ℹ️  GITHUB_TOKEN is automatically provided by GitHub Actions${NC}"
}

# Verify secrets
verify_secrets() {
    echo -e "${YELLOW}🔍 Verifying secrets...${NC}"
    
    echo -e "${BLUE}Current repository secrets:${NC}"
    gh secret list --repo $REPO
}

# Create repository if it doesn't exist
create_repo() {
    echo -e "${YELLOW}📁 Checking repository...${NC}"
    
    if ! gh repo view $REPO &> /dev/null; then
        echo -e "${YELLOW}⚠️  Repository doesn't exist. Creating...${NC}"
        
        read -p "Make repository private? (Y/n): " private
        if [[ "$private" =~ ^[Nn]$ ]]; then
            gh repo create $REPO --public --description "Secure Banking Application with CI/CD Pipeline"
        else
            gh repo create $REPO --private --description "Secure Banking Application with CI/CD Pipeline"
        fi
        
        echo -e "${GREEN}✅ Repository created${NC}"
    else
        echo -e "${GREEN}✅ Repository exists${NC}"
    fi
}

# Push code to repository
push_code() {
    echo -e "${YELLOW}📤 Pushing code to repository...${NC}"
    
    # Check if remote exists
    if ! git remote get-url origin &> /dev/null; then
        git remote add origin https://github.com/$REPO.git
        echo -e "${GREEN}✅ Added remote origin${NC}"
    fi
    
    # Add all files
    git add .
    
    # Commit if there are changes
    if ! git diff --cached --quiet; then
        git commit -m "feat: Complete banking app CI/CD pipeline

- GitHub Actions workflow with OpenTofu infrastructure
- Kubernetes manifests for secure banking application  
- Argo CD GitOps with selective sync
- Prometheus and Grafana monitoring stack
- Security-hardened Chainguard container images
- Comprehensive documentation and setup guides"
        
        echo -e "${GREEN}✅ Changes committed${NC}"
    else
        echo -e "${BLUE}ℹ️  No changes to commit${NC}"
    fi
    
    # Push to GitHub
    git push -u origin main
    echo -e "${GREEN}✅ Code pushed to GitHub${NC}"
}

# Show next steps
show_next_steps() {
    echo -e "${GREEN}🎉 Setup completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Next steps:${NC}"
    echo "1. 🌐 Visit your repository: https://github.com/$REPO"
    echo "2. 🔄 Check GitHub Actions: https://github.com/$REPO/actions"
    echo "3. 📊 Monitor the pipeline execution"
    echo "4. 🚀 Access your deployed application"
    echo ""
    echo -e "${YELLOW}The CI/CD pipeline will:${NC}"
    echo "✅ Provision DigitalOcean Kubernetes cluster"
    echo "✅ Build and push Docker images"
    echo "✅ Deploy monitoring stack (Prometheus/Grafana)"
    echo "✅ Deploy Argo CD for GitOps"
    echo "✅ Run comprehensive health checks"
    echo ""
    echo -e "${BLUE}Expected completion time: 10-15 minutes${NC}"
    echo ""
    echo -e "${GREEN}📖 For detailed information, see:${NC}"
    echo "- GITHUB_SETUP.md - Complete setup guide"
    echo "- README-CICD.md - CI/CD pipeline documentation"
    echo "- ./scripts/validate-deployment.sh - Deployment validation"
}

# Main execution
main() {
    echo -e "${BLUE}Starting GitHub setup process...${NC}"
    echo ""
    
    check_gh_cli
    check_gh_auth
    create_repo
    get_do_token
    set_github_secrets
    verify_secrets
    push_code
    show_next_steps
}

# Handle script arguments
case "${1:-}" in
    "auth")
        check_gh_auth
        ;;
    "token")
        get_do_token
        set_github_secrets
        ;;
    "secrets")
        verify_secrets
        ;;
    "push")
        push_code
        ;;
    "repo")
        create_repo
        ;;
    "")
        main
        ;;
    *)
        echo "Usage: $0 [auth|token|secrets|push|repo]"
        echo ""
        echo "Commands:"
        echo "  auth     - Check GitHub authentication"
        echo "  token    - Set DigitalOcean token"
        echo "  secrets  - Verify GitHub secrets"
        echo "  push     - Push code to repository"
        echo "  repo     - Create repository"
        echo "  (no args) - Run full setup"
        exit 1
        ;;
esac
