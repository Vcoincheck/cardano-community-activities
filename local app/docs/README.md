# Cardano Community Suite - README

## 🔗 Overview

**Cardano Community Suite** is a comprehensive, PowerShell-based multi-purpose toolkit for Cardano community management and wallet operations.

### Features
✅ **End-User Tools**
- Generate Cardano keypairs
- Sign messages offline
- Export wallet data
- Verify signatures locally

✅ **Admin Dashboard**
- Generate signing challenges
- Verify user signatures
- Check on-chain stake
- Manage user registry
- Export reports

✅ **Security-First**
- Offline signing (private keys never transmitted)
- Ed25519 cryptography
- Challenge-response authentication
- On-chain verification support

## 🚀 Quick Start

### Prerequisites
- PowerShell 5.1+ (Windows 10/11)
- cardano-cli and cardano-signer executables
- .NET Framework 4.7.2+

### Installation
```bash
# Clone repository
git clone https://github.com/your-org/cardano-community-suite.git
cd cardano-community-suite

# Copy executables
cp /path/to/cardano-cli.exe .
cp /path/to/cardano-signer.exe .

# Launch
.\Launcher.ps1
```

### First Run

#### As End-User
1. Click "👤 End-User Tools"
2. Generate keypair → saves keys to `./keys/`
3. Sign message → uses private key for signing
4. Verify signature → checks before submitting

#### As Admin
1. Click "👨‍💼 Admin Dashboard"
2. Generate challenge → creates unique verification request
3. Verify signature → server-side validation
4. Check stake → optional on-chain verification
5. Manage registry → track community members

## 📁 Directory Structure

```
cardano-community-suite/
├── Launcher.ps1                    # Main entry point
├── end-user-app/
│   ├── EndUserGUI.ps1            # GUI for end-users
│   └── modules/
│       ├── Keygen.ps1            # Generate keypairs
│       ├── SignOffline.ps1       # Sign messages
│       ├── ExportWallet.ps1      # Export wallet
│       └── VerifyLocal.ps1       # Local verification
├── community-admin/
│   ├── AdminGUI.ps1              # Admin dashboard
│   ├── modules/
│   │   ├── GenerateChallenge.ps1 # Create challenges
│   │   ├── VerifySignature.ps1   # Verify signatures
│   │   ├── VerifyOnchain.ps1     # Check on-chain
│   │   ├── UserRegistry.ps1      # User management
│   │   └── ExportReports.ps1     # Generate reports
│   ├── data/
│   │   └── user_registry.json    # User database
│   └── scripts/
│       ├── verify_stake.sh       # Batch verification
│       └── batch_verify.py       # Bulk operations
├── core-crypto/
│   ├── VerifySignature.ps1       # Ed25519 verification
│   ├── DeriveStake.ps1           # Derive stake address
│   ├── MessageFormat.json        # Message schema
│   └── SignatureFormat.json      # Signature schema
└── docs/
    ├── USER_FLOW_ENDUSER.md      # End-user guide
    ├── USER_FLOW_ADMIN.md        # Admin guide
    ├── API_SPEC.md               # API reference
    ├── SECURITY_MODEL.md         # Security details
    └── README.md                 # This file
```

## 🔐 Security

### Private Key Management
- **Never transmit** private keys over network
- **Offline signing** recommended for sensitive operations
- **Air-gapped computer** for critical keys
- **Hardware wallets** for maximum security

### Signature Verification
- Client-side: Verify before submitting
- Server-side: Always verify on admin side
- Challenge expiry: Prevents old challenge replay
- Nonce validation: One-time use per challenge

### On-Chain Verification
- Optional stake balance check
- Uses public Koios API
- No private data exposed
- Rate-limited for performance

See [SECURITY_MODEL.md](docs/SECURITY_MODEL.md) for full security details.

## 📖 Documentation

- **[USER_FLOW_ENDUSER.md](docs/USER_FLOW_ENDUSER.md)** - End-user workflow and guide
- **[USER_FLOW_ADMIN.md](docs/USER_FLOW_ADMIN.md)** - Admin workflow and management
- **[API_SPEC.md](docs/API_SPEC.md)** - Complete API reference
- **[SECURITY_MODEL.md](docs/SECURITY_MODEL.md)** - Security architecture and best practices

## 🛠️ Development

### Adding New Modules
1. Create `.ps1` file in appropriate directory
2. Implement functions with consistent naming
3. Export functions using `Export-ModuleMember`
4. Add documentation

### Example Module
```powershell
# MyModule.ps1
function Do-Something {
    param([string]$Input)
    Write-Host "Processing: $Input" -ForegroundColor Yellow
    # Implementation
    return $result
}

Export-ModuleMember -Function Do-Something
```

## 🤝 Contributing

1. Fork repository
2. Create feature branch
3. Implement changes
4. Add tests
5. Submit pull request

## 📝 License

MIT License - See LICENSE file

## 🙋 Support

- Issues: GitHub Issues
- Discussions: GitHub Discussions
- Email: support@example.com

## 🎯 Roadmap

### Phase 1 (Current)
- ✅ Core PowerShell modules
- ✅ End-user GUI
- ✅ Admin dashboard
- ✅ Basic documentation

### Phase 2
- 🔄 Web interface (optional)
- 🔄 API server (FastAPI/Flask)
- 🔄 Mobile app (React Native)
- 🔄 Hardware wallet integration

### Phase 3
- ⏳ Multi-language support
- ⏳ Advanced reporting
- ⏳ Community plugins
- ⏳ Blockchain integration

## 👥 Credits

Built for the Cardano community by developers, for developers.

**Special thanks to:**
- Cardano Foundation
- Community contributors
- IOG (Input Output Global)
