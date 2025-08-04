#!/bin/bash
# Complete Fix Script - Create ALL Missing Files for AI-NOC
# Run this script from your project root directory: ~/ai-powered-noc/

set -e

echo "🔧 Creating ALL missing files for AI-NOC Docker builds..."

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[CREATING]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[CREATED]${NC} $1"
}

# Create all required directories
print_status "Creating directory structure..."
mkdir -p {config,src/{data-collector,ai-engine,dashboard/backend},logs,data/training}

# =====================================================
# 1. CREATE MAIN REQUIREMENTS.TXT (ROOT LEVEL)
# =====================================================
print_status "requirements.txt"
cat > requirements.txt << 'EOF'
# AI-NOC Main Requirements
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
psycopg2-binary==2.9.9
redis==5.0.1
aioredis==2.0.1
pydantic==2.5.0
python-multipart==0.0.6
python-dotenv==1.0.0
requests==2.31.0
websockets==12.0
asyncio-mqtt==0.16.1
influxdb-client==1.39.0
prometheus-client==0.19.0
structlog==23.2.0
pyyaml==6.0.1
httpx==0.25.2
EOF
print_success "requirements.txt"

# =====================================================
# 2. CREATE DATA COLLECTOR REQUIREMENTS
# =====================================================
print_status "src/data-collector/requirements.txt"
cat > src/data-collector/requirements.txt << 'EOF'
# Data Collector Specific Requirements
pysnmp==4.4.12
snmp-mibs-compiler==0.3.4
aiokafka==0.10.0
scapy==2.5.0
netaddr==0.9.0
pyasn1==0.5.0
asyncio==3.4.3
aiofiles==23.2.1
EOF
print_success "src/data-collector/requirements.txt"

# =====================================================
# 3. CREATE AI ENGINE REQUIREMENTS
# =====================================================
print_status "src/ai-engine/requirements.txt"
cat > src/ai-engine/requirements.txt << 'EOF'
# AI Engine Specific Requirements
tensorflow==2.15.0
scikit-learn==1.3.2
pandas==2.0.3
numpy==1.24.3
matplotlib==3.7.2
seaborn==0.12.2
scipy==1.11.4
joblib==1.3.2
xgboost==2.0.2
lightgbm==4.1.0
optuna==3.4.0
mlflow==2.8.1
networkx==3.2.1
torch==2.1.0
transformers==4.35.0
EOF
print_success "src/ai-engine/requirements.txt"

# =====================================================
# 4. CREATE DASHBOARD BACKEND REQUIREMENTS
# =====================================================
print_status "src/dashboard/backend/requirements.txt"
cat > src/dashboard/backend/requirements.txt << 'EOF'
# Dashboard Backend Specific Requirements
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
alembic==1.12.1
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-multipart==0.0.6
jinja2==3.1.2
aiofiles==23.2.1
EOF
print_success "src/dashboard/backend/requirements.txt"

# =====================================================
# 5. CREATE CONFIGURATION FILES
# =====================================================

# Production configuration
print_status "config/production.yaml"
cat > config/production.yaml << 'EOF'
# AI-NOC Production Configuration

# Database settings
database:
  url: "${DATABASE_URL}"
  pool_size: 10
  max_overflow: 20
  pool_timeout: 30
  pool_recycle: 3600

# Redis settings
redis:
  url: "${REDIS_URL}"
  max_connections: 10
  retry_on_timeout: true
  decode_responses: true

# InfluxDB settings
influxdb:
  url: "${INFLUXDB_URL}"
  token: "${INFLUXDB_TOKEN}"
  org: "${INFLUXDB_ORG}"
  bucket: "${INFLUXDB_BUCKET}"

# Kafka settings
kafka:
  bootstrap_servers: "${KAFKA_BOOTSTRAP_SERVERS}"
  auto_offset_reset: "earliest"
  enable_auto_commit: true
  group_id: "ai-noc-consumer"

# SNMP settings
snmp:
  default_community: "${SNMP_COMMUNITY:public}"
  timeout: 5
  retries: 3
  max_repetitions: 25

