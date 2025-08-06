# GitHub Repository Setup Guide

This guide will help you set up the GitHub repository with all required secrets for the CI/CD pipeline to work with DigitalOcean and OpenTofu.

## 🚀 Step 1: Create GitHub Repository

1. **Go to GitHub**: https://github.com/chingnokas
2. **Create new repository**:
   - Repository name: `bank-ui`
   - Description: `Secure Banking Application with CI/CD Pipeline`
   - Visibility: `Private` (recommended for banking app)
   - Initialize: `Don't initialize` (we already have files)

## 🔐 Step 2: Required GitHub Secrets

You need to set up these secrets in your GitHub repository:

### Navigate to Repository Settings
1. Go to your repository: `https://github.com/chingnokas/bank-ui`
2. Click **Settings** tab
3. Click **Secrets and variables** → **Actions**
4. Click **New repository secret**

### Required Secrets:

#### 1. DIGITALOCEAN_TOKEN
```bash
# Get your DigitalOcean API token
# Go to: https://cloud.digitalocean.com/account/api/tokens
# Create a new token with read/write permissions
# Copy the token value
```
- **Name**: `DIGITALOCEAN_TOKEN`
- **Value**: Your DigitalOcean API token (starts with `dop_v1_...`)

#### 2. KUBE_CONFIG_DATA (Will be set automatically after cluster creation)
This will be set automatically by the pipeline after the cluster is created.

#### 3. GITHUB_TOKEN (Automatically provided)
This is automatically provided by GitHub Actions.

## 🏗️ Step 3: DigitalOcean Setup

### Create DigitalOcean API Token
1. **Login to DigitalOcean**: https://cloud.digitalocean.com/
2. **Go to API section**: https://cloud.digitalocean.com/account/api/tokens
3. **Generate New Token**:
   - Token name: `banking-app-cicd`
   - Scopes: `Read and Write`
   - Expiration: `No expiration` (or set as needed)
4. **Copy the token** (you won't see it again!)

### Create Spaces Bucket for Terraform State (Optional but Recommended)
1. **Go to Spaces**: https://cloud.digitalocean.com/spaces
2. **Create Space**:
   - Name: `banking-app-terraform-state`
   - Region: `NYC3`
   - File Listing: `Restricted`
3. **Create API Key for Spaces**:
   - Go to API → Spaces Keys
   - Generate new key pair
   - Save Access Key and Secret Key

## 📝 Step 4: Update Configuration Files

### Update OpenTofu Backend (if using Spaces for state)
Edit `infra/main.tf`:

```hcl
terraform {
  backend "s3" {
    endpoint                    = "nyc3.digitaloceanspaces.com"
    key                        = "banking-app/terraform.tfstate"
    bucket                     = "banking-app-terraform-state"
    region                     = "us-east-1"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    # Add these if using Spaces
    access_key = "your-spaces-access-key"
    secret_key = "your-spaces-secret-key"
  }
}
```

## 🚀 Step 5: Push Code to GitHub

```bash
# Add all files
git add .

# Commit changes
git commit -m "Initial commit: Banking app with CI/CD pipeline

- Complete GitHub Actions workflow with OpenTofu
- Kubernetes manifests for banking application
- Argo CD GitOps configuration
- Prometheus and Grafana monitoring
- Security-hardened Chainguard images
- Comprehensive documentation"

# Add GitHub remote (replace with your actual repo URL)
git remote add origin https://github.com/chingnokas/bank-ui.git

# Push to GitHub
git push -u origin main
```

## 🔍 Step 6: Verify Setup

### Check GitHub Actions
1. Go to your repository
2. Click **Actions** tab
3. You should see the workflow run automatically after push

### Monitor the Pipeline
The pipeline will:
1. ✅ Detect changes (all files are new)
2. ✅ Provision DigitalOcean infrastructure with OpenTofu
3. ✅ Build Docker images
4. ✅ Deploy monitoring stack
5. ✅ Deploy Argo CD
6. ✅ Run health checks

## 🛠️ Step 7: Troubleshooting

### Common Issues:

#### 1. "DIGITALOCEAN_TOKEN not found"
- Make sure you added the secret in GitHub repository settings
- Check the token is valid and has read/write permissions

#### 2. "OpenTofu backend initialization failed"
- If using Spaces backend, make sure the bucket exists
- Check access keys are correct

#### 3. "Cluster creation failed"
- Check DigitalOcean account limits
- Verify region availability
- Check billing/payment status

#### 4. "Docker build failed"
- Check Dockerfile syntax
- Verify base images are accessible

### Debug Commands:
```bash
# Check workflow logs in GitHub Actions
# Or run locally:

# Test OpenTofu
cd infra
tofu init
tofu plan -var="do_token=YOUR_TOKEN"

# Test Docker builds
docker build -t test-frontend -f frontend/Dockerfile frontend/
docker build -t test-backend -f backend/Dockerfile backend/
```

## 📊 Step 8: Access Your Application

After successful deployment, you'll get:

### Service URLs (from GitHub Actions output):
- **Frontend**: `http://LOAD_BALANCER_IP/`
- **Backend API**: `http://LOAD_BALANCER_IP:8000/`
- **Grafana**: `http://GRAFANA_IP:3000/` (admin/BankingGrafana2024!)
- **Prometheus**: `http://PROMETHEUS_IP:9090/`

### Argo CD Access:
```bash
# Port forward to access Argo CD
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

# Access at: https://localhost:8080/
```

## 🔄 Step 9: Test the CI/CD Pipeline

### Test Frontend Changes:
```bash
# Make a change to frontend
echo "console.log('CI/CD test');" >> frontend/src/App.js

git add frontend/
git commit -m "test: frontend change"
git push
```

### Test Backend Changes:
```bash
# Make a change to backend
echo "# CI/CD test comment" >> backend/server.py

git add backend/
git commit -m "test: backend change"
git push
```

### Test Infrastructure Changes:
```bash
# Make a change to infrastructure
echo "# Updated infrastructure" >> infra/main.tf

git add infra/
git commit -m "test: infrastructure change"
git push
```

## 📈 Expected Behavior:

- **Frontend changes** → Builds frontend image + Argo CD syncs frontend
- **Backend changes** → Builds backend image + Argo CD syncs backend  
- **Infrastructure changes** → Provisions infrastructure only
- **Monitoring changes** → Deploys monitoring stack only

## 🎯 Success Indicators:

✅ GitHub Actions workflow completes successfully  
✅ DigitalOcean Kubernetes cluster is created  
✅ Docker images are built and pushed to GHCR  
✅ Argo CD applications are synced  
✅ All pods are running and healthy  
✅ Load balancers have external IPs  
✅ Monitoring dashboards show data  

## 🆘 Need Help?

1. **Check GitHub Actions logs** for detailed error messages
2. **Run validation script**: `./scripts/validate-deployment.sh`
3. **Check Kubernetes resources**: `kubectl get all --all-namespaces`
4. **Review this guide** for missed steps

---

**🎉 Once everything is working, you'll have a production-ready banking application with:**
- Automated CI/CD pipeline
- Infrastructure as Code
- GitOps deployment
- Comprehensive monitoring
- Security best practices
