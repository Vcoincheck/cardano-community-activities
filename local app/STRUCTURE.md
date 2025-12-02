# 📁 Cardano Community Suite - Reorganized Structure

## Overview

The Cardano Community Suite has been reorganized by **programming language** for better clarity and maintainability.

```
cardano-community-suite/
├── 🔵 csharp/                    ← Modern C# / WinUI 3 Applications
│   ├── cardano-launcher-winui/   ← Main launcher (entry point)
│   ├── end-user-app-winui/       ← End-user tools
│   └── community-admin-winui/    ← Admin dashboard
│
├── 🟣 powershell/                ← Legacy PowerShell Scripts
│   ├── community-admin/          ← PowerShell admin GUI
│   ├── end-user-app/             ← PowerShell end-user GUI
│   ├── core-crypto/              ← Cryptographic utilities
│   ├── Launcher.ps1
│   ├── install-all.ps1
│   ├── run-admin-gui.ps1
│   └── run-end-user-gui.ps1
│
├── 🟡 tools/                     ← External tools & binaries
│   ├── cardano-cli-win64/
│   ├── cardano-address.exe
│   ├── cardano-signer.exe
│   └── install-all.sh
│
├── 📚 docs/                      ← Documentation
├── 🌐 web/                       ← Web applications (reserved)
│
└── Root Files:
    ├── setup.ps1                 ← One-click setup (all platforms)
    ├── setup.bat
    ├── setup.sh
    ├── README.md
    └── QUICK_START.md
```

## 🔵 csharp/ - Modern C# Applications (Production Ready)

| Project | Purpose | Status |
|---------|---------|--------|
| **cardano-launcher-winui** | Main entry point | ✅ Complete |
| **end-user-app-winui** | Keypair, signing, export | ✅ Complete |
| **community-admin-winui** | Verification, registry | ✅ Complete |

**Build & Run**:
```bash
cd csharp/cardano-launcher-winui
dotnet restore && dotnet build -c Release && dotnet run
```

**Tech**: .NET 8.0, WinUI 3, C# 12.0, MVVM

## 🟣 powershell/ - Legacy Scripts (Maintenance Mode)

PowerShell implementations for reference and legacy support.

**Run Legacy**:
```powershell
.\powershell\Launcher.ps1
```

## 🟡 tools/ - External Binaries

Third-party Cardano tools (cardano-cli, cardano-address, cardano-signer).

**Install** (Unix):
```bash
cd tools && bash install-all.sh
```

## �� docs/ - Documentation

- API_SPEC.md - Complete API reference
- SECURITY_MODEL.md - Security architecture  
- USER_FLOW_*.md - Workflow guides

## Quick Commands

```bash
# Setup all projects (ONE COMMAND)
./setup.ps1                 # Windows PowerShell
setup.bat                   # Windows CMD
./setup.sh                  # Linux/Mac

# Build specific project
cd csharp/cardano-launcher-winui
dotnet build -c Release

# Check folder structure
tree -L 2 -d

# View sizes
du -sh csharp powershell tools docs
```

## Migration Map

| Old | New | Type |
|-----|-----|------|
| cardano-launcher-winui/ | csharp/cardano-launcher-winui/ | C# |
| end-user-app-winui/ | csharp/end-user-app-winui/ | C# |
| community-admin-winui/ | csharp/community-admin-winui/ | C# |
| community-admin/ | powershell/community-admin/ | PowerShell |
| end-user-app/ | powershell/end-user-app/ | PowerShell |
| core-crypto/ | powershell/core-crypto/ | PowerShell |
| Launcher.ps1 | powershell/Launcher.ps1 | PowerShell |
| cardano-cli-win64/ | tools/cardano-cli-win64/ | Binary |

## Technology Stack

**csharp/**
- Runtime: .NET 8.0
- UI: WinUI 3
- Build: MSBuild / dotnet CLI
- Language: C# 12.0

**powershell/**
- Runtime: PowerShell 5.0+
- UI: Windows Forms
- Language: PowerShell

**tools/**
- Cardano CLI (native binary)
- Address tool (Go-based)
- Signer tool (native)

## Build Priority

1. ✅ **Priority 1**: C# WinUI 3 (production)
2. 🟡 **Priority 2**: PowerShell legacy (reference)
3. ⚪ **Priority 3**: External tools (third-party)

## Setup

### One-Command Setup (Recommended)

```powershell
# Windows PowerShell
.\setup.ps1

# Windows CMD
setup.bat

# Linux/Mac
./setup.sh
```

### Manual by Language

```bash
# Build all C#
cd csharp
for dir in */; do
  cd "$dir"
  dotnet restore && dotnet build -c Release
  cd ..
done

# Use PowerShell
cd powershell
.\Launcher.ps1
```

## Adding New Projects

**C# Project**: Create folder in `csharp/<name>/`
**PowerShell Script**: Create folder in `powershell/<name>/`
**Tool**: Add to `tools/`

## Support

- **Setup Issues**: See setup.ps1 output
- **Build Issues**: `dotnet clean && dotnet restore`
- **Execution**: `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned`

## Next Steps

1. Run setup: `./setup.ps1`
2. Read: `README.md`
3. Check: `docs/`
4. Launch: `CardanoLauncher.exe`
5. Learn: `docs/SECURITY_MODEL.md`

## FAQ

**Q: Which apps are production-ready?**
A: All C# WinUI 3 apps (csharp/ folder)

**Q: Should I use PowerShell apps?**
A: Use C# WinUI 3. PowerShell is legacy reference only.

**Q: How to build specific project?**
A: `cd csharp/<project> && dotnet build -c Release`

**Q: Where are compiled executables?**
A: `csharp/<project>/bin/Release/net8.0-windows.../`
