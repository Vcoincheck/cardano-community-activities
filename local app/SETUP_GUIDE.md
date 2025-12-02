# Cardano Community Suite - Setup Guide

Complete setup guide for installing Cardano Community Suite with all required tools.

## 📋 Prerequisites

### Windows
- Windows 10 or later
- PowerShell 5.0 or later (usually pre-installed)
- Internet connection
- Administrator access (recommended)
- At least 2GB free disk space

### Linux
- Ubuntu 20.04 LTS or later (or other Linux distributions)
- bash shell
- curl or wget
- tar utility (pre-installed)
- Internet connection
- At least 2GB free disk space

### macOS
- macOS 10.14 or later
- bash or zsh shell
- curl (pre-installed)
- tar utility (pre-installed)
- Internet connection
- At least 2GB free disk space

---

## 🚀 Quick Start

### Windows Setup

**Step 1: Clone/Download Repository**
```bash
git clone https://github.com/quanlychcamdo/Guitool.git
cd Guitool/cardano-community-suite
```

**Step 2: Run Setup**
```bash
# Option A: Double-click setup.bat in File Explorer
setup.bat

# Option B: Run from Command Prompt/PowerShell
.\setup.bat
```

**Step 3: Verify Installation**
```bash
# Run setup-env.bat to add tools to PATH
setup-env.bat

# Test each tool
cardano-cli --version
cardano-address --version
cardano-signer.exe --version
```

---

### Linux/Mac Setup

**Step 1: Clone/Download Repository**
```bash
git clone https://github.com/quanlychcamdo/Guitool.git
cd Guitool/cardano-community-suite
```

**Step 2: Make Setup Script Executable**
```bash
chmod +x setup.sh
```

**Step 3: Run Setup**
```bash
./setup.sh
```

**Step 4: Add Tools to PATH**
```bash
source ./setup-env.sh
```

**Step 5: Verify Installation**
```bash
# Test each tool
cardano-cli --version
cardano-address --version
cardano-signer --version
```

---

## 📁 Directory Structure After Setup

```
cardano-community-suite/
├── setup.sh                    # Linux/Mac setup script
├── setup.bat                   # Windows setup script
├── setup-env.sh                # Linux/Mac environment setup (created)
├── setup-env.bat               # Windows environment setup (created)
│
├── tools/                      # Created by setup scripts
│   ├── downloads/              # Temporary downloads folder
│   │   ├── cardano-addresses-*.tar.gz  (or .zip on Windows)
│   │   ├── cardano-cli-*.tar.gz        (or .zip on Windows)
│   │   └── cardano-signer-*.*
│   │
│   ├── cardano-addresses/      # Cardano Address tool
│   │   ├── cardano-address (or .exe)
│   │   └── ...
│   │
│   ├── cardano-cli/            # Cardano CLI tool
│   │   ├── cardano-cli (or .exe)
│   │   └── ...
│   │
│   └── cardano-signer/         # Cardano Signer tool
│       └── cardano-signer (or .exe)
│
├── lib/                        # PowerShell libraries
├── end-user-app/               # End-user GUI (PowerShell)
├── community-admin/            # Admin GUI (PowerShell)
├── core-crypto/                # Crypto modules
└── docs/                       # Documentation
```

---

## 🔧 What Gets Installed

### 1. Cardano Addresses (v3.12.0)
- **Purpose:** Address derivation and management for Cardano wallets
- **Source:** https://github.com/IntersectMBO/cardano-addresses/releases
- **Installed as:** `tools/cardano-addresses/`

**Usage Examples:**
```bash
# Derive stake address from payment address
cardano-address address inspect <<< "addr1q..."

# Derive payment address from verification key
cardano-address address bootstrap-era <<< "...key..."
```

### 2. Cardano CLI (v8.14.0)
- **Purpose:** Command-line interface for Cardano blockchain operations
- **Source:** https://github.com/IntersectMBO/cardano-cli/releases
- **Installed as:** `tools/cardano-cli/`

**Usage Examples:**
```bash
# Get Cardano network status
cardano-cli query tip --mainnet

# Generate keys
cardano-cli address key-gen --verification-key-file payment.vkey --signing-key-file payment.skey

# Create transactions
cardano-cli transaction build ...
```

### 3. Cardano Signer (v1.32.0)
- **Purpose:** Tool for signing Cardano transactions and messages
- **Source:** https://github.com/gitmachtl/cardano-signer/releases
- **Installed as:** `tools/cardano-signer/`

