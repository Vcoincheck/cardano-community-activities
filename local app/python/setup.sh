#!/bin/bash
# Setup script for Python application

echo "======================================"
echo "Cardano Community Activities - Setup"
echo "======================================"

# Check Python version
python_version=$(python3 --version 2>&1 | grep -oP '\d+\.\d+')
echo "✓ Python version: $python_version"

# Create virtual environment
echo ""
echo "Creating virtual environment..."
python3 -m venv venv

# Activate virtual environment
echo "Activating virtual environment..."
source venv/bin/activate

# Install dependencies
echo ""
echo "Installing dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo ""
echo "======================================"
echo "✓ Setup completed successfully!"
echo ""
echo "To run the application:"
echo "  source venv/bin/activate"
echo "  python main.py"
echo "======================================"
