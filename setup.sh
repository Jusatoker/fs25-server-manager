#!/bin/bash

# Farming Simulator 25 Server Manager Setup Script

echo "🚜 Farming Simulator 25 Server Manager Setup"
echo "=============================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Docker is not installed. Please install Docker first."
    echo "   Visit: https://docs.docker.com/get-docker/"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose is not installed. Please install Docker Compose first."
    echo "   Visit: https://docs.docker.com/compose/install/"
    exit 1
fi

echo "✅ Docker and Docker Compose are installed"

# Create necessary directories
echo "📁 Creating directories..."
mkdir -p server-data
mkdir -p logs

# Make scripts executable
echo "🔧 Setting permissions..."
chmod +x start-services.sh
chmod +x server-data/update_server.sh

# Check if FS25 server files exist
if [ ! -f "server-data/dedicatedServer.exe" ]; then
    echo "⚠️  WARNING: FS25 server files not found!"
    echo "   Please copy your Farming Simulator 25 dedicated server files to:"
    echo "   $(pwd)/server-data/"
    echo ""
    echo "   Required files:"
    echo "   - dedicatedServer.exe"
    echo "   - All DLL files"
    echo "   - Configuration files"
    echo ""
    echo "   You can continue with the setup, but the server won't start until"
    echo "   you add the required files."
    echo ""
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled. Add the server files and run this script again."
        exit 1
    fi
else
    echo "✅ FS25 server files found"
fi

# Build and start the container
echo "🐳 Building Docker container..."
if docker-compose build; then
    echo "✅ Container built successfully"
else
    echo "❌ Failed to build container"
    exit 1
fi

echo "🚀 Starting services..."
if docker-compose up -d; then
    echo "✅ Services started successfully"
else
    echo "❌ Failed to start services"
    exit 1
fi

# Wait a moment for services to initialize
echo "⏳ Waiting for services to initialize..."
sleep 10

# Check if services are running
if docker-compose ps | grep -q "Up"; then
    echo "✅ Services are running"
    echo ""
    echo "🎉 Setup completed successfully!"
    echo ""
    echo "Access your FS25 Server Manager:"
    echo "  🌐 Web Interface: http://localhost"
    echo "  🖥️  Server GUI:    http://localhost/vnc/"
    echo "  📊 Direct VNC:    localhost:5900"
    echo ""
    echo "Next steps:"
    echo "  1. Open http://localhost in your browser"
    echo "  2. Use the web interface to start your FS25 server"
    echo "  3. Access the server GUI to configure settings"
    echo ""
    echo "Useful commands:"
    echo "  📋 View logs:     docker-compose logs -f"
    echo "  🔄 Restart:       docker-compose restart"
    echo "  ⏹️  Stop:          docker-compose down"
    echo "  🗑️  Clean up:      docker-compose down -v"
else
    echo "❌ Some services may not be running properly"
    echo "Check the logs with: docker-compose logs"
fi
