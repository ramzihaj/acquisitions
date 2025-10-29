#!/bin/bash

# Docker Development Start Script
# This script starts the development environment with Neon Local

set -e

echo "🚀 Starting Acquisitions Development Environment..."
echo "=================================================="

# Check if .env.development exists
if [ ! -f .env.development ]; then
    echo "⚠️  Warning: .env.development not found!"
    echo "Creating from .env..."
    
    if [ -f .env ]; then
        cp .env .env.development
        # Update DATABASE_URL for local development
        sed -i 's|DATABASE_URL=.*|DATABASE_URL=postgres://postgres:postgres@neon-local:5432/main|g' .env.development
        echo "✅ Created .env.development (please review settings)"
    else
        echo "❌ Error: .env file not found. Please create .env.development manually."
        exit 1
    fi
fi

# Stop any existing containers
echo ""
echo "🛑 Stopping any existing containers..."
docker-compose -f docker-compose.dev.yml down

# Start services
echo ""
echo "🔨 Building and starting services..."
docker-compose -f docker-compose.dev.yml up --build -d

# Wait for services to be healthy
echo ""
echo "⏳ Waiting for services to be healthy..."
sleep 5

# Check service status
echo ""
echo "📊 Service Status:"
docker-compose -f docker-compose.dev.yml ps

# Show logs
echo ""
echo "📋 Recent logs:"
docker-compose -f docker-compose.dev.yml logs --tail=20

echo ""
echo "✅ Development environment is running!"
echo "=================================================="
echo "🌐 Application: http://localhost:3000"
echo "🏥 Health Check: http://localhost:3000/health"
echo "📊 View logs: docker-compose -f docker-compose.dev.yml logs -f"
echo "🛑 Stop: docker-compose -f docker-compose.dev.yml down"
echo "=================================================="
