# Development Guide - Community Admin WinUI 3

## Setup

### Prerequisites
- Windows 10 (21H2) or Windows 11
- Visual Studio 2022 (Community, Professional, or Enterprise)
- .NET 8.0 SDK
- Windows App SDK 1.4.240 (installed via VS or separately)

### Installation

1. **Install .NET 8.0 SDK**
   ```bash
   # Verify installation
   dotnet --version  # Should show 8.0.xxx
   ```

2. **Open in Visual Studio**
   ```bash
   cd community-admin-winui
   # Open CardanoCommunityAdmin.sln (or CardanoCommunityAdmin.csproj)
   ```

3. **Restore NuGet packages**
   ```bash
   dotnet restore
   ```

4. **Build**
   ```bash
   dotnet build
   ```

5. **Run**
   ```bash
   dotnet run
   ```

## Project Structure Explained

```
CardanoCommunityAdmin.csproj
├── PropertyGroup
│   ├── OutputType: WinExe (desktop application)
│   ├── TargetFramework: net8.0-windows10.0.22621.0
│   └── UseWindowsAppSDK: true (enables WinUI 3)
│
├── ItemGroup (PackageReferences)
│   ├── Microsoft.WindowsAppSDK (1.4.240108002)
│   ├── CommunityToolkit.Mvvm (8.2.2)
│   ├── CommunityToolkit.WinUI (8.0.240109)
│   └── System.Text.Json, System.Net.Http.Json
│
MainWindow.xaml (UI Definition - 300+ lines)
├── Grid: 2-column layout
│   ├── Left Column (280px): Sidebar with buttons
│   │   ├── BtnGenChallenge
│   │   ├── BtnVerifySignature
│   │   ├── BtnCheckOnChain
│   │   ├── BtnViewRegistry
│   │   ├── BtnExportReport
│   │   └── Statistics Section
│   │
│   └── Right Column: Content Area
│       ├── ContentTitle (dynamic)
│       ├── OutputContent (RichTextBlock for results)
│       ├── ActionPanel (input fields - hidden by default)
│       └── Status Bar (bottom)
│
MainWindow.xaml.cs (Code-behind - 200+ lines)
├── SetupWindow()
├── InitializeStatusBar()
├── Button Click Handlers
│   ├── BtnGenChallenge_Click()
│   ├── BtnVerifySignature_Click()
│   ├── BtnCheckOnChain_Click()
│   ├── BtnViewRegistry_Click()
│   └── BtnExportReport_Click()
├── Action Executors
│   ├── ExecuteGenerateChallenge()
│   ├── ExecuteVerifySignature()
│   ├── ExecuteCheckOnChain()
│   ├── ExecuteExportReport()
│   └── ExecuteAction_Click() [dispatcher]
└── UI Helpers
    ├── AddOutput() [colored text]
    └── UpdateStatus() [status bar]

Services/ (Business Logic)
├── ChallengeService.cs (80 lines)
│   ├── GenerateChallengeAsync()
│   ├── ValidateChallenge()
│   ├── ValidateChallengeId()
│   └── ExportChallengeAsJson()
│
├── SignatureVerificationService.cs (100 lines)
│   ├── VerifySignatureAsync() [TODO: Ed25519]
│   ├── GetVerificationResultAsync()
│   └── ExportResultAsJson()
│
├── RegistryService.cs (180 lines)
│   ├── RegisterVerifiedUserAsync()
│   ├── GetStatisticsAsync()
│   ├── GetAllUsersAsync()
│   ├── FindUserByWalletAsync()
│   ├── ExportAsJsonAsync()
│   └── ExportAsCsvAsync()
│
└── OnChainService.cs (70 lines)
    ├── CheckStakeAddressAsync() [TODO: Blockfrost API]
    ├── GetCommunityStakeDistributionAsync()
    └── ValidateStakeAddressFormat()

Models/ (Data Classes)
└── ChallengeModels.cs (150 lines)
    ├── SigningChallenge
    ├── SignatureData
    ├── RegistryUser
    ├── RegistryStatistics
    ├── OnChainStakeInfo
    └── ReportExport
```

