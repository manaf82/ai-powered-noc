#!/bin/bash
# IMMEDIATE FIX - Correct the Docker COPY syntax error

echo "🔧 FIXING DOCKER COPY SYNTAX ERROR..."

# Fix Data Collector Dockerfile
cat > Dockerfiles/Dockerfile.data-collector << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libsnmp-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Copy and install requirements
COPY requirements.txt .
COPY src/data-collector/requirements.txt ./data-collector-requirements.txt

RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -r data-collector-requirements.txt

# Copy source code
COPY src/data-collector/ .

# Create basic config directory and file
RUN mkdir -p ./config
RUN echo "# Basic config" > ./config/app.conf

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8080/health || exit 1

CMD ["python", "main.py"]
EOF

# Fix AI Engine Dockerfile
cat > Dockerfiles/Dockerfile.ai-engine << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Copy and install requirements
COPY requirements.txt .
COPY src/ai-engine/requirements.txt ./ai-requirements.txt

RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -r ai-requirements.txt

# Copy source code
COPY src/ai-engine/ .

# Create directories
RUN mkdir -p ./config ./models ./logs
RUN echo "# Basic config" > ./config/app.conf

# Create non-root user
RUN groupadd -r aiuser && useradd -r -g aiuser aiuser
RUN chown -R aiuser:aiuser /app
USER aiuser

EXPOSE 8081

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8081/health || exit 1

CMD ["python", "ai_service.py"]
EOF

# Fix Dashboard Backend Dockerfile
cat > Dockerfiles/Dockerfile.dashboard-backend << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    curl \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Copy and install requirements
COPY requirements.txt .
COPY src/dashboard/backend/requirements.txt ./backend-requirements.txt

RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -r backend-requirements.txt

# Copy source code
COPY src/dashboard/backend/ .

# Create basic config directory
RUN mkdir -p ./config
RUN echo "# Basic config" > ./config/app.conf

# Create non-root user
RUN groupadd -r webuser && useradd -r -g webuser webuser
RUN chown -R webuser:webuser /app
USER webuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

# Fix Dashboard Frontend Dockerfile
cat > Dockerfiles/Dockerfile.dashboard-frontend << 'EOF'
FROM node:18-alpine AS build

WORKDIR /app

# Copy package files and install dependencies
COPY src/dashboard/frontend/package*.json ./
RUN npm install

# Copy source and build
COPY src/dashboard/frontend/ .
RUN npm run build

# Production stage
FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Copy built application
COPY --from=build /app/build /usr/share/nginx/html

# Create a simple nginx config
RUN echo 'server { \
    listen 80; \
    server_name localhost; \
    root /usr/share/nginx/html; \
    index index.html; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
    location /api/ { \
        proxy_pass http://dashboard-backend:8000; \
        proxy_set_header Host $host; \
        proxy_set_header X-Real-IP $remote_addr; \
    } \
    location /health { \
        return 200 "healthy"; \
        add_header Content-Type text/plain; \
    } \
}' > /etc/nginx/conf.d/default.conf

# Set permissions
RUN chown -R nginx:nginx /usr/share/nginx/html
RUN chown -R nginx:nginx /var/cache/nginx
RUN chown -R nginx:nginx /var/log/nginx

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
EOF

echo "✅ Fixed all Dockerfiles - removed problematic COPY syntax"
echo ""
echo "🚀 Now run: ./scripts/build_working.sh"
