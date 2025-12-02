# Cardano Community Admin Dashboard - WinUI 3

Professional Windows desktop application for administering Cardano community verification and member registry.

## Features

- 🔐 **Challenge Generation**: Create cryptographic challenges for member verification
- ✔️ **Signature Verification**: Server-side verification of user signatures
- 🔗 **On-Chain Verification**: Check stake information on Cardano blockchain
- 👥 **User Registry**: Maintain and query community member database
- 📋 **Report Export**: Export member data in JSON or CSV format
- 📊 **Statistics Dashboard**: Real-time registry statistics

## System Requirements

- Windows 10 (Build 21H2) or Windows 11
- .NET 8.0 SDK or Runtime
- Visual Studio 2022 (for development) or Windows App Runtime (for execution)

## Project Structure

```
community-admin-winui/
├── MainWindow.xaml          # Main UI (left sidebar + content area)
├── MainWindow.xaml.cs       # Event handlers and UI logic
├── App.xaml                 # Application entry point
├── App.xaml.cs              # Application lifecycle
├── Services/                # Business logic layer
│   ├── ChallengeService.cs           # Challenge generation & validation
│   ├── SignatureVerificationService.cs # Signature verification
│   ├── RegistryService.cs            # User registry management
│   └── OnChainService.cs             # Blockchain queries
├── Models/                  # Data models
│   └── ChallengeModels.cs   # Challenge, SignatureData, RegistryUser, etc.
├── Dialogs/                 # Modal dialogs (future)
└── Data/                    # Local data storage (future)
```

## Build & Run

### Build
```bash
cd community-admin-winui
dotnet restore
dotnet build
```

### Run
```bash
dotnet run
```

### Package
```bash
dotnet publish -c Release -r win-x64 --self-contained
```

## UI Layout

### Left Sidebar (280px)
- 5 main action buttons
- Real-time statistics display
- About section

### Right Content Area
- Dynamic title display
- Large output/results area
- Input fields for parameters
- Responsive grid layout

### Status Bar
- Real-time action status
- Current timestamp
- Version information

## Color Scheme

- **Primary Accent**: Cyan (#00FFFF)
- **Success**: Lime Green (#00FF00)
- **Action**: Dark Green (#1A7F4E)
- **Background**: Dark Gray (#1A1A1A, #0A0A0A)
- **Border**: Medium Gray (#404040)
- **Text**: White/Light Gray

## Service Architecture

### ChallengeService
- Generate signing challenges with nonce and expiry
- Validate challenge tokens
- Export challenges as JSON

### SignatureVerificationService
- Verify Ed25519 signatures
- Check challenge expiry and ID
- Return detailed verification results
- Export results as JSON

### RegistryService
- Register verified users
- Query user database
- Generate statistics
- Export registry as JSON/CSV
- Persist data to disk

### OnChainService
- Query Blockfrost API for stake information
- Validate stake address format
- Get community-wide stake distribution
- (Requires BLOCKFROST_API_KEY environment variable)

## Implementation Status

### ✅ Complete
- UI Layout and styling
- Event handlers and state management
- Service architecture
- Data models
- JSON serialization
- Registry persistence (async file I/O)

### 🟡 Partially Complete
- Input validation (basic checks implemented)
- Error handling (placeholders ready)

### ⏳ TODO
- Ed25519 signature verification (requires Chaos.NaCl)
- Blockfrost API integration (requires HTTP client setup)
- File dialogs for report export
- Progress indicators for long-running operations
- Detailed error messages and logging
- MVVM ViewModel pattern migration

## Dependencies

### Core
- Microsoft.WindowsAppSDK (1.4.240108002) - WinUI 3 framework
- CommunityToolkit.Mvvm (8.2.2) - MVVM support
- CommunityToolkit.WinUI (8.0.240109) - WinUI extensions

### Serialization
- System.Text.Json (8.0.0) - JSON handling
- System.Net.Http.Json (8.0.0) - HTTP+JSON

### Optional (commented out, ready to uncomment)
- Chaos.NaCl (2.2.1) - Ed25519 cryptography
- NBitcoin (7.8.12) - Bitcoin/Cardano utilities

## Environment Variables

Optional configuration:
```bash
# Blockfrost API key for on-chain queries
BLOCKFROST_API_KEY=your_api_key_here

# Registry storage path
REGISTRY_PATH=./data/user_registry.json
```

## License

Part of the Cardano Community Suite

## Related Projects

- `../end-user-app-winui/` - End-user signing application
- `../cardano-web-suite/` - Web-based services
- `../core-crypto/` - Cryptographic utilities
