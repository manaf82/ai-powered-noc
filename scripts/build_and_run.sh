#!/bin/bash
# File: scripts/build_and_run.sh

set -e

echo "🚀 AI-NOC Complete Build and Setup Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found. Please run this script from the project root directory."
    exit 1
fi

# Create necessary directories
print_status "Creating necessary directories..."
mkdir -p {logs,data/training,demos/screenshots}

# Build Docker images one by one with error handling
print_status "Building Docker images..."

# Data Collector
print_status "Building data-collector image..."
if docker build -f Dockerfiles/Dockerfile.data-collector -t ai-noc/data-collector:latest .; then
    print_success "data-collector image built successfully"
else
    print_error "Failed to build data-collector image"
    exit 1
fi

# AI Engine
print_status "Building ai-engine image..."
if docker build -f Dockerfiles/Dockerfile.ai-engine -t ai-noc/ai-engine:latest .; then
    print_success "ai-engine image built successfully"
else
    print_error "Failed to build ai-engine image"
    exit 1
fi

# Dashboard Backend
print_status "Building dashboard-backend image..."
if docker build -f Dockerfiles/Dockerfile.dashboard-backend -t ai-noc/dashboard-backend:latest .; then
    print_success "dashboard-backend image built successfully"
else
    print_error "Failed to build dashboard-backend image"
    exit 1
fi

# Dashboard Frontend
print_status "Building dashboard-frontend image..."
if docker build -f Dockerfiles/Dockerfile.dashboard-frontend --target production -t ai-noc/dashboard-frontend:latest .; then
    print_success "dashboard-frontend image built successfully"
else
    print_error "Failed to build dashboard-frontend image"
    exit 1
fi

print_success "All Docker images built successfully!"

# Start the environment
print_status "Starting AI-NOC environment..."
docker-compose up -d

# Wait for services to start
print_status "Waiting for services to start up..."
sleep 30

# Health checks
print_status "Performing health checks..."

# Check each service
services=("postgres:5432" "redis:6379" "influxdb:8086")
for service in "${services[@]}"; do
    IFS=':' read -r name port <<< "$service"
    if docker-compose ps | grep -q "$name.*Up"; then
        print_success "$name is running"
    else
        print_warning "$name may not be ready yet"
    fi
done

# Check application services with HTTP health checks
app_services=("data-collector:8080" "ai-engine:8081" "dashboard-backend:8000")
for service in "${app_services[@]}"; do
    IFS=':' read -r name port <<< "$service"
    if curl -s http://localhost:$port/health > /dev/null 2>&1; then
        print_success "$name health check passed"
    else
        print_warning "$name health check failed - service may still be starting"
    fi
done

# Display access URLs
echo ""
print_success "AI-NOC Environment is ready!"
echo "=================================="
echo ""
echo -e "${BLUE}🌐 Access URLs:${NC}"
echo "  📊 Main Dashboard:    http://localhost:3000"
echo "  🔧 Backend API:       http://localhost:8000"
echo "  📖 API Documentation: http://localhost:8000/docs"
echo "  🤖 AI Engine:         http://localhost:8081"
echo "  📈 Grafana:          http://localhost:3001 (admin/admin)"
echo "  📊 Prometheus:       http://localhost:9090"
echo "  🔍 Kibana:           http://localhost:5601"
echo ""
echo -e "${BLUE}🔧 Management Commands:${NC}"
echo "  View logs:           docker-compose logs -f [service-name]"
echo "  Stop environment:    docker-compose down"
echo "  Restart service:     docker-compose restart [service-name]"
echo "  View status:         docker-compose ps"
echo ""
echo -e "${YELLOW}📝 Next Steps:${NC}"
echo "  1. Open http://localhost:3000 to access the dashboard"
echo "  2. Check the AI insights and network topology"
echo "  3. Monitor logs with: docker-compose logs -f"
echo "  4. Take screenshots for documentation"
echo ""
