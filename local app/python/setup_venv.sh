#!/bin/bash

# Setup Python Virtual Environment for Cardano Community Activities
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$SCRIPT_DIR/venv"

echo "📦 Creating Python virtual environment..."
python3 -m venv "$VENV_DIR"

echo "✅ Virtual environment created at: $VENV_DIR"
echo ""
echo "🔄 Activating virtual environment and installing dependencies..."

# Activate venv and install requirements
source "$VENV_DIR/bin/activate"
pip install --upgrade pip setuptools wheel
pip install -r "$SCRIPT_DIR/requirements.txt"

echo ""
echo "✅ Installation complete!"
echo ""
echo "📝 To activate this virtual environment, run:"
echo "   source $VENV_DIR/bin/activate"
echo ""
echo "📝 To run the app with this venv:"
echo "   source $VENV_DIR/bin/activate"
echo "   python app/main_launcher.py"
echo ""
echo "📝 To deactivate:"
echo "   deactivate"
