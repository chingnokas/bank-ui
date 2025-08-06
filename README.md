# 🏦 Peoples Bank - Secure Containerized Banking Application

A modern, secure banking application built with FastAPI, React, and PostgreSQL, containerized using nerdctl with Chainguard security-hardened images.

## 🔒 Security Features

- **Chainguard Images**: Uses distroless, security-hardened base images
- **PostgreSQL**: ACID-compliant database for financial data integrity
- **JWT Authentication**: Secure token-based authentication
- **Secrets Management**: Docker secrets for sensitive data
- **Network Isolation**: Isolated container networks
- **Non-root Containers**: All containers run as non-root users
- **Security Headers**: Comprehensive security headers in nginx
- **Input Validation**: Pydantic models for API validation

## 🏗️ Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Frontend      │    │    Backend      │    │   PostgreSQL    │
│   (React)       │◄──►│   (FastAPI)     │◄──►│   Database      │
│   Port: 80      │    │   Port: 8000    │    │   Port: 5432    │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │     Redis       │
                    │   (Caching)     │
                    │   Port: 6379    │
                    └─────────────────┘
```

## 🚀 Quick Start

### Prerequisites

- [nerdctl](https://github.com/containerd/nerdctl) (Container runtime)
- [containerd](https://containerd.io/) (Container daemon)
- OpenSSL (for secret generation)
- Make (optional, for convenience commands)

### 1. Initial Setup

```bash
# Clone the repository
git clone <repository-url>
cd bank-ui

# Run initial setup (generates secrets, configures environment)
make setup
# or
./scripts/setup.sh
```

### 2. Build Container Images

```bash
# Build all images using nerdctl with Chainguard base images
make build
# or
./scripts/build.sh
```

### 3. Deploy Application

```bash
# Deploy to development environment
make deploy-dev
# or
./scripts/deploy.sh development
```

### 4. Access the Application

- **Frontend**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API Documentation**: http://localhost:8000/docs

## 📋 Available Commands

### Using Make (Recommended)

```bash
make help              # Show all available commands
make setup             # Initial setup and secret generation
make build             # Build container images
make deploy-dev        # Deploy to development
make deploy-prod       # Deploy to production
make start             # Start application (alias for deploy-dev)
make stop              # Stop all services
make restart           # Restart all services
make logs              # Show logs from all services
make status            # Show service status
make test              # Run smoke tests
make clean             # Clean up containers and images
make security-scan     # Run security scans (requires Trivy)
```

### Using Scripts Directly

```bash
./scripts/setup.sh                    # Initial setup
./scripts/build.sh [tag] [--push]     # Build images
./scripts/deploy.sh [environment]     # Deploy application
```

## 🔧 Configuration

### Environment Variables

The application uses environment-specific configuration:

- **Development**: `docker-compose.override.yml`
- **Production**: `docker-compose.prod.yml`

### Secrets Management

Secrets are stored in the `secrets/` directory:

- `db_password.txt` - PostgreSQL password
- `jwt_secret.txt` - JWT signing secret
- `redis_password.txt` - Redis password

**⚠️ Important**: Change default secrets before production deployment!

### Database Migration

The application automatically migrates from MongoDB to PostgreSQL:

- Uses SQLAlchemy ORM for database operations
- Automatic table creation on startup
- ACID compliance for financial transactions

## 🛡️ Security Considerations

### Container Security

- **Distroless Images**: Chainguard images with minimal attack surface
- **Non-root Users**: All containers run as non-privileged users
- **Read-only Filesystems**: Containers use read-only root filesystems
- **Security Contexts**: Proper security contexts and capabilities

### Network Security

- **Isolated Networks**: Services communicate through isolated Docker networks
- **Port Restrictions**: Only necessary ports are exposed
- **CORS Configuration**: Restricted CORS origins for production

### Data Security

- **Encrypted Secrets**: Docker secrets for sensitive data
- **Password Hashing**: bcrypt for password hashing
- **JWT Tokens**: Secure token-based authentication
- **Input Validation**: Comprehensive input validation with Pydantic

## 🧪 Testing

### Smoke Tests

```bash
make test
# or
./scripts/deploy.sh development --test
```

### Security Scanning

```bash
make security-scan
# Requires Trivy: https://trivy.dev/
```

### Manual Testing

1. **Frontend Health**: `curl http://localhost:3000/`
2. **Backend Health**: `curl http://localhost:8000/api/`
3. **Database Connection**: `make dev-shell-db`

## 📊 Monitoring

### Service Status

```bash
make status           # Show service status
make logs            # Show all logs
make logs-backend    # Backend logs only
make logs-frontend   # Frontend logs only
make logs-db         # Database logs only
```

### Resource Monitoring

```bash
make monitor         # Real-time resource usage
```

## 🔄 Database Operations

### Backup

```bash
make backup-db       # Create database backup
```

### Restore

```bash
make restore-db BACKUP=backup_20240101_120000.sql
```

## 🚀 Production Deployment

### 1. Security Checklist

- [ ] Change all default secrets
- [ ] Review CORS origins
- [ ] Configure SSL certificates
- [ ] Set up monitoring and logging
- [ ] Configure backup strategy
- [ ] Review security headers

### 2. Deploy to Production

```bash
make deploy-prod
# or
./scripts/deploy.sh production
```

### 3. Production Configuration

Production deployment includes:

- Resource limits and reservations
- No exposed database ports
- Enhanced security configurations
- Optional reverse proxy setup

## 🛠️ Development

### Development Environment

```bash
make dev             # Complete development setup
make dev-shell-backend   # Backend container shell
make dev-shell-frontend  # Frontend container shell
make dev-shell-db        # Database shell
```

### Code Quality

```bash
make install-deps    # Install development dependencies
make format-code     # Format Python and JavaScript code
make lint           # Run linters
```

## 📁 Project Structure

```
bank-ui/
├── backend/                 # FastAPI backend
│   ├── Dockerfile          # Backend container definition
│   ├── server.py           # Main application
│   ├── database.py         # Database models and config
│   └── requirements.txt    # Python dependencies
├── frontend/               # React frontend
│   ├── Dockerfile         # Frontend container definition
│   ├── nginx.conf         # Nginx configuration
│   ├── package.json       # Node.js dependencies
│   └── src/              # React source code
├── scripts/               # Build and deployment scripts
│   ├── setup.sh          # Initial setup
│   ├── build.sh          # Container build script
│   └── deploy.sh         # Deployment script
├── secrets/              # Docker secrets (generated)
├── database/            # Database initialization
│   └── init/           # SQL initialization scripts
├── docker-compose.yml   # Main compose file
├── docker-compose.override.yml  # Development overrides
├── docker-compose.prod.yml      # Production configuration
└── Makefile            # Convenience commands
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Run tests and security scans
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🆘 Support

For support and questions:

1. Check the logs: `make logs`
2. Review the documentation
3. Open an issue on GitHub

---

**⚠️ Security Notice**: This is a demo banking application. Do not use in production without proper security review and additional hardening.