**Usage Examples:**
```bash
# Sign a message with a signing key
cardano-signer.exe sign --signing-key-file payment.skey --message "hello"

# Verify a signature
cardano-signer.exe verify --public-key "..." --signature "..." --message "..."

# Sign transaction
cardano-signer.exe sign --tx-body-file tx.raw --signing-key-file payment.skey
```

---

## 🔄 Using the Tools

### Adding Tools to PATH Permanently

#### Windows

**Option 1: Using the Setup Script**
```bash
setup-env.bat
```

**Option 2: Manual PATH Configuration**
1. Open "Environment Variables" (search in Start menu)
2. Click "Edit environment variables for your account"
3. Click "New" under "User variables"
4. Variable name: `CARDANO_TOOLS`
5. Variable value: `C:\path\to\cardano-community-suite\tools`
6. In Path variable, add: `%CARDANO_TOOLS%\cardano-addresses;%CARDANO_TOOLS%\cardano-cli;%CARDANO_TOOLS%\cardano-signer`
7. Click OK and restart terminal

**Option 3: Open PowerShell as Admin and Run**
```powershell
$path = [Environment]::GetEnvironmentVariable("Path", "User")
$newPath = $path + ";C:\path\to\tools\cardano-addresses;C:\path\to\tools\cardano-cli;C:\path\to\tools\cardano-signer"
[Environment]::SetEnvironmentVariable("Path", $newPath, "User")
```

#### Linux/macOS

**Option 1: Add to ~/.bashrc or ~/.zshrc**
```bash
# Add this line to ~/.bashrc or ~/.zshrc
export PATH="$HOME/cardano-community-suite/tools/cardano-addresses:$HOME/cardano-community-suite/tools/cardano-cli:$HOME/cardano-community-suite/tools/cardano-signer:$PATH"

# Then reload:
source ~/.bashrc  # or source ~/.zshrc
```

**Option 2: Use the Setup Script**
```bash
source ./setup-env.sh
```

---

## 🧪 Testing Installation

### Windows
```powershell
# PowerShell
cardano-cli --version
cardano-address --version
cardano-signer.exe --version

# Should output version information for each
```

### Linux/macOS
```bash
# Terminal
cardano-cli --version
cardano-address --version
cardano-signer --version

# Should output version information for each
```

---

## 📊 System Compatibility

| OS | Architecture | Support | Notes |
|---|---|---|---|
| Windows | x86 (32-bit) | ✓ | Limited support |
| Windows | x64 (64-bit) | ✅ | Fully supported |
| Linux | x86-64 | ✅ | Fully supported |
| Linux | ARM64 | ✅ | Fully supported |
| macOS | Intel (x64) | ✅ | Fully supported |
| macOS | Apple Silicon (ARM64) | ✅ | Fully supported |

---

## ⚠️ Troubleshooting

### Issue 1: "Command not found" / Tool not in PATH

**Solution:**
```bash
# Windows: Run setup-env.bat
setup-env.bat

# Linux/Mac: Source setup script
source ./setup-env.sh

# Or add to PATH manually (see "Adding Tools to PATH" section)
```

### Issue 2: Download Fails

**Possible Causes:**
- No internet connection
- Firewall/Antivirus blocking downloads
- GitHub rate limiting

**Solutions:**
```bash
# Check internet connection
ping github.com

# Try again later (GitHub has rate limits)

# On Windows, disable Windows Defender temporarily
# On Linux, check firewall: sudo ufw status
```

### Issue 3: Extract/Unzip Fails

**Windows:**
```powershell
# Use Windows built-in extraction
# Right-click .zip file → Extract All

# Or use 7-Zip if installed
# Or delete the zip and re-run setup.bat
```

**Linux/Mac:**
```bash
# Check if tar is installed
tar --version

# Manually extract if auto-extract failed
cd tools/downloads
tar -xzf cardano-addresses-*.tar.gz -C ../cardano-addresses
tar -xzf cardano-cli-*.tar.gz -C ../cardano-cli
```

### Issue 4: Disk Space Issues

**Check available space:**
```bash
# Windows PowerShell
Get-Volume

# Linux/Mac
df -h

# Free up space by deleting downloads folder (optional, after verification)
rm -rf tools/downloads/
```

