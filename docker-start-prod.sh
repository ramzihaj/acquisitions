#!/bin/bash

# Docker Production Start Script
# This script starts the production environment with Neon Cloud

set -e

echo "🚀 Starting Acquisitions Production Environment..."
echo "=================================================="

# Check if .env.production exists
if [ ! -f .env.production ]; then
    echo "❌ Error: .env.production not found!"
    echo ""
    echo "Please create .env.production with the following variables:"
    echo "  NODE_ENV=production"
    echo "  PORT=3000"
    echo "  LOG_LEVEL=info"
    echo "  DATABASE_URL=<your-neon-cloud-url>"
    echo "  ARCJET_KEY=<your-arcjet-key>"
    echo ""
    exit 1
fi

# Validate DATABASE_URL contains neon.tech (production check)
DATABASE_URL=$(grep "^DATABASE_URL=" .env.production | cut -d '=' -f2-)
if [[ ! "$DATABASE_URL" =~ "neon.tech" ]]; then
    echo "⚠️  Warning: DATABASE_URL doesn't appear to be a Neon Cloud URL"
    echo "Current value: $DATABASE_URL"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Stop any existing containers
echo ""
echo "🛑 Stopping any existing containers..."
docker-compose -f docker-compose.prod.yml down

# Start services
echo ""
echo "🔨 Building and starting production services..."
docker-compose -f docker-compose.prod.yml --env-file .env.production up --build -d

# Wait for services to be healthy
echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 10

# Check service status
echo ""
echo "📊 Service Status:"
docker-compose -f docker-compose.prod.yml ps

# Test health endpoint
echo ""
echo "🏥 Testing health endpoint..."
sleep 2
if curl -s http://localhost:3000/health > /dev/null; then
    echo "✅ Health check passed!"
else
    echo "⚠️  Health check failed - check logs for details"
fi

# Show logs
echo ""
echo "📋 Recent logs:"
docker-compose -f docker-compose.prod.yml logs --tail=20

echo ""
echo "✅ Production environment is running!"
echo "=================================================="
echo "🌐 Application: http://localhost:3000"
echo "🏥 Health Check: http://localhost:3000/health"
echo "📊 View logs: docker-compose -f docker-compose.prod.yml logs -f"
echo "🛑 Stop: docker-compose -f docker-compose.prod.yml down"
echo "=================================================="
