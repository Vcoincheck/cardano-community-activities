# 🚀 Cardano Launcher - Quick Start

## Build & Run (30 seconds)

```bash
cd /workspaces/Guitool/cardano-community-suite/cardano-launcher-winui
dotnet restore
dotnet build -c Debug
dotnet run
```

## Architecture

```
cardano-launcher-winui/
├── App.xaml              - Application entry point & resources
├── App.xaml.cs           - App initialization
├── MainWindow.xaml       - Launcher UI with 3 buttons
├── MainWindow.xaml.cs    - Click handlers & app launching logic
├── nuget.config          - NuGet package source configuration
└── CardanoLauncher.csproj - Project file with dependencies
```

## Features

✅ **Beautiful UI** - Fluent Design System with WinUI 3  
✅ **Application Launcher** - Starts End-User and Admin apps  
✅ **Documentation Access** - Built-in help and resources  
✅ **Error Handling** - Graceful error messages and fallbacks  

## Project File Details

- **Framework**: .NET 8.0 for Windows 10 (Build 22621)
- **Dependencies**: 
  - Microsoft.WindowsAppSDK 1.4.240108002
  - CommunityToolkit.Mvvm 8.2.2
- **Target**: Windows 10 (Build 22621) or Windows 11
- **Package**: Self-contained executable

## How It Works

1. **User launches CardanoLauncher.exe**
2. **Main window displays with 3 buttons**:
   - 👤 End-User Tools → Launches CardanoEndUserTool.exe
   - 👨‍💼 Admin Dashboard → Launches CardanoCommunityAdmin.exe
   - 📖 Documentation → Shows built-in help
3. **Child applications run independently**
4. **Launcher stays open for switching between apps**

## Build Locations

Built executables will be placed in:

```
bin/Debug/net8.0-windows10.0.22621.0/
└── CardanoLauncher.exe
```

## Dependencies Resolution

The launcher automatically searches for child applications in:
1. Same directory as launcher
2. Parent directory
3. `../end-user-app-winui/bin/[Config]/net8.0-windows10.0.22621.0/`
4. `../community-admin-winui/bin/[Config]/net8.0-windows10.0.22621.0/`

## Development

### Adding New Applications

To add a new application to the launcher:

1. Add a button in `MainWindow.xaml`
2. Add click handler in `MainWindow.xaml.cs`
3. Update `LaunchApplication()` method if needed
4. Build and test

### Customization

Edit `MainWindow.xaml` to:
- Change button colors via `Button.Background`
- Add new sections via `StackPanel`
- Modify footer text
- Add icons and descriptions

## Next Steps

1. Build end-user-app-winui and community-admin-winui
2. Verify executables are in expected locations
3. Test launcher by clicking each button
4. Verify child applications start correctly
