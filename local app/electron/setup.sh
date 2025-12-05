#!/bin/bash

# Cardano Suite - Electron App Setup & Run Script

echo "🚀 Cardano Community Suite - Electron App"
echo "=========================================="
echo ""

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "❌ Node.js not found. Please install Node.js 14+."
    exit 1
fi

echo "✓ Node.js $(node -v) found"
echo "✓ npm $(npm -v) found"
echo ""

# Navigate to electron-app
cd "$(dirname "$0")"

echo "📦 Installing dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ npm install failed"
    exit 1
fi

echo "✓ Dependencies installed"
echo ""

echo "🎨 Available commands:"
echo "  npm start       - Run Electron app"
echo "  npm run dev     - Run with DevTools"
echo "  npm run build   - Build installer"
echo "  npm run pack    - Package without installer"
echo ""

echo "Starting Electron app..."
npm start
