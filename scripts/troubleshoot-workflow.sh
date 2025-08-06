#!/bin/bash

# Troubleshooting script for GitHub Actions workflow failures
# This script helps diagnose common issues with the CI/CD pipeline

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

REPO="chingnokas/bank-ui"

echo -e "${BLUE}🔍 GitHub Actions Workflow Troubleshooting${NC}"
echo "============================================="

# Check if GitHub CLI is available
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        echo -e "${RED}❌ GitHub CLI not found${NC}"
        echo "Please install GitHub CLI: https://cli.github.com/"
        return 1
    else
        echo -e "${GREEN}✅ GitHub CLI is available${NC}"
        return 0
    fi
}

# Check GitHub authentication
check_gh_auth() {
    echo -e "${YELLOW}🔍 Checking GitHub authentication...${NC}"
    
    if ! gh auth status &> /dev/null; then
        echo -e "${RED}❌ Not authenticated with GitHub${NC}"
        echo "Please run: gh auth login"
        return 1
    else
        echo -e "${GREEN}✅ GitHub authentication verified${NC}"
        return 0
    fi
}

# Check repository secrets
check_secrets() {
    echo -e "${YELLOW}🔐 Checking repository secrets...${NC}"
    
    if ! gh secret list --repo $REPO &> /dev/null; then
        echo -e "${RED}❌ Cannot access repository secrets${NC}"
        return 1
    fi
    
    local secrets=$(gh secret list --repo $REPO --json name --jq '.[].name')
    
    echo -e "${BLUE}Current secrets:${NC}"
    echo "$secrets"
    
    # Check for required secrets
    if echo "$secrets" | grep -q "DIGITALOCEAN_TOKEN"; then
        echo -e "${GREEN}✅ DIGITALOCEAN_TOKEN is set${NC}"
    else
        echo -e "${RED}❌ DIGITALOCEAN_TOKEN is missing${NC}"
        echo "Add it at: https://github.com/$REPO/settings/secrets/actions"
        return 1
    fi
    
    return 0
}

# Check latest workflow run
check_workflow() {
    echo -e "${YELLOW}🔄 Checking latest workflow run...${NC}"
    
    local run_info=$(gh run list --repo $REPO --limit 1 --json status,conclusion,url,createdAt)
    
    if [ -z "$run_info" ]; then
        echo -e "${RED}❌ No workflow runs found${NC}"
        return 1
    fi
    
    local status=$(echo "$run_info" | jq -r '.[0].status')
    local conclusion=$(echo "$run_info" | jq -r '.[0].conclusion')
    local url=$(echo "$run_info" | jq -r '.[0].url')
    local created=$(echo "$run_info" | jq -r '.[0].createdAt')
    
    echo -e "${BLUE}Latest workflow run:${NC}"
    echo "Status: $status"
    echo "Conclusion: $conclusion"
    echo "Created: $created"
    echo "URL: $url"
    
    if [ "$conclusion" = "failure" ]; then
        echo -e "${RED}❌ Latest workflow failed${NC}"
        return 1
    elif [ "$conclusion" = "success" ]; then
        echo -e "${GREEN}✅ Latest workflow succeeded${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  Workflow is still running or pending${NC}"
        return 0
    fi
}

# Get workflow logs
get_workflow_logs() {
    echo -e "${YELLOW}📋 Getting workflow logs...${NC}"
    
    local run_id=$(gh run list --repo $REPO --limit 1 --json databaseId --jq '.[0].databaseId')
    
    if [ -z "$run_id" ]; then
        echo -e "${RED}❌ No workflow runs found${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Downloading logs for run ID: $run_id${NC}"
    gh run download $run_id --repo $REPO --dir ./workflow-logs || true
    
    if [ -d "./workflow-logs" ]; then
        echo -e "${GREEN}✅ Logs downloaded to ./workflow-logs/${NC}"
        echo -e "${BLUE}To view logs:${NC}"
        echo "find ./workflow-logs -name '*.txt' -exec echo '=== {} ===' \\; -exec cat {} \\;"
    fi
}

