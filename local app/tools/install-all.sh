#!/bin/bash

################################################################################
# Cardano Community Suite - Complete Installation & Launch Script
################################################################################
# This script downloads all Cardano tools, sets up the environment,
# and launches all GUI applications in one go (Linux/macOS version).
################################################################################

set -e

# ============================================================================
# CONFIGURATION
# ============================================================================

CARDANO_ADDRESSES_VERSION="3.12.0"
CARDANO_CLI_VERSION="8.14.0"
CARDANO_SIGNER_VERSION="1.32.0"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/tools"
DOWNLOADS_DIR="$TOOLS_DIR/downloads"
ADDRESSES_DIR="$TOOLS_DIR/cardano-addresses"
CLI_DIR="$TOOLS_DIR/cardano-cli"
SIGNER_DIR="$TOOLS_DIR/cardano-signer"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Flags
LAUNCH_APP="both"
SKIP_TOOL_DOWNLOAD=false
SKIP_SETUP_ENV=false
NO_LAUNCH=false

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

print_header() {
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║ $1${NC}" | head -c 64 | xargs printf "%-63s"
    echo -e " ${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

print_warn() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

detect_os() {
    case "$(uname -s)" in
        Linux*) echo "Linux" ;;
        Darwin*) echo "Mac" ;;
        *) echo "Unknown" ;;
    esac
}

detect_arch() {
    case "$(uname -m)" in
        x86_64) echo "x86_64" ;;
        aarch64) echo "arm64" ;;
        arm64) echo "arm64" ;;  # macOS
        *) echo "unknown" ;;
    esac
}

download_file() {
    local url="$1"
    local output="$2"
    
    print_info "Downloading from: $url"
    
    if [ -f "$output" ]; then
        print_warn "File already exists: $(basename "$output"). Skipping download."
        return 0
    fi
    
    if command -v curl &> /dev/null; then
        curl -L --progress-bar "$url" -o "$output" || return 1
    elif command -v wget &> /dev/null; then
        wget -q --show-progress "$url" -O "$output" || return 1
    else
        print_error "Neither curl nor wget found. Cannot download files."
        return 1
    fi
    
    print_success "Downloaded: $(basename "$output")"
    return 0
}

extract_archive() {
    local archive="$1"
    local dest="$2"
    
    print_info "Extracting to: $dest"
    
    mkdir -p "$dest"
    
    if [[ "$archive" == *.tar.gz || "$archive" == *.tgz ]]; then
        tar -xzf "$archive" -C "$dest" || return 1
    elif [[ "$archive" == *.tar ]]; then
        tar -xf "$archive" -C "$dest" || return 1
    elif [[ "$archive" == *.zip ]]; then
        unzip -q "$archive" -d "$dest" || return 1
    else
        print_error "Unknown archive format: $archive"
        return 1
    fi
    
    print_success "Extracted: $(basename "$archive")"
    return 0
}

test_command() {
    local cmd="$1"
    local desc="$2"
    
    if command -v "$cmd" &> /dev/null; then
        print_success "$desc is installed and working"
        return 0
    else
        print_warn "$desc not found in PATH"
        return 1
    fi
}

create_env_setup() {
    print_header "Creating Environment Setup Script"
    
    local env_script="$SCRIPT_DIR/setup-env.sh"
    
    cat > "$env_script" << 'EOF'
#!/bin/bash

# Cardano Community Suite - Environment Setup
# Source this file to add tools to your PATH

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/tools"

# Add tools to PATH
export PATH="$TOOLS_DIR/cardano-addresses:$TOOLS_DIR/cardano-cli:$TOOLS_DIR/cardano-signer:$PATH"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}Cardano Community Suite Tools - Environment Configured${NC}"
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""
echo "Tools directory: $TOOLS_DIR"
echo ""
echo "Testing installations:"
echo ""

# Test each tool
if cardano-cli --version > /dev/null 2>&1; then
    echo -e "${GREEN}✓ cardano-cli is ready${NC}"
else
    echo -e "${RED}✗ cardano-cli not found${NC}"
fi

if cardano-address --version > /dev/null 2>&1; then
    echo -e "${GREEN}✓ cardano-address is ready${NC}"
else
    echo -e "${RED}✗ cardano-address not found${NC}"
fi

if cardano-signer --version > /dev/null 2>&1; then
    echo -e "${GREEN}✓ cardano-signer is ready${NC}"
