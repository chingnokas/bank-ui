# 🚀 Quick Start Guide - Banking App CI/CD

## Step 1: Get DigitalOcean API Token

1. **Go to DigitalOcean**: https://cloud.digitalocean.com/account/api/tokens
2. **Click "Generate New Token"**
3. **Settings**:
   - Name: `banking-app-cicd`
   - Scopes: `Read and Write`
   - Expiration: `No expiration`
4. **Copy the token** (starts with `dop_v1_...`)

## Step 2: Create GitHub Repository

1. **Go to**: https://github.com/chingnokas
2. **Click "New repository"**
3. **Settings**:
   - Repository name: `bank-ui`
   - Description: `Secure Banking Application with CI/CD Pipeline`
   - Visibility: `Private` (recommended)
   - **Don't initialize** (we have files already)

## Step 3: Set GitHub Secrets

1. **Go to your repo**: https://github.com/chingnokas/bank-ui
2. **Click Settings → Secrets and variables → Actions**
3. **Click "New repository secret"**
4. **Add this secret**:
   - Name: `DIGITALOCEAN_TOKEN`
   - Value: Your DigitalOcean API token from Step 1

## Step 4: Push Code to GitHub

```bash
# Add all files
git add .

# Commit
git commit -m "Initial commit: Banking app with CI/CD pipeline"

# Add remote
git remote add origin https://github.com/chingnokas/bank-ui.git

# Push
git push -u origin main
```

## Step 5: Watch the Magic! ✨

1. **Go to Actions**: https://github.com/chingnokas/bank-ui/actions
2. **Watch the pipeline run** (takes ~10-15 minutes)
3. **Pipeline will**:
   - ✅ Create DigitalOcean Kubernetes cluster
   - ✅ Build Docker images
   - ✅ Deploy monitoring (Prometheus/Grafana)
   - ✅ Deploy Argo CD
   - ✅ Run health checks

## Step 6: Access Your Application

After successful deployment, check the GitHub Actions summary for:

- **Frontend**: `http://YOUR_LOAD_BALANCER_IP/`
- **Grafana**: `http://GRAFANA_IP:3000/` (admin/BankingGrafana2024!)
- **Prometheus**: `http://PROMETHEUS_IP:9090/`

## 🛠️ Alternative: Use Setup Script

```bash
# Run the automated setup script
./scripts/setup-github-secrets.sh
```

This script will:
- Install GitHub CLI if needed
- Create the repository
- Set up secrets
- Push the code
- Start the pipeline

## 🔍 Troubleshooting

### Pipeline Fails?
1. Check GitHub Actions logs
2. Verify DigitalOcean token is correct
3. Check DigitalOcean account limits/billing

### Need Help?
- Run: `./scripts/validate-deployment.sh`
- Check: `GITHUB_SETUP.md` for detailed guide
- Review: `README-CICD.md` for full documentation

## 🎯 What You Get

After successful deployment:

✅ **Production-ready banking application**  
✅ **Kubernetes cluster on DigitalOcean**  
✅ **CI/CD pipeline with GitOps**  
✅ **Monitoring with Prometheus/Grafana**  
✅ **Security-hardened containers**  
✅ **Auto-scaling and health checks**  

## 🔄 Test the Pipeline

Make changes and push to test:

```bash
# Test frontend change
echo "// Test change" >> frontend/src/App.js
git add frontend/ && git commit -m "test: frontend change" && git push

# Test backend change  
echo "# Test change" >> backend/server.py
git add backend/ && git commit -m "test: backend change" && git push
```

**Expected behavior**:
- Frontend changes → Builds frontend + Argo CD syncs
- Backend changes → Builds backend + Argo CD syncs
- Infrastructure changes → Only provisions infrastructure

---

**🎉 That's it! You now have a complete banking application with enterprise-grade CI/CD pipeline!**