# Check DigitalOcean token validity
check_do_token() {
    echo -e "${YELLOW}🌊 Checking DigitalOcean token...${NC}"
    
    read -p "Enter your DigitalOcean API token to test: " -s DO_TOKEN
    echo
    
    if [ -z "$DO_TOKEN" ]; then
        echo -e "${RED}❌ No token provided${NC}"
        return 1
    fi
    
    # Test the token
    local response=$(curl -s -H "Authorization: Bearer $DO_TOKEN" "https://api.digitalocean.com/v2/account")
    
    if echo "$response" | grep -q '"account"'; then
        echo -e "${GREEN}✅ DigitalOcean token is valid${NC}"
        local email=$(echo "$response" | jq -r '.account.email')
        echo "Account: $email"
        return 0
    else
        echo -e "${RED}❌ DigitalOcean token is invalid${NC}"
        echo "Response: $response"
        return 1
    fi
}

# Common fixes
suggest_fixes() {
    echo -e "${YELLOW}🛠️  Common fixes:${NC}"
    echo ""
    echo -e "${BLUE}1. Missing DigitalOcean Token:${NC}"
    echo "   - Get token: https://cloud.digitalocean.com/account/api/tokens"
    echo "   - Add to GitHub: https://github.com/$REPO/settings/secrets/actions"
    echo "   - Name: DIGITALOCEAN_TOKEN"
    echo ""
    echo -e "${BLUE}2. OpenTofu Configuration Issues:${NC}"
    echo "   - Check infra/simple.tf for basic configuration"
    echo "   - Verify DigitalOcean provider version compatibility"
    echo ""
    echo -e "${BLUE}3. Resource Limits:${NC}"
    echo "   - Check DigitalOcean account limits"
    echo "   - Verify billing/payment status"
    echo "   - Try smaller node sizes (s-1vcpu-2gb)"
    echo ""
    echo -e "${BLUE}4. Re-run Workflow:${NC}"
    echo "   - Go to: https://github.com/$REPO/actions"
    echo "   - Click on failed workflow"
    echo "   - Click 'Re-run all jobs'"
    echo ""
    echo -e "${BLUE}5. Manual Testing:${NC}"
    echo "   - Test locally: cd infra && tofu init && tofu plan"
    echo "   - Check token: ./scripts/troubleshoot-workflow.sh token"
}

# Main troubleshooting function
main() {
    echo -e "${BLUE}Starting troubleshooting process...${NC}"
    echo ""
    
    if ! check_gh_cli; then
        echo -e "${RED}Please install GitHub CLI first${NC}"
        exit 1
    fi
    
    if ! check_gh_auth; then
        echo -e "${RED}Please authenticate with GitHub first${NC}"
        exit 1
    fi
    
    check_secrets
    echo ""
    
    check_workflow
    echo ""
    
    suggest_fixes
}

# Handle script arguments
case "${1:-}" in
    "secrets")
        check_gh_cli && check_gh_auth && check_secrets
        ;;
    "workflow")
        check_gh_cli && check_gh_auth && check_workflow
        ;;
    "logs")
        check_gh_cli && check_gh_auth && get_workflow_logs
        ;;
    "token")
        check_do_token
        ;;
    "fixes")
        suggest_fixes
        ;;
    "")
        main
        ;;
    *)
        echo "Usage: $0 [secrets|workflow|logs|token|fixes]"
        echo ""
        echo "Commands:"
        echo "  secrets   - Check GitHub repository secrets"
        echo "  workflow  - Check latest workflow run status"
        echo "  logs      - Download workflow logs"
        echo "  token     - Test DigitalOcean token validity"
        echo "  fixes     - Show common fixes"
        echo "  (no args) - Run full troubleshooting"
        exit 1
        ;;
esac
