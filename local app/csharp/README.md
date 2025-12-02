# 🔵 C# WinUI 3 Applications

Modern, production-ready desktop applications built with .NET 8.0 and WinUI 3.

## Projects

### 1. cardano-launcher-winui
**Purpose**: Main entry point and application launcher

- Launch End-User Tools
- Launch Admin Dashboard
- Access documentation
- Professional Fluent Design UI

**Build**:
```bash
cd cardano-launcher-winui
dotnet restore && dotnet build -c Release
```

**Run**:
```bash
dotnet run
```

### 2. end-user-app-winui
**Purpose**: End-user cryptocurrency tools

**Features**:
- Generate Cardano keypairs
- Sign messages offline
- Export wallet data
- Verify signatures locally

**Build**:
```bash
cd end-user-app-winui
dotnet restore && dotnet build -c Release
```

### 3. community-admin-winui
**Purpose**: Administrative dashboard for community verification

**Features**:
- Generate signing challenges
- Verify user signatures
- Check on-chain stakes
- Manage user registry
- Export reports (JSON/CSV)

**Build**:
```bash
cd community-admin-winui
dotnet restore && dotnet build -c Release
```

## Technology Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| .NET | 8.0 | Runtime |
| WinUI | 3 (1.4.240108002) | UI Framework |
| C# | 12.0 | Language |
| MVVM Toolkit | 8.2.2 | Architecture |
| System.Text.Json | Built-in | Serialization |

## Project Structure

```
cardano-launcher-winui/
├── App.xaml / .xaml.cs      ← Application initialization
├── MainWindow.xaml / .xaml.cs ← Main UI & event handlers
├── CardanoLauncher.csproj   ← Project configuration
├── nuget.config             ← Package sources
└── Docs/                    ← Documentation

Similar structure for other projects...
```

## Build Instructions

### Prerequisites

- Windows 10 Build 22621 or Windows 11
- .NET 8.0 SDK
- Visual Studio 2022 or VS Code with C# extension

### Build All Projects

```bash
# From csharp/ directory
cd cardano-launcher-winui && dotnet build -c Release && cd ..
cd end-user-app-winui && dotnet build -c Release && cd ..
cd community-admin-winui && dotnet build -c Release
```

### Or use the root setup script

```bash
# From cardano-community-suite root
./setup.ps1           # PowerShell
setup.bat             # Command Prompt
./setup.sh            # Linux/Mac
```

## Output Executables

After building, find executables at:

```
cardano-launcher-winui/bin/Release/net8.0-windows10.0.22621.0/CardanoLauncher.exe
end-user-app-winui/bin/Release/net8.0-windows10.0.22621.0/CardanoEndUserTool.exe
community-admin-winui/bin/Release/net8.0-windows10.0.22621.0/CardanoCommunityAdmin.exe
```

## Development

### Adding New Features

1. **Add Service**: Create in `Services/`
2. **Add Model**: Create in `Models/` (if needed)
3. **Update UI**: Modify `.xaml` file
4. **Add Handler**: Implement in `.xaml.cs`

### Code Style

- Use nullable reference types (enabled)
- Follow async/await patterns
- Implement INotifyPropertyChanged for MVVM
- Use System.Text.Json for serialization

### Testing

```bash
# Build in Debug mode
dotnet build -c Debug

# Run with verbose output
dotnet build -v diagnostic

# Check for errors
dotnet build --no-restore
```

## Dependencies

### Required NuGet Packages

```xml
<PackageReference Include="Microsoft.WindowsAppSDK" Version="1.4.240108002" />
<PackageReference Include="CommunityToolkit.Mvvm" Version="8.2.2" />
<PackageReference Include="Microsoft.Windows.SDK.BuildTools" Version="10.0.22621.756" />
```

## Deployment

### Self-Contained Deployment

```bash
dotnet publish -c Release --self-contained
```

### Create Installer

1. Use MSIX Packaging Tool
2. Or distribute as standalone .exe files

### System Requirements

**Minimum**:
- Windows 10 Build 22621
- .NET 8.0 Runtime (or included in self-contained build)
- 100 MB disk space

**Recommended**:
- Windows 11
- .NET 8.0 SDK (for development)
- 500 MB disk space

## Troubleshooting

### Build Errors

```bash
# Clean and rebuild
dotnet clean
dotnet restore
dotnet build -c Release

# Verbose output for debugging
dotnet build -v diagnostic
```

### Runtime Errors

- Check Windows version (must be 22621+)
- Verify .NET 8.0 is installed: `dotnet --version`
- Check disk space: `df -h` or `Get-Volume`

### Missing Dependencies

```bash
# Restore packages
dotnet restore

# Check for conflicts
dotnet list package --outdated
```

## Documentation

- See individual project QUICK_START.md files
- Check DEVELOPMENT.md for architectural details
- Read IMPLEMENTATION_SUMMARY.md for project status

## Performance

| Metric | Value |
|--------|-------|
| Launch Time | ~300-500ms |
| Memory Usage | 50-80 MB |
| Executable Size | 60-80 MB (self-contained) |
| Build Time | 30-60 seconds |

## Next Steps

1. **Build**: `dotnet restore && dotnet build -c Release`
2. **Run**: `dotnet run` or execute .exe directly
3. **Deploy**: Copy .exe to Windows machine
4. **Use**: Launch Cardano Launcher and explore features

## Support

- **Setup Issues**: See setup.ps1 output
- **Build Issues**: Run `dotnet clean` then rebuild
- **Runtime Issues**: Check Windows version and .NET SDK

## Related

- PowerShell legacy versions: `../powershell/`
- Documentation: `../docs/`
- External tools: `../tools/`