## Implementation Workflow

### Phase 1: UI & Core Logic ✅ COMPLETE
1. ✅ Create XAML layout with Fluent Design
2. ✅ Implement event handlers in code-behind
3. ✅ Add color scheme and styling
4. ✅ Create data models
5. ✅ Set up service architecture

### Phase 2: Service Implementation 🟡 PARTIAL
1. ✅ ChallengeService - complete
2. 🟡 SignatureVerificationService - structure ready, Ed25519 pending
3. 🟡 RegistryService - complete with file I/O
4. 🟡 OnChainService - structure ready, API integration pending
5. ⏳ Input validation - basic checks only
6. ⏳ Error handling - placeholders implemented

### Phase 3: Advanced Features ⏳ TODO
1. Dialog system (file picker, input dialogs)
2. Progress indicators for async operations
3. Detailed logging and debugging
4. MVVM ViewModel migration
5. Data binding improvements
6. Unit tests

## Key Implementation Details

### Challenge Generation
```csharp
// From ChallengeService.GenerateChallengeAsync()
var challenge = new SigningChallenge
{
    ChallengeId = Guid.NewGuid().ToString(),
    CommunityId = "cardano-community",
    Nonce = Convert.ToBase64String(...),
    Timestamp = DateTimeOffset.Now.ToUnixTimeSeconds(),
    Message = $"I verify my membership for {communityId}",
    Expiry = timestamp + 3600  // 1 hour
};
```

### Registry Persistence
```csharp
// RegistryService uses async file I/O
private async Task SaveRegistryAsync()
{
    var json = JsonSerializer.Serialize(_userRegistry, indented: true);
    await File.WriteAllTextAsync(_registryPath, json);
}
```

### Output Display
```csharp
// MainWindow.xaml.cs: AddOutput() creates colored text
private void AddOutput(string text, string color = "#00FF00")
{
    var paragraph = new Paragraph();
    var run = new Run { Text = text };
    // Apply color based on parameter
    paragraph.Inlines.Add(run);
    OutputContent.Blocks.Add(paragraph);
}
```

## Next Steps (Priority Order)

### Priority 1: Cryptography Integration
- [ ] Uncomment `Chaos.NaCl` and `NBitcoin` in CardanoCommunityAdmin.csproj
- [ ] Run `dotnet restore` to fetch packages
- [ ] Implement `SignatureVerificationService.VerifySignatureAsync()`
  - Convert base64 strings to byte arrays
  - Use `Chaos.NaCl.CryptoSign.VerifyDetached()`
  - Return bool validation result

### Priority 2: On-Chain Integration
- [ ] Get Blockfrost API key from https://blockfrost.io
- [ ] Implement `OnChainService.CheckStakeAddressAsync()`
  - Create HttpClient with API key header
  - Call `/accounts/{stakeAddress}` endpoint
  - Parse response and populate OnChainStakeInfo
- [ ] Set environment variable: `BLOCKFROST_API_KEY=your_key`

### Priority 3: Input Validation
- [ ] Validate JSON input in SignatureData
- [ ] Validate stake address format
- [ ] Check community ID not empty
- [ ] Show user-friendly error messages

### Priority 4: UI Enhancements
- [ ] Add file picker dialog for export location
- [ ] Add progress indicator during async operations
- [ ] Implement detailed error notification UI
- [ ] Add spinner/loading animation
- [ ] Better output formatting

### Priority 5: Data Persistence
- [ ] Set registry storage path from config
- [ ] Create database abstraction layer
- [ ] Implement backup/restore functionality
- [ ] Add data encryption option

### Priority 6: MVVM Migration (Optional)
- [ ] Create ViewModels for each main function
- [ ] Implement INotifyPropertyChanged
- [ ] Convert event handlers to RelayCommand
- [ ] Use CommunityToolkit.Mvvm attributes
- [ ] Improve testability with dependency injection

## Testing

### Manual Testing Checklist

