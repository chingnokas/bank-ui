# Multi-stage build using Chainguard Node.js images for security

# Build stage
FROM cgr.dev/chainguard/node:latest-dev as builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package.json yarn.lock ./

# Install dependencies
RUN yarn install --frozen-lockfile --production=false

# Copy source code
COPY . .

# Build the application
RUN yarn build

# Production stage with minimal Chainguard image
FROM cgr.dev/chainguard/nginx:latest

# Copy built application from builder stage
COPY --from=builder /app/build /usr/share/nginx/html

# Copy custom nginx configuration for React SPA
COPY nginx.conf /etc/nginx/nginx.conf

# Security: nginx runs as non-root user by default in Chainguard images
# Expose port 8080
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/ || exit 1

# Labels for better container management
LABEL org.opencontainers.image.title="Banking App Frontend"
LABEL org.opencontainers.image.description="React frontend for banking application"
LABEL org.opencontainers.image.vendor="Banking Corp"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.source="https://github.com/chingnokas/bank-ui"

# Start nginx (use default entrypoint)
# The Chainguard nginx image already has the correct entrypoint