# NetFlow settings
netflow:
  listen_port: "${NETFLOW_PORT:2055}"
  buffer_size: 65536

# Syslog settings
syslog:
  listen_port: "${SYSLOG_PORT:514}"
  facility: 16

# Logging settings
logging:
  level: "${LOG_LEVEL:INFO}"
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"
  file: "/app/logs/ai-noc.log"
  max_size: "100MB"
  backup_count: 5

# AI/ML settings
ai:
  model_path: "/app/models"
  training_data_path: "/app/data"
  anomaly_threshold: 0.1
  prediction_window: 3600  # seconds
  retrain_interval: 86400  # seconds (24 hours)

# API settings
api:
  cors_origins: ["*"]
  max_request_size: 16777216  # 16MB
  timeout: 300
  workers: 4

# Monitoring settings
monitoring:
  metrics_port: 9000
  health_check_interval: 30
  prometheus_enabled: true
EOF
print_success "config/production.yaml"

# Development configuration
print_status "config/development.yaml"
cat > config/development.yaml << 'EOF'
# AI-NOC Development Configuration

# Database settings
database:
  url: "postgresql://noc_user:noc_password@postgres:5432/noc_config"
  pool_size: 5
  max_overflow: 10
  echo: true  # Enable SQL logging in development

# Redis settings
redis:
  url: "redis://redis:6379"
  max_connections: 5

# InfluxDB settings
influxdb:
  url: "http://influxdb:8086"
  token: "admin-token-12345"
  org: "ai-noc"
  bucket: "network-metrics"

# Kafka settings
kafka:
  bootstrap_servers: "kafka:9092"
  auto_offset_reset: "earliest"

# SNMP settings
snmp:
  default_community: "public"
  timeout: 2
  retries: 2

# Logging settings
logging:
  level: "DEBUG"
  format: "%(asctime)s - %(name)s - %(levelname)s - %(message)s"

# AI/ML settings
ai:
  model_path: "/app/models"
  training_data_path: "/app/data"
  anomaly_threshold: 0.15  # More lenient in development

# API settings
api:
  cors_origins: ["http://localhost:3000", "http://localhost:8000"]
  reload: true  # Enable hot reload
EOF
print_success "config/development.yaml"