#### Challenge Generation
- [ ] Click "Generate Challenge"
- [ ] Leave Community ID as default or change it
- [ ] Optionally enter custom message
- [ ] Click "Execute Action"
- [ ] Verify challenge output contains: ID, nonce, timestamp, expiry
- [ ] Copy JSON output

#### Signature Verification
- [ ] Click "Verify Signature"
- [ ] Paste signature JSON in message field
- [ ] Click "Execute Action"
- [ ] Should show verification success/failure

#### On-Chain Check
- [ ] Click "Check On-Chain Stake"
- [ ] Enter valid Cardano stake address (starts with "stake1")
- [ ] Click "Execute Action"
- [ ] Should display stake amount, pool delegation, rewards

#### Registry View
- [ ] Click "View Registry"
- [ ] Should display current statistics (initially 0)
- [ ] After registering users, should update

#### Report Export
- [ ] Click "Export Report"
- [ ] Choose format: json or csv
- [ ] Click "Execute Action"
- [ ] Should show file path and record count

## Debugging

### Enable Verbose Logging
Edit `MainWindow.xaml.cs` and add:
```csharp
System.Diagnostics.Debug.WriteLine($"Debug: {message}");
```

### VS Code Debugging
- F5 to start with debugger
- Set breakpoints by clicking line numbers
- View local variables in Watch window
- Step through code with F10 (step over), F11 (step into)

### Console Output
```bash
# Show console window during debugging
dotnet run --no-restore
```

## Common Issues

### Issue: "Cannot find Windows App SDK"
**Solution**: Install Windows App SDK separately or via Visual Studio Installer

### Issue: "XAML designer not showing"
**Solution**: This is normal in VS Code. Designer works in Visual Studio.

### Issue: App crashes on launch
**Solution**: Check that .NET 8.0 is installed and Windows is 10.0.22621.0 or later

### Issue: "Type not found" errors
**Solution**: Run `dotnet restore` and rebuild

## Useful Commands

```bash
# Navigate to project
cd community-admin-winui

# Restore dependencies
dotnet restore

# Build for Debug
dotnet build

# Build for Release
dotnet build -c Release

# Run application
dotnet run

# Clean build artifacts
dotnet clean

# Format code
dotnet format

# Run tests (after adding test project)
dotnet test

# Publish standalone executable
dotnet publish -c Release -r win-x64 --self-contained
```

## References

- [WinUI 3 Documentation](https://learn.microsoft.com/windows/apps/winui/)
- [Windows App SDK](https://learn.microsoft.com/windows/apps/windows-app-sdk/)
- [XAML Basics](https://learn.microsoft.com/windows/apps/design/basics/)
- [CommunityToolkit.Mvvm](https://github.com/CommunityToolkit/dotnet)
- [System.Text.Json](https://learn.microsoft.com/dotnet/standard/serialization/system-text-json/)

## Architecture Pattern

### Current: Code-Behind Pattern
- Event handlers in MainWindow.xaml.cs
- Direct manipulation of UI elements
- Simple and straightforward

### Future: MVVM Pattern
- ViewModels separate from UI
- Binding instead of code-behind
- Better testability and reusability
- Using CommunityToolkit.Mvvm

## File Organization

```
CardanoCommunityAdmin/
├── App.xaml                         # Application root (styling, resources)
├── App.xaml.cs                      # Application lifecycle
├── MainWindow.xaml                  # Main UI (300+ lines)
├── MainWindow.xaml.cs               # Event handlers (200+ lines)
├── CardanoCommunityAdmin.csproj     # Project configuration
├── Services/
│   ├── ChallengeService.cs          # Challenge generation
│   ├── SignatureVerificationService.cs  # Signature verification
│   ├── RegistryService.cs           # User registry (180 lines, complete with file I/O)
│   └── OnChainService.cs            # Blockchain queries
├── Models/
│   └── ChallengeModels.cs           # Data models (6 classes)
├── Dialogs/                         # Modal dialogs (future)
├── Data/                            # Local storage (future)
├── README.md                        # User documentation
├── DEVELOPMENT.md                   # This file
└── .gitignore                       # Git exclusions
```

---

**Last Updated**: 2024-12-01  
**Status**: UI and architecture complete, implementation ready
