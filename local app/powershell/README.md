# 🟣 PowerShell Legacy Implementation

Legacy PowerShell-based implementation for reference and backward compatibility.

**Status**: Maintenance only - Use C# WinUI 3 apps for production.

## Projects

### community-admin/
**Purpose**: PowerShell admin GUI (legacy)

Original implementation of admin dashboard before C# rewrite.

### end-user-app/
**Purpose**: PowerShell end-user GUI (legacy)

Original implementation of end-user tools before C# rewrite.

### core-crypto/
**Purpose**: Cryptographic utilities

Cryptographic helper scripts for signing and verification.

### Launcher.ps1
**Purpose**: Main PowerShell entry point

Central launcher script (legacy version).

**Run**:
```powershell
.\Launcher.ps1
```

## Running Legacy Apps

### Enable Execution Policy

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Run Launcher

```powershell
cd powershell
.\Launcher.ps1
```

## Scripts

### install-all.ps1
Installation script for legacy setup.

```powershell
.\install-all.ps1
```

### run-admin-gui.ps1
Directly run admin GUI.

```powershell
.\run-admin-gui.ps1
```

### run-end-user-gui.ps1
Directly run end-user GUI.

```powershell
.\run-end-user-gui.ps1
```

## Technology

- **Language**: PowerShell 5.0+
- **UI Framework**: Windows Forms
- **Runtime**: .NET Framework
- **Cryptography**: Cardano CLI tools

## Important Notes

⚠️ **These are legacy implementations**

- Use **C# WinUI 3** apps for production
- PowerShell versions are for reference only
- No active maintenance or feature development

## Migration Path

To migrate to C# WinUI 3:

1. Use `../csharp/cardano-launcher-winui/` as entry point
2. Use `../csharp/end-user-app-winui/` for user tools
3. Use `../csharp/community-admin-winui/` for admin features

## Troubleshooting

### Script Execution Issues

```powershell
# Check execution policy
Get-ExecutionPolicy

# Set to allow script execution
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Module Load Errors

```powershell
# Force module reload
Remove-Module -Name ModuleName -Force
Import-Module .\path\to\module.ps1
```

## Related

- Modern C# implementation: `../csharp/`
- Documentation: `../docs/`
- External tools: `../tools/`