else
    echo -e "${RED}✗ cardano-signer not found${NC}"
fi

echo ""
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo "Ready to use: cardano-cli, cardano-address, cardano-signer"
echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}"
echo ""
EOF
    
    chmod +x "$env_script"
    print_success "Created: setup-env.sh"
}

# ============================================================================
# MAIN INSTALLATION FLOW
# ============================================================================

install_cardano_tools() {
    print_header "Step 1: Downloading Cardano Tools"
    
    # Detect system
    local os=$(detect_os)
    local arch=$(detect_arch)
    print_info "Detected OS: $os, Architecture: $arch"
    
    # Create directories
    print_info "Creating directories..."
    mkdir -p "$TOOLS_DIR" "$DOWNLOADS_DIR" "$ADDRESSES_DIR" "$CLI_DIR" "$SIGNER_DIR"
    print_success "Directories created"
    
    # Determine file extensions based on OS
    local archive_ext=".tar.gz"
    if [ "$os" = "Mac" ]; then
        archive_ext=".tar.gz"
    fi
    
    # Download Cardano Addresses
    print_info "Downloading Cardano Addresses v$CARDANO_ADDRESSES_VERSION..."
    local addresses_url="https://github.com/IntersectMBO/cardano-addresses/releases/download/$CARDANO_ADDRESSES_VERSION/cardano-addresses-$CARDANO_ADDRESSES_VERSION-${os,,}${archive_ext}"
    local addresses_archive="$DOWNLOADS_DIR/cardano-addresses-$CARDANO_ADDRESSES_VERSION${archive_ext}"
    if download_file "$addresses_url" "$addresses_archive"; then
        extract_archive "$addresses_archive" "$ADDRESSES_DIR"
    fi
    
    # Download Cardano CLI
    print_info "Downloading Cardano CLI v$CARDANO_CLI_VERSION..."
    local cli_url="https://github.com/IntersectMBO/cardano-cli/releases/download/$CARDANO_CLI_VERSION/cardano-cli-$CARDANO_CLI_VERSION-${os,,}${archive_ext}"
    local cli_archive="$DOWNLOADS_DIR/cardano-cli-$CARDANO_CLI_VERSION${archive_ext}"
    if download_file "$cli_url" "$cli_archive"; then
        extract_archive "$cli_archive" "$CLI_DIR"
    fi
    
    # Download Cardano Signer
    print_info "Downloading Cardano Signer v$CARDANO_SIGNER_VERSION..."
    local signer_url="https://github.com/gitmachtl/cardano-signer/releases/download/v$CARDANO_SIGNER_VERSION/cardano-signer-${os,,}-${arch}"
    local signer_bin="$SIGNER_DIR/cardano-signer"
    if download_file "$signer_url" "$signer_bin"; then
        chmod +x "$signer_bin"
    fi
    
    print_header "Step 2: Verifying Installations"
    
    # Verify installations
    if [ -f "$ADDRESSES_DIR/cardano-address" ] || [ -f "$ADDRESSES_DIR/bin/cardano-address" ]; then
        print_success "Cardano Addresses: Ready"
    else
        print_warn "Cardano Addresses: Not found or not in expected location"
    fi
    
    if [ -f "$CLI_DIR/cardano-cli" ] || [ -f "$CLI_DIR/bin/cardano-cli" ]; then
        print_success "Cardano CLI: Ready"
    else
        print_warn "Cardano CLI: Not found or not in expected location"
    fi
    
    if [ -f "$SIGNER_DIR/cardano-signer" ]; then
        print_success "Cardano Signer: Ready"
    else
        print_warn "Cardano Signer: Not found or not in expected location"
    fi
}

setup_environment() {
    print_header "Step 3: Setting Up Environment"
    
    create_env_setup
    
    # Update current session PATH
    export PATH="$ADDRESSES_DIR:$CLI_DIR:$SIGNER_DIR:$PATH"
    print_success "Environment PATH updated for current session"
    print_warn "To persist PATH changes, run: source ./setup-env.sh"
}

