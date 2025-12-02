#!/bin/bash

################################################################################
# CARDANO COMMUNITY SUITE - SETUP SCRIPT (BASH)
################################################################################
# Builds and installs all three WinUI 3 applications:
# 1. Cardano Launcher (main entry point)
# 2. End-User Tools (keypair generation, signing)
# 3. Community Admin Dashboard (verification, registry)
# Requires: Linux/macOS, .NET 8.0 SDK

set -e

################################################################################
# CONFIGURATION
################################################################################

CONFIGURATION="Release"
SKIP_RESTORE=0
OPEN_AFTER_BUILD=0
SHOW_HELP=0

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -Debug)
            CONFIGURATION="Debug"
            shift
            ;;
        --skip-restore)
            SKIP_RESTORE=1
            shift
            ;;
        --open)
            OPEN_AFTER_BUILD=1
            shift
            ;;
        --help|-h)
            SHOW_HELP=1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SUITE_PATH="$SCRIPT_DIR"
LAUNCHER_PATH="$SUITE_PATH/cardano-launcher-winui"
ENDUSER_PATH="$SUITE_PATH/end-user-app-winui"
ADMIN_PATH="$SUITE_PATH/community-admin-winui"

################################################################################
# FUNCTIONS
################################################################################

print_header() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║  $1${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

print_step() {
    local step=$1
    local total=$2
    local message=$3
    echo -e "${YELLOW}[$step/$total] ▶ $message${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

show_help() {
    cat << EOF
╔════════════════════════════════════════════════════════════════════════════╗
║  CARDANO COMMUNITY SUITE - SETUP SCRIPT                                   ║
║  Builds and installs all three WinUI 3 applications                        ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE:
    ./setup.sh [OPTIONS]

OPTIONS:
    -Debug                  Build Debug configuration (default: Release)
    --skip-restore          Skip dotnet restore (use if dependencies cached)
    --open                  Launch Cardano Launcher after build
    --help, -h              Show this help message

EXAMPLES:
    # Standard setup (Release build)
    ./setup.sh

    # Debug build for development
    ./setup.sh -Debug

    # Full setup and launch the app
    ./setup.sh --open

    # Quick rebuild (skip restore)
    ./setup.sh --skip-restore

REQUIREMENTS:
    • Ubuntu 22.04+ or macOS 11+
    • .NET 8.0 SDK or later
    • 2 GB free disk space

WHAT IT INSTALLS:
    1️⃣  Cardano Launcher (main entry point)
    2️⃣  End-User Tools (keypair generation, signing)
    3️⃣  Community Admin Dashboard (verification, registry)

OUTPUT LOCATION:
    After successful build, executables are located in:
    • Launcher:     cardano-launcher-winui/bin/$CONFIGURATION/net8.0-windows.../
    • End-User:     end-user-app-winui/bin/$CONFIGURATION/net8.0-windows.../
    • Admin:        community-admin-winui/bin/$CONFIGURATION/net8.0-windows.../

NOTE: These are Windows applications (.NET 8 targeting Windows).
They can be run on Linux/macOS using Windows Subsystem for Linux (WSL)
or via Wine with additional setup.

TROUBLESHOOTING:
    If build fails:
    1. Verify .NET 8.0 SDK: dotnet --version
    2. Check disk space: df -h
    3. Try: dotnet clean
    4. Try: ./setup.sh -Debug

For more information, see README.md or docs/
EOF
}

check_requirements() {
    print_header "🔍 Checking Requirements"
    
    local step=1
    local total=4
    
    # Check .NET SDK
    print_step $step $total "Checking .NET SDK installation"
    if ! command -v dotnet &> /dev/null; then
        print_error ".NET SDK not found. Please install .NET 8.0 SDK or later."
        echo "Visit: https://dotnet.microsoft.com/download"
        exit 1
    fi
    
    local dotnet_version=$(dotnet --version 2>/dev/null)
    local major_version=$(echo $dotnet_version | cut -d. -f1)
    
    if [ "$major_version" -lt 8 ]; then
        print_error ".NET 8.0 or later required. Found: $dotnet_version"
        exit 1
    fi
    print_success ".NET SDK $dotnet_version"
    
    # Check project directories
    ((step++))
    print_step $step $total "Checking project directories"
    
    local all_found=1
    for dir in "$LAUNCHER_PATH" "$ENDUSER_PATH" "$ADMIN_PATH"; do
        if [ -d "$dir" ]; then
            echo -e "  ${GREEN}✓${NC} $(basename "$dir")"
        else
            echo -e "  ${RED}✗${NC} $(basename "$dir") - NOT FOUND"
            all_found=0
        fi
    done
    
    if [ $all_found -eq 0 ]; then
        print_error "Some project directories not found. Run from cardano-community-suite directory."
        exit 1
    fi
    
    # Check disk space
    ((step++))
    print_step $step $total "Checking disk space"
    
    local available=$(df "$SUITE_PATH" | awk 'NR==2 {print int($4/1024/1024)}')
    if [ $available -lt 2 ]; then
        print_warning "Low disk space: ${available}GB free. Build may fail. Minimum: 2GB"
    else
        print_success "${available}GB free disk space"
    fi
}

build_project() {
    local project_name=$1
    local project_path=$2
    local step=$3
    local total=$4
    
    print_step $step $total "Building $project_name"
    print_info "Location: $project_path"
    print_info "Configuration: $CONFIGURATION"
    
    cd "$project_path"
    
    # Restore if not skipped
    if [ $SKIP_RESTORE -eq 0 ]; then
        echo "  → Restoring NuGet packages..."
        dotnet restore > /dev/null 2>&1 || {
            print_error "$project_name restore failed"
            exit 1
        }
    fi
    
    # Build project
    echo "  → Building project..."
    dotnet build -c "$CONFIGURATION" > /dev/null 2>&1 || {
        print_error "$project_name build failed"
        exit 1
    }
    
    print_success "$project_name built successfully"
}

validate_build() {
    local project_name=$1
    local project_path=$2
    local exe_name=$3
    local step=$4
    local total=$5
    
    print_step $step $total "Validating $project_name"
    
    # Find the built executable
    local exe_path=$(find "$project_path/bin/$CONFIGURATION" -name "$exe_name.exe" 2>/dev/null | head -1)
    
    if [ -n "$exe_path" ]; then
        local size_kb=$(du -h "$exe_path" | cut -f1)
        print_success "$project_name executable found: $exe_path ($size_kb)"
        echo "$exe_path"
    else
        print_error "$project_name executable not found"
    fi
}

show_summary() {
    print_header "✨ Setup Complete"
    
    echo -e "${GREEN}All three applications have been successfully built!${NC}"
    echo ""
    echo -e "${CYAN}📦 Installed Applications:${NC}"
    echo ""
    
    local num=1
    
    if [ -n "$LAUNCHER_EXE" ]; then
        echo "$num. Cardano Launcher"
        echo "   📁 $LAUNCHER_EXE"
        local size_kb=$(du -h "$LAUNCHER_EXE" | cut -f1)
        echo "   💾 Size: $size_kb"
        echo ""
        ((num++))
    fi
    
    if [ -n "$ENDUSER_EXE" ]; then
        echo "$num. End-User Tools"
        echo "   📁 $ENDUSER_EXE"
        local size_kb=$(du -h "$ENDUSER_EXE" | cut -f1)
        echo "   💾 Size: $size_kb"
        echo ""
        ((num++))
    fi
    
    if [ -n "$ADMIN_EXE" ]; then
        echo "$num. Community Admin Dashboard"
        echo "   📁 $ADMIN_EXE"
        local size_kb=$(du -h "$ADMIN_EXE" | cut -f1)
        echo "   💾 Size: $size_kb"
        echo ""
    fi
    
    echo -e "${CYAN}🚀 Next Steps:${NC}"
    echo "   1. Transfer executables to Windows machine"
    echo "   2. Run 'Cardano Launcher' to start the main application"
    echo "   3. Use the launcher to access End-User Tools or Admin Dashboard"
    echo "   4. Check documentation in docs/ folder for detailed guides"
    echo ""
    echo -e "${CYAN}📖 Documentation:${NC}"
    echo "   • README.md - Project overview"
    echo "   • docs/API_SPEC.md - API documentation"
    echo "   • docs/SECURITY_MODEL.md - Security architecture"
    echo "   • docs/USER_FLOW_*.md - User workflows"
    echo ""
}

################################################################################
# MAIN EXECUTION
################################################################################

# Show help if requested
if [ $SHOW_HELP -eq 1 ]; then
    show_help
    exit 0
fi

echo -e "${CYAN}"
cat << "EOF"
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║         🔗 CARDANO COMMUNITY SUITE - SETUP & BUILD SYSTEM 🔗              ║
║                                                                            ║
║  Installing: Launcher + End-User Tools + Community Admin Dashboard        ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Check requirements
check_requirements

# Build all projects
print_header "🔨 Building Applications"

local step=1
local total=3

build_project "Cardano Launcher" "$LAUNCHER_PATH" $step $total
((step++))

build_project "End-User Tools" "$ENDUSER_PATH" $step $total
((step++))

build_project "Community Admin Dashboard" "$ADMIN_PATH" $step $total

# Validate builds
print_header "✔️  Validating Builds"

LAUNCHER_EXE=$(validate_build "Cardano Launcher" "$LAUNCHER_PATH" "CardanoLauncher" 1 3)
ENDUSER_EXE=$(validate_build "End-User Tools" "$ENDUSER_PATH" "CardanoEndUserTool" 2 3)
ADMIN_EXE=$(validate_build "Community Admin" "$ADMIN_PATH" "CardanoCommunityAdmin" 3 3)

# Show summary
show_summary

echo -e "${CYAN}Setup script completed successfully! ✨${NC}"
echo ""
