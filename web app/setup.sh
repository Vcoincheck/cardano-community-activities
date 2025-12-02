#!/bin/bash
# ============================================
# CARDANO COMMUNITY SUITE - WEB SETUP SCRIPT
# ============================================
# Automated setup for development environment

echo "╔════════════════════════════════════════════════════╗"
echo "║  Cardano Community Suite - Web Setup              ║"
echo "╚════════════════════════════════════════════════════╝"

# Check Node.js
echo ""
echo "✓ Checking Node.js..."
if ! command -v node &> /dev/null; then
    echo "✗ Node.js not found. Please install Node.js 16+ from https://nodejs.org/"
    exit 1
fi
echo "  Version: $(node -v)"

# Check npm
echo ""
echo "✓ Checking npm..."
echo "  Version: $(npm -v)"

# Setup backend
echo ""
echo "✓ Setting up backend..."
cd backend
npm install
echo "  Backend dependencies installed"

# Setup frontend
echo ""
echo "✓ Setting up frontend..."
cd ../frontend
npm install
echo "  Frontend dependencies installed"

# Done
echo ""
echo "✓ Setup complete!"
echo ""
echo "════════════════════════════════════════════════════"
echo "Start development servers:"
echo ""
echo "Terminal 1 - Backend:"
echo "  cd backend && npm run dev"
echo ""
echo "Terminal 2 - Frontend:"
echo "  cd frontend && npm run dev"
echo ""
echo "Then open: http://localhost:5173"
echo "════════════════════════════════════════════════════"