launch_gui_apps() {
    local app_type="$1"
    
    print_header "Step 4: Launching GUI Applications"
    
    local end_user_gui="$SCRIPT_DIR/end-user-app/EndUserGUI.ps1"
    local admin_gui="$SCRIPT_DIR/community-admin/AdminGUI.ps1"
    local launch_count=0
    
    if [ "$app_type" = "both" ] || [ "$app_type" = "enduser" ]; then
        if [ -f "$end_user_gui" ]; then
            print_info "Launching End-User Application..."
            if powershell -ExecutionPolicy Bypass -File "$end_user_gui" &> /dev/null &
            then
                print_success "End-User Application launched"
                ((launch_count++))
            else
                print_error "Failed to launch End-User Application"
            fi
        fi
    fi
    
    if [ "$app_type" = "both" ] || [ "$app_type" = "admin" ]; then
        if [ -f "$admin_gui" ]; then
            print_info "Launching Admin Application..."
            if powershell -ExecutionPolicy Bypass -File "$admin_gui" &> /dev/null &
            then
                print_success "Admin Application launched"
                ((launch_count++))
            else
                print_error "Failed to launch Admin Application"
            fi
        fi
    fi
    
    if [ $launch_count -eq 0 ]; then
        print_warn "No GUI applications found to launch or launch failed"
        print_info "Looking for scripts in:"
        print_info "  - $end_user_gui"
        print_info "  - $admin_gui"
    fi
}

show_summary() {
    echo ""
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${GREEN} CARDANO COMMUNITY SUITE - INSTALLATION COMPLETE${CYAN}           ║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}\n"
    
    echo -e "${GREEN}✓ Cardano Tools Downloaded:${NC}"
    echo "  • Cardano Addresses v$CARDANO_ADDRESSES_VERSION"
    echo "  • Cardano CLI v$CARDANO_CLI_VERSION"
    echo "  • Cardano Signer v$CARDANO_SIGNER_VERSION"
    echo ""
    
    echo -e "${GREEN}✓ Locations:${NC}"
    echo "  • Tools: $TOOLS_DIR"
    echo "  • End-User App: $SCRIPT_DIR/end-user-app/EndUserGUI.ps1"
    echo "  • Admin App: $SCRIPT_DIR/community-admin/AdminGUI.ps1"
    echo ""
    
    echo -e "${GREEN}✓ Quick Commands:${NC}"
    echo "  • Setup environment: source ./setup-env.sh"
    echo "  • Run end-user GUI: pwsh -ExecutionPolicy Bypass -File ./end-user-app/EndUserGUI.ps1"
    echo "  • Run admin GUI: pwsh -ExecutionPolicy Bypass -File ./community-admin/AdminGUI.ps1"
    echo "  • Test tools:"
    echo "    - cardano-cli --version"
    echo "    - cardano-address --version"
    echo "    - cardano-signer --version"
    echo ""
    
    echo -e "${CYAN}════════════════════════════════════════════════════════════${NC}\n"
}

# ============================================================================
# PARSE ARGUMENTS
# ============================================================================

while [[ $# -gt 0 ]]; do
    case $1 in
        --app)
            LAUNCH_APP="$2"
            shift 2
            ;;
        --skip-download)
            SKIP_TOOL_DOWNLOAD=true
            shift
            ;;
        --skip-env)
            SKIP_SETUP_ENV=true
            shift
            ;;
        --no-launch)
            NO_LAUNCH=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --app {enduser|admin|both}  App to launch (default: both)"
            echo "  --skip-download              Skip tool downloads"
            echo "  --skip-env                   Skip environment setup"
            echo "  --no-launch                  Don't launch GUI apps"
            echo "  -h, --help                   Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# ============================================================================
# EXECUTION FLOW
# ============================================================================

print_header "CARDANO COMMUNITY SUITE - COMPLETE INSTALLER (Linux/macOS)"

print_info "App to launch: $LAUNCH_APP"
print_info "Skip tool download: $SKIP_TOOL_DOWNLOAD"
print_info "Skip environment setup: $SKIP_SETUP_ENV"
print_info "No launch: $NO_LAUNCH"

echo ""

# Install tools
if [ "$SKIP_TOOL_DOWNLOAD" = false ]; then
    install_cardano_tools
else
    print_warn "Skipping tool download"
fi

# Setup environment
if [ "$SKIP_SETUP_ENV" = false ]; then
    setup_environment
else
    print_warn "Skipping environment setup"
fi

# Launch applications
if [ "$NO_LAUNCH" = false ]; then
    launch_gui_apps "$LAUNCH_APP"
else
    print_warn "Skipping application launch"
fi

# Show summary
show_summary

echo -e "${GREEN}All done! Your Cardano Community Suite is ready to use.${NC}\n"
