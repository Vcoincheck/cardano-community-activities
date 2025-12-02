# WinUI 3 GUI Development Setup

## Installation & Build

### Prerequisites
- Visual Studio 2022 Community/Professional
- Windows 10/11 (21H2+)
- .NET 8.0 SDK
- Windows App SDK (included in VS)

### Steps

1. **Clone and Navigate**
```bash
cd cardano-community-suite/end-user-app-winui
```

2. **Restore Dependencies**
```bash
dotnet restore
```

3. **Build Project**
```bash
dotnet build
```

4. **Run Application**
```bash
dotnet run
```

## Project Structure

### MainWindow
- **XAML**: Modern fluent design with Mica backdrop
- **Code-behind**: Event handlers for buttons
- **Layout**: 
  - Left sidebar: Navigation buttons
  - Right area: Content display with output
  - Status bar: Real-time status updates

### Dialogs
- **MessageSigningDialog**: Multi-option dialog for sign method selection
- Supports signing offline or via wallet

### Services
- **KeygenService**: BIP39 mnemonic and key generation
- **SigningService**: Message signing (offline & wallet)
- **ExportService**: Wallet data export/import
- **VerifyService**: Signature verification

## UI Features

- ✅ Modern Windows 11 Fluent Design
- ✅ Dark theme (Mica backdrop)
- ✅ Responsive layout
- ✅ Real-time status updates
- ✅ Rich text output display
- ✅ Content dialogs for input

## Architecture

```
App.xaml
├── MainWindow (UI + handlers)
├── Services (Business logic)
│   ├── KeygenService
│   ├── SigningService
│   ├── ExportService
│   └── VerifyService
└── Dialogs
    └── MessageSigningDialog
```

## Implementation Status

| Feature | Status | Notes |
|---------|--------|-------|
| UI Layout | ✅ Complete | Modern WinUI 3 design |
| Keygen | 🟡 Partial | Service skeleton ready |
| Sign Offline | 🟡 Partial | Needs crypto lib |
| Sign via Wallet | 🟡 Partial | Needs browser comm |
| Export | 🟡 Partial | JSON export ready |
| Verify | 🟡 Partial | Service skeleton ready |

## Next Steps

1. Implement cryptography operations (Ed25519)
2. Add wallet browser communication
3. Implement BIP39 mnemonic generation
4. Add file picker dialogs
5. Implement encryption for exports
6. Add progress indicators
7. Implement error handling UI
8. Add logging/debugging features

## Dependencies to Add

```xml
<!-- For Ed25519 signatures -->
<PackageReference Include="Chaos.NaCl" Version="2.2.1" />

<!-- For BIP39 mnemonics -->
<PackageReference Include="NBitcoin" Version="7.8.12" />

<!-- For AES encryption -->
<PackageReference Include="System.Security.Cryptography.Algorithms" Version="4.3.1" />

<!-- For HTTP communication with wallets -->
<PackageReference Include="System.Net.Http.Json" Version="8.0.0" />
```

## References

- [WinUI 3 Documentation](https://learn.microsoft.com/en-us/windows/apps/winui/winui3/)
- [Windows App SDK](https://learn.microsoft.com/en-us/windows/apps/windows-app-sdk/)
- [Cardano Documentation](https://developers.cardano.org/)