### Issue 5: Permission Denied (Linux/Mac)

```bash
# Make scripts executable
chmod +x setup.sh setup-env.sh

# Make tools executable
chmod +x tools/*/cardano-*
```

### Issue 6: PowerShell Execution Policy (Windows)

```powershell
# If you get "running scripts is disabled on this system"

# Check current policy
Get-ExecutionPolicy

# Temporarily allow for current session
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Run setup script
.\setup.bat
```

---

## 🔐 Security Considerations

### Download Verification

The setup scripts download from official GitHub repositories:
- **Cardano Addresses:** https://github.com/IntersectMBO/cardano-addresses/releases
- **Cardano CLI:** https://github.com/IntersectMBO/cardano-cli/releases
- **Cardano Signer:** https://github.com/gitmachtl/cardano-signer/releases

All downloads use HTTPS to ensure secure transmission.

### Private Key Safety

⚠️ **IMPORTANT:** Never share your private keys or seed phrases!
- Private keys should be kept offline
- Only enter private keys in trusted applications
- Use cardano-signer for offline signing

---

## 📝 Manual Setup (if automated setup fails)

### Windows Manual Setup

```powershell
# Create directories
mkdir tools/cardano-addresses
mkdir tools/cardano-cli
mkdir tools/cardano-signer

# Download files manually from:
# https://github.com/IntersectMBO/cardano-addresses/releases
# https://github.com/IntersectMBO/cardano-cli/releases
# https://github.com/gitmachtl/cardano-signer/releases

# Extract files to respective directories
# Add to PATH manually
```

### Linux/Mac Manual Setup

```bash
# Create directories
mkdir -p tools/cardano-addresses
mkdir -p tools/cardano-cli
mkdir -p tools/cardano-signer

# Download and extract manually
cd tools

# Cardano Addresses
wget https://github.com/IntersectMBO/cardano-addresses/releases/download/3.12.0/cardano-addresses-3.12.0-linux.tar.gz
tar -xzf cardano-addresses-3.12.0-linux.tar.gz -C cardano-addresses

# Cardano CLI
wget https://github.com/IntersectMBO/cardano-cli/releases/download/8.14.0/cardano-cli-8.14.0-linux.tar.gz
tar -xzf cardano-cli-8.14.0-linux.tar.gz -C cardano-cli

# Cardano Signer
wget https://github.com/gitmachtl/cardano-signer/releases/download/v1.32.0/cardano-signer-linux-x86_64
mv cardano-signer-linux-x86_64 cardano-signer/cardano-signer
chmod +x cardano-signer/cardano-signer

# Add to PATH
export PATH="$PWD/cardano-addresses:$PWD/cardano-cli:$PWD/cardano-signer:$PATH"
```

---

## 🔄 Updating Tools

### Updating Tool Versions

Edit the version numbers in the setup script:

**Windows (setup.bat):**
```batch
set "CARDANO_ADDRESSES_VERSION=3.12.0"
set "CARDANO_CLI_VERSION=8.14.0"
set "CARDANO_SIGNER_VERSION=1.32.0"
```

**Linux/Mac (setup.sh):**
```bash
CARDANO_ADDRESSES_VERSION="3.12.0"
CARDANO_CLI_VERSION="8.14.0"
CARDANO_SIGNER_VERSION="1.32.0"
```

Then re-run the setup script.

---

## 📚 Additional Resources

- **Cardano Documentation:** https://docs.cardano.org
- **Cardano Addresses GitHub:** https://github.com/IntersectMBO/cardano-addresses
- **Cardano CLI GitHub:** https://github.com/IntersectMBO/cardano-cli
- **Cardano Signer GitHub:** https://github.com/gitmachtl/cardano-signer

---

## ✅ Setup Checklist

- [ ] Downloaded Guitool repository
- [ ] Ran setup script (setup.sh or setup.bat)
- [ ] Verified all tools installed successfully
- [ ] Added tools to PATH (ran setup-env script)
- [ ] Tested each tool with `--version` command
- [ ] Tools directory created with all binaries
- [ ] No errors during setup process
- [ ] Ready to use PowerShell apps or web app

---

## 🎉 You're Ready!

Once setup is complete, you can:
- Run PowerShell GUI applications for wallet management
- Launch admin console for community management
- Use command-line tools for advanced operations
- Deploy the web application

For next steps, see the main README.md or specific tool documentation.