# Nginx configuration
print_status "config/nginx.conf"
cat > config/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
    use epoll;
    multi_accept on;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    client_max_body_size 16M;
    
    gzip on;
    gzip_vary on;
    gzip_min_length 1000;
    gzip_comp_level 6;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml;
    
    include /etc/nginx/conf.d/*.conf;
}
EOF
print_success "config/nginx.conf"

# Nginx default site configuration
print_status "config/default.conf"
cat > config/default.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html index.htm;
    
    # Serve static files
    location /static/ {
        alias /usr/share/nginx/html/static/;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # API proxy to backend
    location /api/ {
        proxy_pass http://dashboard-backend:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 30s;
        proxy_send_timeout 30s;
        proxy_read_timeout 30s;
    }
    
    # WebSocket proxy
    location /ws/ {
        proxy_pass http://dashboard-backend:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_connect_timeout 7d;
        proxy_send_timeout 7d;
        proxy_read_timeout 7d;
    }
    
    # React Router - serve index.html for all routes
    location / {
        try_files $uri $uri/ /index.html;
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        add_header Expires "0";
    }
    
    # Health check endpoint
    location /health {
        access_log off;
        return 200 "healthy\n";
        add_header Content-Type text/plain;
    }
    
    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
}
EOF
print_success "config/default.conf"

# PostgreSQL initialization
print_status "config/init.sql"
cat > config/init.sql << 'EOF'
-- AI-NOC Database Initialization
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Devices table
CREATE TABLE IF NOT EXISTS devices (
    device_id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ip_address INET NOT NULL UNIQUE,
    device_name VARCHAR(100) NOT NULL,
    device_type VARCHAR(50) NOT NULL,
    location VARCHAR(100),
    snmp_community VARCHAR(50) DEFAULT 'public',
    snmp_port INTEGER DEFAULT 161,
    status VARCHAR(20) DEFAULT 'unknown',
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Insert sample devices
INSERT INTO devices (ip_address, device_name, device_type, location) VALUES
('192.168.1.1', 'Core Router', 'router', 'Data Center'),
('192.168.1.10', 'Access Switch 1', 'switch', 'Floor 3'),
('192.168.1.2', 'Firewall', 'firewall', 'DMZ'),
('192.168.1.100', 'Web Server', 'server', 'Data Center')
ON CONFLICT (ip_address) DO NOTHING;

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO noc_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO noc_user;
EOF
print_success "config/init.sql"

# =====================================================
# 6. CREATE BASIC SOURCE CODE FILES
# =====================================================

# Data collector main file
print_status "src/data-collector/main.py"
cat > src/data-collector/main.py << 'EOF'
"""
AI-NOC Data Collector Service
Main entry point for network data collection
"""
import asyncio
import logging
from fastapi import FastAPI
import yaml
import os

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="AI-NOC Data Collector", version="1.0.0")

# Load configuration
config_file = os.getenv('CONFIG_FILE', '/app/config/production.yaml')
if os.path.exists(config_file):
    with open(config_file, 'r') as f:
        config = yaml.safe_load(f)
else:
    config = {}

@app.on_startup
async def startup_event():
    """Initialize collectors on startup"""
    logger.info("Starting AI-NOC Data Collector Service")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "data-collector",
        "version": "1.0.0"
    }

@app.get("/metrics")
async def get_metrics():
    """Get collector metrics"""
    return {
        "devices_monitored": 4,
        "metrics_collected": 1250,
        "last_collection": "2024-01-01T00:00:00Z"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)
EOF
print_success "src/data-collector/main.py"

# AI Engine main file
print_status "src/ai-engine/ai_service.py"
cat > src/ai-engine/ai_service.py << 'EOF'
"""
AI Engine Service for Network Operations Center
"""
import asyncio
import logging
from fastapi import FastAPI
import yaml
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="AI-NOC AI Engine", version="1.0.0")

# Load configuration
config_file = os.getenv('CONFIG_FILE', '/app/config/production.yaml')
if os.path.exists(config_file):
    with open(config_file, 'r') as f:
        config = yaml.safe_load(f)
else:
    config = {}

@app.on_startup
async def startup_event():
    """Initialize AI models on startup"""
    logger.info("Starting AI-NOC AI Engine Service")

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "ai-engine",
        "version": "1.0.0",
        "models_loaded": 3
    }

@app.get("/api/ai/insights")
async def get_ai_insights():
    """Get AI-generated insights"""
    return [
        {
            "id": "insight_1",
            "title": "Network Performance Optimal",
            "description": "All monitored devices showing normal performance",
            "confidence": 94.7,
            "timestamp": "2 minutes ago"
        }
    ]

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8081)
EOF
print_success "src/ai-engine/ai_service.py"

# Dashboard backend main file
print_status "src/dashboard/backend/main.py"
cat > src/dashboard/backend/main.py << 'EOF'
"""
AI-NOC Dashboard Backend
"""
import asyncio
import logging
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
import yaml
import os

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI(title="AI-NOC Dashboard API", version="1.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load configuration
config_file = os.getenv('CONFIG_FILE', '/app/config/production.yaml')
if os.path.exists(config_file):
    with open(config_file, 'r') as f:
        config = yaml.safe_load(f)
else:
    config = {}

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {
        "status": "healthy",
        "service": "dashboard-backend",
        "version": "1.0.0"
    }

@app.get("/api/devices")
async def get_devices():
    """Get network devices"""
    return {
        "devices": [
            {
                "id": "device_1",
                "name": "Core Router",
                "ip": "192.168.1.1",
                "type": "router",
                "status": "up",
                "cpu_usage": 23.5,
                "memory_usage": 67.2
            }
        ]
    }

@app.websocket("/ws/realtime")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket for real-time updates"""
    await websocket.accept()
    try:
        while True:
            data = {"timestamp": "2024-01-01T00:00:00Z", "throughput": 856.7}
            await websocket.send_json(data)
            await asyncio.sleep(5)
    except:
        pass

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
EOF
print_success "src/dashboard/backend/main.py"

# =====================================================
# 7. CREATE FIXED DOCKERFILES
# =====================================================

print_status "Dockerfiles/Dockerfile.data-collector"
cat > Dockerfiles/Dockerfile.data-collector << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libsnmp-dev \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Copy requirements and install dependencies
COPY requirements.txt .
COPY src/data-collector/requirements.txt ./data-collector-requirements.txt

RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -r data-collector-requirements.txt

# Copy source code and config
COPY src/data-collector/ .
COPY config/ ./config/

# Create non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8080/health')" || exit 1

CMD ["python", "main.py"]
EOF
print_success "Dockerfiles/Dockerfile.data-collector"

print_status "Dockerfiles/Dockerfile.ai-engine"
cat > Dockerfiles/Dockerfile.ai-engine << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    gfortran \
    libopenblas-dev \
    liblapack-dev \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Copy requirements and install dependencies
COPY requirements.txt .
COPY src/ai-engine/requirements.txt ./ai-requirements.txt

RUN pip install --no-cache-dir --upgrade pip
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -r ai-requirements.txt

# Copy source code and config
COPY src/ai-engine/ .
COPY config/ ./config/

# Create directories and user
RUN mkdir -p /app/models /app/logs /app/temp
RUN groupadd -r aiuser && useradd -r -g aiuser aiuser
RUN chown -R aiuser:aiuser /app
USER aiuser

EXPOSE 8081

HEALTHCHECK --interval=30s --timeout=30s --start-period=10s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8081/health')" || exit 1

CMD ["python", "ai_service.py"]
EOF
print_success "Dockerfiles/Dockerfile.ai-engine"

print_status "Dockerfiles/Dockerfile.dashboard-backend"
cat > Dockerfiles/Dockerfile.dashboard-backend << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Copy requirements and install dependencies
COPY requirements.txt .
COPY src/dashboard/backend/requirements.txt ./backend-requirements.txt

RUN pip install --no-cache-dir -r requirements.txt
RUN pip install --no-cache-dir -r backend-requirements.txt

# Copy source code and config
COPY src/dashboard/backend/ .
COPY config/ ./config/

# Create non-root user
RUN groupadd -r webuser && useradd -r -g webuser webuser
RUN chown -R webuser:webuser /app
USER webuser

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD python -c "import requests; requests.get('http://localhost:8000/health')" || exit 1

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF
print_success "Dockerfiles/Dockerfile.dashboard-backend"

# Create simple React package.json for frontend
print_status "src/dashboard/frontend/package.json"
mkdir -p src/dashboard/frontend/{src,public}
cat > src/dashboard/frontend/package.json << 'EOF'
{
  "name": "ai-noc-dashboard",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "browserslist": {
    "production": [">0.2%", "not dead", "not op_mini all"],
    "development": ["last 1 chrome version", "last 1 firefox version", "last 1 safari version"]
  }
}
EOF

# Create basic React files
cat > src/dashboard/frontend/public/index.html << 'EOF'
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>AI-NOC Dashboard</title>
  </head>
  <body>
    <div id="root"></div>
  </body>
</html>
EOF

cat > src/dashboard/frontend/src/index.js << 'EOF'
import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(<App />);
EOF

cat > src/dashboard/frontend/src/App.js << 'EOF'
import React from 'react';

function App() {
  return (
    <div style={{padding: '20px', fontFamily: 'Arial, sans-serif'}}>
      <h1>🤖 AI-NOC Dashboard</h1>
      <p>Welcome to the AI-Powered Network Operations Center!</p>
      <div style={{marginTop: '20px', padding: '15px', backgroundColor: '#f0f0f0', borderRadius: '5px'}}>
        <h3>System Status: ✅ Operational</h3>
        <p>All services are running correctly.</p>
      </div>
    </div>
  );
}

export default App;
EOF
print_success "src/dashboard/frontend/ (basic React app)"

print_status "Dockerfiles/Dockerfile.dashboard-frontend"
cat > Dockerfiles/Dockerfile.dashboard-frontend << 'EOF'
# Multi-stage build for React frontend
FROM node:18-alpine AS build

WORKDIR /app

# Copy package files
COPY src/dashboard/frontend/package*.json ./

# Install dependencies
RUN npm install

# Copy source code
COPY src/dashboard/frontend/ .

# Build the application
RUN npm run build

# Production stage with Nginx
FROM nginx:alpine

# Install curl for health checks
RUN apk add --no-cache curl

# Copy built application
COPY --from=build /app/build /usr/share/nginx/html

# Copy custom Nginx configuration
COPY config/nginx.conf /etc/nginx/nginx.conf
COPY config/default.conf /etc/nginx/conf.d/default.conf

# Create non-root user
RUN addgroup -g 1001 -S nginx && \
    adduser -S -D -H -u 1001 -h /var/cache/nginx -s /sbin/nologin -G nginx -g nginx nginx

# Set proper permissions
RUN chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d
RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

USER nginx

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
EOF
print_success "Dockerfiles/Dockerfile.dashboard-frontend"

echo ""
echo -e "${GREEN}✅ ALL FILES CREATED SUCCESSFULLY!${NC}"
echo ""
echo "📁 Created files:"
echo "   ├── requirements.txt"
echo "   ├── config/"
echo "   │   ├── production.yaml"
echo "   │   ├── development.yaml" 
echo "   │   ├── nginx.conf"
echo "   │   ├── default.conf"
echo "   │   └── init.sql"
echo "   ├── src/"
echo "   │   ├── data-collector/"
echo "   │   │   ├── main.py"
echo "   │   │   └── requirements.txt"
echo "   │   ├── ai-engine/"
echo "   │   │   ├── ai_service.py"
echo "   │   │   └── requirements.txt"
echo "   │   └── dashboard/"
echo "   │       ├── backend/"
echo "   │       │   ├── main.py"
echo "   │       │   └── requirements.txt"
echo "   │       └── frontend/"
echo "   │           ├── package.json"
echo "   │           ├── src/App.js"
echo "   │           └── public/index.html"
echo "   └── Dockerfiles/"
echo "       ├── Dockerfile.data-collector"
echo "       ├── Dockerfile.ai-engine"
echo "       ├── Dockerfile.dashboard-backend"
echo "       └── Dockerfile.dashboard-frontend"
echo ""
echo "🚀 Now you can run:"
echo "   docker build -f Dockerfiles/Dockerfile.data-collector -t ai-noc/data-collector:latest ."
echo "   docker build -f Dockerfiles/Dockerfile.ai-engine -t ai-noc/ai-engine:latest ." 
echo "   docker build -f Dockerfiles/Dockerfile.dashboard-backend -t ai-noc/dashboard-backend:latest ."
echo "   docker build -f Dockerfiles/Dockerfile.dashboard-frontend -t ai-noc/dashboard-frontend:latest ."
echo ""
echo "   Or simply run: docker-compose up --build"#!/bin/bash
# Quick Fix Script - Create Missing Configuration Files
# Run this script from your project root directory: ~/ai-powered-noc/

set -e

echo "🔧 Creating missing configuration files for AI-NOC..."

# Create config directory
mkdir -p config

# Create nginx.conf
cat > config/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_bytes_sent "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    sendfile on;
    keepalive_timeout 65;
    gzip on;
    
    include /etc/nginx/conf.d/*.conf;
}
EOF

# Create default.conf
cat > config/default.conf << 'EOF'
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;
    
    # API proxy
    location /api/ {
        proxy_pass http://dashboard-backend:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    # WebSocket proxy
    location /ws/ {
        proxy_pass http://dashboard-backend:8000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header
