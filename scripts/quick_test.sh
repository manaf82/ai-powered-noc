#!/bin/bash
# Quick Test Script - Verify everything works

set -e

echo "🧪 AI-NOC Quick Test"
echo "==================="

# Test 1: Check if images exist
echo "1. Checking Docker images..."
if docker images ai-noc/data-collector | grep -q latest; then
    echo "   ✅ data-collector image exists"
else
    echo "   ❌ data-collector image missing"
fi

if docker images ai-noc/ai-engine | grep -q latest; then
    echo "   ✅ ai-engine image exists"
else
    echo "   ❌ ai-engine image missing"
fi

if docker images ai-noc/dashboard-backend | grep -q latest; then
    echo "   ✅ dashboard-backend image exists"
else
    echo "   ❌ dashboard-backend image missing"
fi

if docker images ai-noc/dashboard-frontend | grep -q latest; then
    echo "   ✅ dashboard-frontend image exists"
else
    echo "   ❌ dashboard-frontend image missing"
fi

# Test 2: Start services
echo ""
echo "2. Starting services..."
docker-compose up -d

# Test 3: Wait and check health
echo ""
echo "3. Waiting for services to start..."
sleep 30

# Test 4: Health checks
echo ""
echo "4. Health checks..."

if curl -s http://localhost:8080/health | grep -q "healthy"; then
    echo "   ✅ Data Collector healthy"
else
    echo "   ❌ Data Collector not responding"
fi

if curl -s http://localhost:8081/health | grep -q "healthy"; then
    echo "   ✅ AI Engine healthy"
else
    echo "   ❌ AI Engine not responding"
fi

if curl -s http://localhost:8000/health | grep -q "healthy"; then
    echo "   ✅ Dashboard Backend healthy"
else
    echo "   ❌ Dashboard Backend not responding"
fi

if curl -s http://localhost:3000 | grep -q "AI-NOC"; then
    echo "   ✅ Dashboard Frontend responding"
else
    echo "   ❌ Dashboard Frontend not responding"
fi

echo ""
echo "🎉 Quick test completed!"
echo ""
echo "🌐 Access URLs:"
echo "   Dashboard: http://localhost:3000"
echo "   API Docs:  http://localhost:8000/docs"
echo "   Backend:   http://localhost:8000"
echo ""
echo "📊 Service Status:"
docker-compose ps
