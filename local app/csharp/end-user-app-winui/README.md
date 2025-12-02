# WinUI 3 Cardano End-User Tool

Modern Windows desktop application for Cardano wallet operations built with WinUI 3 and C#.

## Requirements

- Visual Studio 2022 or later
- Windows 10/11 with Windows App SDK installed
- .NET 8.0 SDK or later
- Windows Terminal (optional, for development)

## Project Structure

```
end-user-app-winui/
├── App.xaml                      # Application entry point
├── App.xaml.cs
├── MainWindow.xaml               # Main UI window
├── MainWindow.xaml.cs            # Main code-behind
├── Dialogs/                      # Dialog windows
│   ├── MessageSigningDialog.xaml
│   └── MessageSigningDialog.xaml.cs
├── Services/                     # Business logic
│   ├── KeygenService.cs
│   ├── SigningService.cs
│   ├── ExportService.cs
│   └── VerifyService.cs
└── CardanoEndUserTool.csproj     # Project file
```

## Features

- **🔑 Generate Keypair**: Create Cardano keypairs with BIP39 support
- **✍️ Sign Messages**: Sign messages offline or via wallet extensions
- **💾 Export Wallet**: Export wallet data for backup
- **✓ Verify Signatures**: Verify Ed25519 signatures

## Building

```bash
# Restore packages
dotnet restore

# Build
dotnet build

# Run
dotnet run
```

## Architecture

- **XAML UI**: Modern Windows 11 Fluent Design System
- **C# Backend**: Service-based architecture
- **Async/Await**: Non-blocking operations
- **MVVM Ready**: Community Toolkit MVVM support

## Supported Wallets

- Yoroi
- Nami
- Eternl
- Lace

## License

MIT License - Part of Cardano Community Suite
