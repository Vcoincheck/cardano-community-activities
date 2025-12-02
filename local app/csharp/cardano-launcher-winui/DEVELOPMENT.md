# Cardano Launcher - Development Guide

## Project Overview

**CardanoLauncher** is the main entry point for the entire Cardano Community Suite. It provides a modern, visually appealing launcher interface that allows users to:

- Launch the End-User Tools application
- Launch the Admin Dashboard application  
- Access built-in documentation and resources
- Learn about the security model and features

## Technology Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| Framework | .NET 8.0 | Modern cross-platform runtime |
| UI Framework | WinUI 3 | Modern Windows UI with Fluent Design |
| Language | C# 12.0 | Type-safe object-oriented language |
| SDK | Windows App SDK 1.4.240108002 | Windows-specific features |
| MVVM | CommunityToolkit.Mvvm 8.2.2 | Optional: Model-View-ViewModel support |

## Project Structure

```
cardano-launcher-winui/
├── App.xaml                    - Application-level resources and initialization
├── App.xaml.cs                 - Application code-behind
├── MainWindow.xaml             - Main launcher UI (XAML markup)
├── MainWindow.xaml.cs          - Event handlers and business logic
├── CardanoLauncher.csproj      - Project configuration
├── nuget.config                - NuGet package sources
├── QUICK_START.md              - Quick start guide
└── DEVELOPMENT.md              - This file

```

## File Descriptions

