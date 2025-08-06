# Peoples Bank - Makefile for Container Management
# Provides convenient commands for building, deploying, and managing the banking application

.PHONY: help setup build deploy start stop clean logs test security-scan

# Default target
help: ## Show this help message
	@echo "🏦 Peoples Bank - Container Management"
	@echo "====================================="
	@echo ""
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

setup: ## Initial setup - generate secrets and configure environment
	@echo "🔧 Running initial setup..."
	@./scripts/setup.sh

build: ## Build all container images using nerdctl
	@echo "🏗️  Building container images..."
	@./scripts/build.sh

build-push: ## Build and push images to registry
	@echo "🏗️  Building and pushing container images..."
	@./scripts/build.sh latest --push

deploy-dev: ## Deploy to development environment
	@echo "🚀 Deploying to development environment..."
	@./scripts/deploy.sh development

deploy-prod: ## Deploy to production environment
	@echo "🚀 Deploying to production environment..."
	@./scripts/deploy.sh production

start: deploy-dev ## Start the application (alias for deploy-dev)

stop: ## Stop all services
	@echo "🛑 Stopping all services..."
	@nerdctl compose down

restart: stop start ## Restart all services

clean: ## Clean up containers, images, and volumes
	@echo "🧹 Cleaning up..."
	@nerdctl compose down --volumes --remove-orphans
	@nerdctl system prune -f
	@echo "✅ Cleanup completed"

logs: ## Show logs from all services
	@echo "📋 Showing logs..."
	@nerdctl compose logs -f

logs-backend: ## Show backend logs only
	@nerdctl compose logs -f backend

logs-frontend: ## Show frontend logs only
	@nerdctl compose logs -f frontend

logs-db: ## Show database logs only
	@nerdctl compose logs -f postgres

status: ## Show status of all services
	@echo "📊 Service status:"
	@nerdctl compose ps

test: ## Run smoke tests
	@echo "🧪 Running tests..."
	@./scripts/deploy.sh development --test

security-scan: ## Run security scans on images
	@echo "🔒 Running security scans..."
	@if command -v trivy >/dev/null 2>&1; then \
		trivy image peoples-bank-backend:latest; \
		trivy image peoples-bank-frontend:latest; \
	else \
		echo "❌ Trivy not found. Please install Trivy for security scanning."; \
	fi

backup-db: ## Backup database
	@echo "💾 Creating database backup..."
	@mkdir -p backups
	@nerdctl compose exec postgres pg_dump -U bankuser bankdb > backups/backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "✅ Database backup created in backups/ directory"

restore-db: ## Restore database from backup (usage: make restore-db BACKUP=filename)
	@if [ -z "$(BACKUP)" ]; then \
		echo "❌ Please specify backup file: make restore-db BACKUP=backup_20240101_120000.sql"; \
		exit 1; \
	fi
	@echo "🔄 Restoring database from $(BACKUP)..."
	@nerdctl compose exec -T postgres psql -U bankuser -d bankdb < backups/$(BACKUP)
	@echo "✅ Database restored from $(BACKUP)"

dev-shell-backend: ## Open shell in backend container
	@nerdctl compose exec backend /bin/sh

dev-shell-frontend: ## Open shell in frontend container
	@nerdctl compose exec frontend /bin/sh

dev-shell-db: ## Open PostgreSQL shell
	@nerdctl compose exec postgres psql -U bankuser -d bankdb

monitor: ## Show real-time resource usage
	@echo "📈 Monitoring resource usage (Ctrl+C to exit)..."
	@watch -n 2 'nerdctl compose ps && echo "" && nerdctl stats --no-stream'

# Development helpers
install-deps: ## Install development dependencies
	@echo "📦 Installing development dependencies..."
	@cd backend && pip install -r requirements.txt
	@cd frontend && yarn install

format-code: ## Format code (Python and JavaScript)
	@echo "🎨 Formatting code..."
	@cd backend && black . && isort .
	@cd frontend && yarn prettier --write src/

lint: ## Run linting
	@echo "🔍 Running linters..."
	@cd backend && flake8 . && mypy .
	@cd frontend && yarn eslint src/

# Quick development workflow
dev: setup build deploy-dev ## Complete development setup (setup + build + deploy)

# Production deployment workflow
prod: build deploy-prod ## Production deployment (build + deploy to prod)
