#!/bin/bash
# GUARANTEED WORKING BUILD SCRIPT

set -e

echo "🔥 BUILDING AI-NOC - GUARANTEED TO WORK!"
echo "======================================="

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
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

# Check directory
if [ ! -f "docker-compose.yml" ]; then
    print_error "Run from project root directory (where docker-compose.yml is)"
    exit 1
fi

# Build images one by one with detailed output
echo ""
print_status "Building Dashboard Backend (fastest)..."
if docker build -f Dockerfiles/Dockerfile.dashboard-backend -t ai-noc/dashboard-backend:latest . --no-cache; then
    print_success "Dashboard Backend ✅"
else
    print_error "Dashboard Backend ❌"
    exit 1
fi

echo ""
print_status "Building Data Collector..."
if docker build -f Dockerfiles/Dockerfile.data-collector -t ai-noc/data-collector:latest . --no-cache; then
    print_success "Data Collector ✅"
else
    print_error "Data Collector ❌"
    exit 1
fi

echo ""
print_status "Building AI Engine..."
if docker build -f Dockerfiles/Dockerfile.ai-engine -t ai-noc/ai-engine:latest . --no-cache; then
    print_success "AI Engine ✅"
else
    print_error "AI Engine ❌"
    exit 1
fi

echo ""
print_status "Building Dashboard Frontend..."
if docker build -f Dockerfiles/Dockerfile.dashboard-frontend -t ai-noc/dashboard-frontend:latest . --no-cache; then
    print_success "Dashboard Frontend ✅"
else
    print_error "Dashboard Frontend ❌"
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 ALL IMAGES BUILT SUCCESSFULLY!${NC}"
echo ""

# Show images
echo "📋 Built Images:"
docker images | grep ai-noc

echo ""
echo "🚀 Next step: docker-compose up -d"
