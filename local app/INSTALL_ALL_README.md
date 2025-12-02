# ONE-CLICK INSTALLER - Cardano Community Suite

Complete installation and launch of Cardano Community Suite with a single command.

## Features

✅ **Automatic Tool Download**
- Cardano Addresses v3.12.0
- Cardano CLI v8.14.0
- Cardano Signer v1.32.0

✅ **Automatic Setup**
- Environment PATH configuration
- Tool verification
- Directory organization

✅ **Instant Launch**
- End-User GUI
- Admin GUI
- Both or single selection

✅ **Cross-Platform Support**
- Windows (PowerShell)
- Linux (Bash)
- macOS (Bash)

---

## Quick Start

### Windows

#### Option 1: Double-Click (Easiest)
```
1. Navigate to: cardano-community-suite/
2. Double-click: install-all.ps1
3. Click "Run" if prompted
4. Wait for completion
5. GUIs will launch automatically
```

#### Option 2: PowerShell Command
```powershell
# Navigate to the directory
cd cardano-community-suite

# Run the installer
.\install-all.ps1

# Or with options
.\install-all.ps1 -LaunchApp "admin"
.\install-all.ps1 -SkipToolDownload
.\install-all.ps1 -NoLaunch
```

### Linux / macOS

#### Make Script Executable
```bash
chmod +x install-all.sh
```

#### Run Installer
```bash
# Navigate to the directory
cd cardano-community-suite

# Run the installer
./install-all.sh

# Or with options
./install-all.sh --app admin
./install-all.sh --skip-download
./install-all.sh --no-launch
```

---

## Script Options

### Windows (install-all.ps1)

```powershell
.\install-all.ps1 [options]

Options:
  -LaunchApp <enduser|admin|both>  Which app to launch (default: both)
  -SkipToolDownload               Skip downloading Cardano tools
  -SkipSetupEnv                   Skip environment setup
  -NoLaunch                       Skip launching GUI apps
  -Help                           Show help message
```

**Examples:**
```powershell
# Install everything and launch both apps
.\install-all.ps1

# Only launch end-user app
.\install-all.ps1 -LaunchApp enduser

# Only launch admin app
.\install-all.ps1 -LaunchApp admin

# Install and setup, but don't launch apps
.\install-all.ps1 -NoLaunch

# Skip downloading tools (already installed)
.\install-all.ps1 -SkipToolDownload

# Just setup environment for already downloaded tools
.\install-all.ps1 -SkipToolDownload -LaunchApp none
```

### Linux / macOS (install-all.sh)

```bash
./install-all.sh [options]

Options:
  --app {enduser|admin|both}  Which app to launch (default: both)
  --skip-download             Skip downloading Cardano tools
  --skip-env                  Skip environment setup
  --no-launch                 Skip launching GUI apps
  -h, --help                  Show help message
```

**Examples:**
```bash
# Install everything and launch both apps
./install-all.sh

# Only launch end-user app
./install-all.sh --app enduser

# Only launch admin app
./install-all.sh --app admin

# Install and setup, but don't launch apps
./install-all.sh --no-launch

# Skip downloading tools (already installed)
./install-all.sh --skip-download

# Just setup environment for already downloaded tools
./install-all.sh --skip-download --app none
```

---

## What Gets Installed

After running the installer, you'll have:

```
cardano-community-suite/
├── tools/
│   ├── cardano-addresses/     ← Cardano Addresses tool
│   ├── cardano-cli/           ← Cardano CLI tool
│   ├── cardano-signer/        ← Cardano Signer tool
│   └── downloads/             ← Original downloaded files
├── setup-env.bat              ← Windows environment setup (auto-created)
├── setup-env.sh               ← Linux/Mac environment setup (auto-created)
├── end-user-app/
│   └── EndUserGUI.ps1         ← End-user GUI (launched)
├── community-admin/
│   └── AdminGUI.ps1           ← Admin GUI (launched)
└── ... (other project files)
```

---

## Verification

After installation, verify everything is working:

### Windows
```powershell
# Run environment setup to ensure PATH is updated
.\setup-env.bat

# Test each tool
cardano-cli --version
cardano-address --version
cardano-signer.exe --version
```

### Linux/macOS
```bash
# Run environment setup to ensure PATH is updated
source ./setup-env.sh

# Test each tool
cardano-cli --version
cardano-address --version
cardano-signer --version
```

---

## Troubleshooting

### Issue: "PowerShell script not found" (Windows)

**Solution 1: Check Execution Policy**
```powershell
# Allow scripts for current session only
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process

# Then run the script
.\install-all.ps1
```

**Solution 2: Use Command Prompt**
```cmd
powershell -ExecutionPolicy Bypass -File install-all.ps1
```

### Issue: "Permission denied" (Linux/macOS)

```bash
chmod +x install-all.sh
./install-all.sh
```

### Issue: Download fails

Possible causes:
- No internet connection
- GitHub rate limiting
- Firewall/antivirus blocking