### App.xaml (45 lines)
- **Purpose**: Defines application-level resources
- **Contents**:
  - Color resources for branding (CardanoPurple: #670883)
  - Merged Fluent Design dictionaries
  - Global resource definitions
- **Key Points**:
  - No resource-heavy content here (keep lightweight)
  - Colors defined for theme consistency
  - `XamlControlsResources` enables Fluent Design

### App.xaml.cs (28 lines)
- **Purpose**: Application initialization and lifecycle
- **Key Method**: `OnLaunched()`
  - Creates main window instance
  - Activates the window
- **Pattern**: Standard WinUI 3 initialization
- **Notes**: Single main window (no multiple window support needed)

### MainWindow.xaml (155 lines)
- **Purpose**: Main launcher UI layout
- **Structure**:
  ```
  Grid (main container)
  ├── Header Section
  │   ├── Title: "🔗 Cardano Community Suite"
  │   └── Subtitle: "Integrated Tools for End-Users & Administrators"
  ├── Main Content (3 Buttons)
  │   ├── End-User Tools Button
  │   ├── Admin Dashboard Button
  │   └── Documentation Button
  └── Footer Section
      └── Version and tagline
  ```
- **Button Design**:
  - Each button is 80 pixels tall
  - Contains icon (emoji), title, and description
  - 2-column layout (icon | content)
  - Stretches full width with consistent spacing
- **Theme**: Uses default theme resources for light/dark mode

### MainWindow.xaml.cs (182 lines)
- **Purpose**: Event handlers and application launching logic
- **Key Methods**:

#### `BtnEndUser_Click()`
```csharp
private void BtnEndUser_Click(object sender, RoutedEventArgs e)
{
    LaunchApplication("End-User Tools", "CardanoEndUserTool.exe");
}
```
- Triggered when user clicks End-User Tools button
- Calls generic launcher with app name and executable

#### `BtnAdmin_Click()`
```csharp
private void BtnAdmin_Click(object sender, RoutedEventArgs e)
{
    LaunchApplication("Admin Dashboard", "CardanoCommunityAdmin.exe");
}
```
- Triggered when user clicks Admin Dashboard button
- Calls generic launcher with app name and executable

#### `BtnDocs_Click()`
```csharp
private void BtnDocs_Click(object sender, RoutedEventArgs e)
{
    ShowDocumentation();
}
```
- Triggered when user clicks Documentation button
- Shows formatted help dialog with features, architecture, and resource links

#### `LaunchApplication(string appName, string exeName)` (40 lines)
- **Purpose**: Generic application launcher
- **Process**:
  1. Gets launcher directory path
  2. Searches multiple possible locations for executable
  3. Uses `Process.Start()` to launch if found
  4. Shows error dialog if executable not found
- **Search Paths** (in order):
  1. Parent directory
  2. Launcher directory
  3. `../end-user-app-winui/bin/Release/...`
  4. `../end-user-app-winui/bin/Debug/...`
  5. `../community-admin-winui/bin/Release/...`
  6. `../community-admin-winui/bin/Debug/...`
- **Error Handling**:
  - Catches `FileNotFoundException` if exe not found
  - Catches `Exception` for general launch errors
  - Shows user-friendly error messages

#### `ShowDocumentation()` (26 lines)
- **Purpose**: Display built-in documentation
- **Content Structure**:
  - Security features (6 bullet points)
  - End-user tools features (5 bullet points)
  - Admin dashboard features (5 bullet points)
  - Architecture principles (5 bullet points)
  - Project structure (5 directories)
- **Format**: Multi-line string with emojis and formatting

#### `ShowInformationDialog(string title, string message)` (5 lines)
- **Purpose**: Show information dialog wrapper
- **Delegates**: Calls `ShowDialog()` with ℹ️ icon

#### `ShowError(string title, string message)` (5 lines)
- **Purpose**: Show error dialog wrapper
- **Delegates**: Calls `ShowDialog()` with ❌ icon

#### `ShowDialog(string title, string message, string icon)` (15 lines)
- **Purpose**: Generic dialog display using ContentDialog
- **Features**:
  - Icon prefix in title
  - TextBlock with text wrapping
  - Text selection enabled
  - Async/await pattern
- **Styling**: Uses current XamlRoot for proper theme

## Build & Run

### Prerequisites
- Windows 10 Build 22621 or Windows 11
- .NET 8.0 SDK installed
- Visual Studio 2022 or Visual Studio Code with C# extension

### Build Steps

```bash
cd /workspaces/Guitool/cardano-community-suite/cardano-launcher-winui

# Restore NuGet packages
dotnet restore

# Build Debug version
dotnet build -c Debug

# Or build Release version
dotnet build -c Release

# Run directly
dotnet run

# Or run executable
./bin/Debug/net8.0-windows10.0.22621.0/CardanoLauncher.exe
```

### Build Output
```
bin/
├── Debug/
│   └── net8.0-windows10.0.22621.0/
│       ├── CardanoLauncher.exe       ← Main executable
│       ├── CardanoLauncher.dll
│       ├── CardanoLauncher.runtimeconfig.json
│       └── [dependencies]
└── Release/
    └── net8.0-windows10.0.22621.0/
        ├── CardanoLauncher.exe
        └── [dependencies]
```

## Architecture Patterns

### Application Lifecycle
```
1. User double-clicks CardanoLauncher.exe
   ↓
2. App.xaml loads (resources initialized)
   ↓
3. App.xaml.cs OnLaunched() executes
   ↓
4. MainWindow created and activated
   ↓
5. User clicks button
   ↓
6. Event handler launches child application
```

### Process Launching
```
User Click
    ↓
Event Handler (BtnEndUser_Click)
    ↓
LaunchApplication()
    ↓
Search for executable
    ↓
ProcessStartInfo configured
    ↓
Process.Start() launches app
    ↓
Error handling if not found
    ↓
Child application runs independently
```

### Error Handling Strategy
```
Try Block
├── Find executable path
├── Launch process
└── Catch exceptions
    ├── FileNotFoundException → "Not found" error
    ├── Exception → "Launch error" message
    └── Show dialog with path list for debugging
```

## Customization Guide

### Add a New Button

1. **In MainWindow.xaml**, add to the StackPanel:
```xaml
<Button
    x:Name="BtnNewApp"
    Click="BtnNewApp_Click"
    Height="80"
    HorizontalAlignment="Stretch">
    <Grid ColumnSpacing="16">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="Auto" />
            <ColumnDefinition Width="*" />
        </Grid.ColumnDefinitions>
        <TextBlock Grid.Column="0" Text="🆕" FontSize="36" />
        <StackPanel Grid.Column="1" Spacing="4">
            <TextBlock Text="New Application" FontSize="16" FontWeight="SemiBold" />
            <TextBlock Text="Description here" FontSize="12" Foreground="{ThemeResource TextFillColorSecondaryBrush}" />
        </StackPanel>
    </Grid>
</Button>
```

2. **In MainWindow.xaml.cs**, add event handler:
```csharp
private void BtnNewApp_Click(object sender, RoutedEventArgs e)
{
    LaunchApplication("New Application", "NewApp.exe");
}
```

### Change Colors

Edit `App.xaml`:
```xaml
<Color x:Key="CardanoPurple">#670883</Color>  ← Change hex code
```

Use in XAML:
```xaml
<TextBlock Foreground="#670883" Text="..." />
```

### Modify Header Text

Edit `MainWindow.xaml`:
```xaml
<TextBlock Text="Your Title Here" FontSize="36" FontWeight="Bold" />
```

## Dependencies

### NuGet Packages
- **Microsoft.WindowsAppSDK** (1.4.240108002)
  - Purpose: WinUI 3 framework and Windows features
  - Provides: XAML rendering, controls, themes
  
- **Microsoft.Windows.SDK.BuildTools** (10.0.22621.756)
  - Purpose: Windows SDK build tools
  - Provides: WinRT interop, metadata

- **CommunityToolkit.Mvvm** (8.2.2)
  - Purpose: MVVM support (optional, not used in current version)
  - Provides: ObservableObject, RelayCommand, etc.

## Performance Considerations

### Current Implementation
- **Launch Time**: ~500ms (depends on OS and disk)
- **Memory Usage**: ~50-80 MB (WinUI 3 framework)
- **UI Responsiveness**: Immediate (no blocking operations)

### Optimization Opportunities
- Pre-cache child application paths
- Lazy load documentation (load on button click)
- Add loading indicator during app launch
- Implement Recent Apps history

## Known Limitations

1. **Single Window**: Launcher closes if window closed (by design)
2. **No Window Management**: Cannot bring child app to front if already running
3. **Simple Process Launch**: Uses standard Windows `Process.Start()`
4. **No Inter-Process Communication**: Child apps run independently

## Future Enhancements

### Short-term (1-2 days)
- [ ] Add Recent Apps functionality
- [ ] Implement Recent Apps registry
- [ ] Add loading indicator during launch
- [ ] Remember window position/size

### Medium-term (1-2 weeks)
- [ ] Add Settings page (theme, language)
- [ ] Implement app update checker
- [ ] Add drag-and-drop file support
- [ ] Create system tray integration

### Long-term (1+ month)
- [ ] Inter-process communication (IPC)
- [ ] App plugin system
- [ ] Marketplace for community apps
- [ ] Self-updating launcher mechanism

## Testing Checklist

- [ ] Build succeeds without errors
- [ ] Launcher window displays correctly
- [ ] All 3 buttons have proper styling
- [ ] Click End-User Tools button → launches CardanoEndUserTool.exe
- [ ] Click Admin Dashboard button → launches CardanoCommunityAdmin.exe
- [ ] Click Documentation button → shows help dialog
- [ ] Error handling works (simulate missing exe)
- [ ] Documentation dialog displays all content
- [ ] Window resizing works correctly
- [ ] Light/dark theme switching works

## Troubleshooting

### Issue: "exe not found" error
**Solution**: 
1. Verify child applications are built
2. Check build output paths match search paths
3. Ensure executables have correct names (CardanoEndUserTool.exe, CardanoCommunityAdmin.exe)

### Issue: Window doesn't display
**Solution**:
1. Check Windows 10 version (requires Build 22621+)
2. Verify .NET 8.0 SDK is installed
3. Try `dotnet build --verbose` for detailed errors

### Issue: Child app doesn't launch
**Solution**:
1. Manually verify .exe exists at expected path
2. Check if .exe requires dependencies
3. Try running child app directly to check if it works
4. Check for antivirus interference

## Resources

- [WinUI 3 Documentation](https://docs.microsoft.com/winui/)
- [.NET 8.0 Documentation](https://docs.microsoft.com/dotnet/)
- [Windows App SDK](https://docs.microsoft.com/windows/apps/windows-app-sdk/)
- [XAML Fundamentals](https://docs.microsoft.com/windows/uwp/xaml-platform/xaml-overview)
