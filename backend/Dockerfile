# Use Chainguard's Python base image for security
FROM cgr.dev/chainguard/python:latest-dev as builder

# Set working directory
WORKDIR /app

# Install dependencies as root user
USER root
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

# Production stage with minimal Chainguard image
FROM cgr.dev/chainguard/python:latest

# Set working directory
WORKDIR /app

# Copy the installed packages from builder stage
COPY --from=builder /root/.local /home/nonroot/.local

# Copy application code
COPY --chown=nonroot:nonroot . .

# Set environment variables for security
ENV PYTHONPATH=/home/nonroot/.local/lib/python3.13/site-packages:$PYTHONPATH
ENV PATH=/home/nonroot/.local/bin:$PATH
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Security: Use non-root user
USER nonroot

# Health check
HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/api/health', timeout=10)" || exit 1

# Expose port
EXPOSE 8000

# Labels for better container management
LABEL org.opencontainers.image.title="Banking App Backend"
LABEL org.opencontainers.image.description="FastAPI backend for banking application"
LABEL org.opencontainers.image.vendor="Banking Corp"
LABEL org.opencontainers.image.version="1.0.0"
LABEL org.opencontainers.image.source="https://github.com/chingnokas/bank-ui"

# Run the application with production settings
CMD ["/home/nonroot/.local/bin/uvicorn", "server:app", "--host", "0.0.0.0", "--port", "8000", "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker"]
