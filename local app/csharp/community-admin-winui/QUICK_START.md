# Quick Start Guide - Community Admin WinUI 3

## 30-Second Setup

```bash
cd cardano-community-suite/community-admin-winui
dotnet restore
dotnet build
dotnet run
```

## What You'll See

A modern Windows 11 desktop application with:
- Left sidebar with 5 action buttons
- Right content area with results
- Status bar with timestamp
- Real-time statistics

## First Actions to Try

### 1. Generate Challenge
1. Click **"Generate Challenge"** button
2. Leave Community ID as default or change it
3. Optionally enter custom message
4. Click **"Execute Action"**
5. See generated challenge with ID, nonce, expiry

### 2. View Registry
1. Click **"View Registry"** button
2. See current member count and stats
3. (No members yet if first run)

### 3. Export Report
1. Click **"Export Report"** button
2. Type "json" or "csv" in message field
3. Click **"Execute Action"**
4. See exported file path

## File Structure Reference

```
community-admin-winui/
├── MainWindow.xaml          ← UI Layout (what you see)
├── MainWindow.xaml.cs       ← Button handlers
├── Services/                ← Business logic
│   ├── ChallengeService.cs
│   ├── SignatureVerificationService.cs
│   ├── RegistryService.cs
│   └── OnChainService.cs
├── Models/ChallengeModels.cs ← Data classes
├── README.md                ← User guide
└── DEVELOPMENT.md           ← Developer guide
```

## Key Services Explained

### ChallengeService
```csharp
// Generate a signing challenge
var challenge = await challengeService.GenerateChallengeAsync(
    communityId: "cardano-community",
    action: "verify_membership"
);
// Returns: Challenge with ID, nonce, timestamp, expiry
```

### RegistryService
```csharp
// Register a verified user
var user = await registryService.RegisterVerifiedUserAsync(
    walletAddress: "addr1...",
    stakeAddress: "stake1...",
    challengeId: "...",
    communityId: "cardano-community"
);
// Automatically saves to data/user_registry.json
```

### SignatureVerificationService
```csharp
// Verify a signature
var isValid = await verificationService.VerifySignatureAsync(
    challenge,
    signatureData
);
// Returns: bool (true if valid)
```

### OnChainService
```csharp
// Check stake on blockchain
var stakeInfo = await onChainService.CheckStakeAddressAsync(
    stakeAddress: "stake1..."
);
// Returns: StakeAmount, DelegatedPool, Rewards
```

## Configuration

### Environment Variables (Optional)
```bash
# API key for blockchain queries
export BLOCKFROST_API_KEY=your_key_here

# Custom registry storage location
export REGISTRY_PATH=/path/to/registry.json
```

### Application Settings
Edit `MainWindow.xaml.cs` to customize:
- Default community ID
- Color scheme
- Button behaviors
- Output formatting

## Building for Distribution

### Self-Contained Executable
```bash
dotnet publish -c Release -r win-x64 --self-contained
```

Output: `bin/Release/net8.0-windows.../win-x64/publish/CommunityAdmin.exe`

Size: ~150 MB (includes .NET runtime)

### Installer (Optional)
Use Windows Installer XML (WiX) toolset:
```bash
# Create .msi installer from published files
```

## Troubleshooting

### "Cannot find Windows App SDK"
```bash
# Install Windows App SDK
winget install Microsoft.WindowsAppSDK

# Or from Visual Studio Installer
```

### "XAML Parser Error"
```bash
# Clean and rebuild
dotnet clean
dotnet restore
dotnet build
```

### "Registry file not found"
The app creates `data/user_registry.json` on first run.
If missing:
```bash
mkdir data
dotnet run
```

### Application crashes on startup
Verify .NET 8.0:
```bash
dotnet --version  # Should show 8.0.x
dotnet --info     # Check Windows SDK version
```

## Development Tips

### Hot Reload (Edit & Continue)
In Visual Studio:
- Edit XAML → Changes appear immediately
- Edit C# → Rebuild required (Ctrl+Shift+B)

### Debugging
- **F5** - Start with debugger
- **F9** - Toggle breakpoint
- **F10** - Step over
- **F11** - Step into
- **Shift+F5** - Stop debugging

### View Output
```bash
# See debug output
dotnet run --configuration Debug

# See release output  
dotnet run --configuration Release
```

## Next Steps

1. ✅ **Get it running** ← You are here
2. 📖 **Read DEVELOPMENT.md** for architecture details
3. 🔧 **Implement services** - Start with ChallengeService
4. 🧪 **Add tests** - Create unit test project
5. 📦 **Create installer** - Package for distribution

## Important Files

| File | Purpose | When to Edit |
|------|---------|--------------|
| `MainWindow.xaml` | UI Layout | Changing appearance |
| `MainWindow.xaml.cs` | Button logic | Changing behavior |
| `Services/*.cs` | Business logic | Implementing features |
| `Models/ChallengeModels.cs` | Data structures | Changing data format |
| `README.md` | User docs | When users need help |
| `DEVELOPMENT.md` | Dev docs | When developers need help |

## Common Tasks

### Add a new button
1. Edit `MainWindow.xaml` - add Button control
2. Edit `MainWindow.xaml.cs` - add event handler
3. Add logic in new method

### Change colors
Edit `MainWindow.xaml`:
```xml
<Button Background="#1A7F4E" />  <!-- Change this color -->
```

### Add a new service
1. Create `Services/NewService.cs`
2. Add namespace: `using CommunityAdmin.Services;`
3. Instantiate in `MainWindow.xaml.cs`
4. Call from button handler

### Export data
See `Services/RegistryService.cs`:
```csharp
var report = await registryService.ExportAsJsonAsync();
var report = await registryService.ExportAsCsvAsync();
```

## Performance Tips

- Async all I/O operations
- Use `Task.Run()` for CPU-bound work
- Don't block the UI thread
- Cache results when possible
- Use pagination for large datasets

## Security Considerations

- ✅ Validate all user input
- ✅ Sanitize file paths
- ✅ Use secure JSON deserialization
- ✅ Hash sensitive data
- ✅ Use HTTPS for API calls (Blockfrost)

## Support Resources

- [WinUI 3 Documentation](https://learn.microsoft.com/windows/apps/winui/)
- [C# Async/Await](https://learn.microsoft.com/dotnet/csharp/asynchronous-programming/)
- [System.Text.Json](https://learn.microsoft.com/dotnet/standard/serialization/system-text-json/)
- [Git Tips](https://github.com)

---

**Next**: Read `DEVELOPMENT.md` for detailed architecture and implementation guide.
