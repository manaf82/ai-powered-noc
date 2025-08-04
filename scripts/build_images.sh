#!/bin/bash
# Optimized Docker Build Script

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[BUILD]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo "🐳 Building AI-NOC Docker Images (Optimized)"
echo "=============================================="

# Check if we're in the right directory
if [ ! -f "docker-compose.yml" ]; then
    print_error "docker-compose.yml not found. Run from project root directory."
    exit 1
fi

# Build function with error handling
build_image() {
    local dockerfile=$1
    local tag=$2
    local name=$3
    
    print_status "Building $name..."
    
    if docker build -f "$dockerfile" -t "$tag" . --no-cache; then
        print_success "$name built successfully"
        return 0
    else
        print_error "Failed to build $name"
        return 1
    fi
}

# Build images in order (lightest first)
echo ""
print_status "Starting Docker builds..."

# 1. Dashboard Backend (fastest)
build_image "Dockerfiles/Dockerfile.dashboard-backend" "ai-noc/dashboard-backend:latest" "Dashboard Backend"

# 2. Data Collector (medium)
build_image "Dockerfiles/Dockerfile.data-collector" "ai-noc/data-collector:latest" "Data Collector"

# 3. AI Engine (medium - no tensorflow)
build_image "Dockerfiles/Dockerfile.ai-engine" "ai-noc/ai-engine:latest" "AI Engine"

# 4. Dashboard Frontend (can be slow due to npm install)
build_image "Dockerfiles/Dockerfile.dashboard-frontend" "ai-noc/dashboard-frontend:latest" "Dashboard Frontend"

echo ""
print_success "All Docker images built successfully!"

# Show built images
echo ""
echo "📋 Built Images:"
docker images | grep ai-noc | head -10

echo ""
echo "🚀 Next steps:"
echo "   1. Run: docker-compose up -d"
echo "   2. Check: docker-compose ps"
echo "   3. Access: http://localhost:3000"