**Solutions:**
```bash
# Check internet
ping github.com

# Try running again (rate limits reset)
# Or wait 1 hour and try again

# Or manually download from:
# https://github.com/IntersectMBO/cardano-addresses/releases
# https://github.com/IntersectMBO/cardano-cli/releases
# https://github.com/gitmachtl/cardano-signer/releases
```

### Issue: GUI app doesn't launch

Check if PowerShell GUI scripts exist:
```powershell
# Windows
Test-Path .\end-user-app\EndUserGUI.ps1
Test-Path .\community-admin\AdminGUI.ps1

# Linux/macOS (check if files exist)
ls -la end-user-app/EndUserGUI.ps1
ls -la community-admin/AdminGUI.ps1
```

If missing, you may need to:
1. Create those GUI scripts
2. Or run the install with `-NoLaunch` and launch manually later

---

## Advanced Usage

### Modify Download Versions

Edit the version variables in the script:

**Windows (install-all.ps1):**
```powershell
$CARDANO_ADDRESSES_VERSION = "3.12.0"
$CARDANO_CLI_VERSION = "8.14.0"
$CARDANO_SIGNER_VERSION = "1.32.0"
```

**Linux/macOS (install-all.sh):**
```bash
CARDANO_ADDRESSES_VERSION="3.12.0"
CARDANO_CLI_VERSION="8.14.0"
CARDANO_SIGNER_VERSION="1.32.0"
```

Then re-run the installer.

### Skip Certain Components

```powershell
# Windows: Just update environment without re-downloading
.\install-all.ps1 -SkipToolDownload -SkipSetupEnv
```

```bash
# Linux/macOS: Just update environment without re-downloading
./install-all.sh --skip-download --skip-env
```

### Batch Installation (Multiple Machines)

Create a wrapper script to install on multiple machines:

**Windows:**
```powershell
# deploy-to-servers.ps1
$servers = @("server1", "server2", "server3")
foreach ($server in $servers) {
    Write-Host "Deploying to $server..."
    Invoke-Command -ComputerName $server -ScriptBlock {
        cd C:\cardano-suite
        .\install-all.ps1 -NoLaunch
    }
}
```

**Linux/macOS:**
```bash
#!/bin/bash
# deploy-to-servers.sh
servers=("server1" "server2" "server3")
for server in "${servers[@]}"; do
    echo "Deploying to $server..."
    ssh $server "cd /opt/cardano-suite && ./install-all.sh --no-launch"
done
```

---

## Performance Notes

**First Run:**
- Total time: 5-15 minutes (depending on internet speed)
- Downloads: ~500MB total
- Disk space required: ~2GB

**Subsequent Runs:**
- With `--skip-download`: ~30 seconds
- Downloads cached locally in `tools/downloads/`

---

## What's Happening Behind the Scenes

1. **Detection** - OS and architecture detection
2. **Directories** - Creation of required folders
3. **Downloads** - Parallel downloads from GitHub
4. **Extraction** - Automatic archive extraction
5. **Verification** - Checking all tools installed correctly
6. **Environment** - PATH configuration
7. **Launch** - Starting GUI applications

---

## Next Steps After Installation

### For End Users
1. Launch End-User GUI: `EndUserGUI.ps1`
2. Create or import a wallet
3. Generate addresses
4. Sign messages offline
5. Verify signatures online

### For Administrators
1. Launch Admin GUI: `AdminGUI.ps1`
2. Register users in the system
3. Create events/challenges
4. Verify user signatures
5. Generate reports

### For Developers
1. Source the environment: `source ./setup-env.sh` (Linux/Mac) or `setup-env.bat` (Windows)
2. Use tools from command line:
   ```bash
   cardano-cli query tip --mainnet
   cardano-address --version
   cardano-signer --version
   ```
3. Integrate tools into your scripts
4. See QUICK_REFERENCE.md for common commands

---

## Files Reference

| File | Purpose |
|------|---------|
| `install-all.ps1` | Windows one-click installer |
| `install-all.sh` | Linux/macOS one-click installer |
| `setup.bat` | Traditional Windows setup script |
| `setup.sh` | Traditional Linux/macOS setup script |
| `setup-env.bat` | Windows PATH configuration (auto-created) |
| `setup-env.sh` | Linux/macOS PATH configuration (auto-created) |
| `SETUP_GUIDE.md` | Detailed setup documentation |
| `QUICK_REFERENCE.md` | Common commands and troubleshooting |

---

## Support

For issues or questions:
1. Check the Troubleshooting section above
2. Review `SETUP_GUIDE.md` for detailed instructions
3. Check tool documentation:
   - Cardano CLI: https://github.com/IntersectMBO/cardano-cli
   - Cardano Addresses: https://github.com/IntersectMBO/cardano-addresses
   - Cardano Signer: https://github.com/gitmachtl/cardano-signer

---

## Version History

**v1.0 - 2024**
- Initial release
- Support for Windows, Linux, macOS
- Automatic tool download and setup
- GUI application launcher
- Environment configuration

---

**One script to rule them all!** 🚀
