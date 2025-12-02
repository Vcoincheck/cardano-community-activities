# Cardano Community Suite - Master README

## 🎯 Project Overview

**Cardano Community Suite** is a complete, production-ready PowerShell toolkit for:
- ✅ Individual users to manage Cardano wallets and sign messages offline
- ✅ Community administrators to verify members and manage registries
- ✅ Organizations to create verifiable audit trails of membership

Built entirely in **PowerShell** with no external dependencies except Cardano CLI tools.

---

## 🚀 Quick Links

| Resource | Purpose |
|----------|---------|
| **[QUICK_START.md](QUICK_START.md)** | Get running in 5 minutes |
| **[STRUCTURE.md](STRUCTURE.md)** | Understand folder organization |
| **[docs/README.md](docs/README.md)** | Full feature documentation |
| **[docs/USER_FLOW_ENDUSER.md](docs/USER_FLOW_ENDUSER.md)** | How end-users work |
| **[docs/USER_FLOW_ADMIN.md](docs/USER_FLOW_ADMIN.md)** | How admins work |
| **[docs/API_SPEC.md](docs/API_SPEC.md)** | Complete API reference |
| **[docs/SECURITY_MODEL.md](docs/SECURITY_MODEL.md)** | Security architecture |

---

## 📦 What's Included

### Core Modules (18 PowerShell files)

#### End-User Tools
```
Keygen.ps1           - Generate Cardano keypairs
SignOffline.ps1      - Sign messages with private key
ExportWallet.ps1     - Export wallet for backup
VerifyLocal.ps1      - Verify signature before submission
EndUserGUI.ps1       - User-friendly GUI interface
```

#### Admin Tools
```
GenerateChallenge.ps1 - Create verification challenges
VerifySignature.ps1   - Verify user signatures server-side
VerifyOnchain.ps1     - Query blockchain for wallet stake
UserRegistry.ps1      - Manage community members
ExportReports.ps1     - Generate analysis reports
AdminGUI.ps1          - Admin dashboard interface
```

#### Core Crypto
```
VerifySignature.ps1   - Ed25519 verification engine
DeriveStake.ps1       - Extract stake addresses
MessageFormat.json    - Standard message schema
SignatureFormat.json  - Standard signature schema
```

### Documentation (7 files)
- Complete architecture documentation
- End-user and admin workflow guides
- Full API specification
- Comprehensive security model
- Quick start guide

### Entry Point
- `Launcher.ps1` - Main GUI launcher with mode selection

---

## ✨ Key Features

### 🔐 Security-First Design
- **Offline Signing**: Private keys never leave your computer
- **Challenge-Response**: One-time challenges prevent replay attacks
- **Ed25519 Cryptography**: Industry-standard digital signatures
- **Air-Gappable**: Can run on completely offline machines
- **Audit Trail**: Complete logging of all operations

### 👤 End-User Features
- Generate Cardano keypairs locally
- Sign messages without exposing private keys
- Verify signatures before submission
- Export wallet for backup/recovery
- Works entirely offline

### 👨‍💼 Admin Features
- Generate unique verification challenges
- Server-side signature verification
- Optional on-chain stake verification
- User registry management
- Batch operations and reporting

### 🎨 User Interfaces
- **GUI Mode**: Intuitive Windows Forms interface
- **CLI Mode**: PowerShell command-line interface
- **Both approaches** fully supported

---

## 🎬 Getting Started

### Quickest Start (30 seconds)
```powershell
.\Launcher.ps1
```
Choose your role and get started!

### Full Setup (5 minutes)
See [QUICK_START.md](QUICK_START.md) for detailed instructions.

### Production Deployment (30 minutes)
See [docs/README.md](docs/README.md) for enterprise setup.

---

## 📊 Architecture Overview

```
┌─────────────────────────────────────────────────────────┐
│         Cardano Community Suite (Launcher.ps1)          │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌──────────────────────┐  ┌──────────────────────┐   │
│  │  End-User App        │  │  Community Admin     │   │
│  ├──────────────────────┤  ├──────────────────────┤   │
│  │ • Generate Keys      │  │ • Create Challenges  │   │
│  │ • Sign Offline       │  │ • Verify Signatures  │   │
│  │ • Export Wallet      │  │ • Check On-Chain     │   │
│  │ • Verify Local       │  │ • Manage Registry    │   │
│  │ • GUI Interface      │  │ • Export Reports     │   │
│  └──────────────────────┘  └──────────────────────┘   │
│           │                          │                 │
│           ├─────────────────────────┤                 │
│                    │                                   │
│         ┌──────────▼──────────┐                       │
│         │   Core Crypto       │                       │
│         ├─────────────────────┤                       │
│         │ • Ed25519 Verify    │                       │
│         │ • Stake Derivation  │                       │
│         │ • Message Formats   │                       │
│         └─────────────────────┘                       │
│                    │                                   │
│         ┌──────────▼──────────┐                       │
│         │ External APIs       │                       │
│         ├─────────────────────┤                       │
│         │ • Koios (On-Chain)  │                       │
│         │ • cardano-signer    │                       │
│         │ • cardano-cli       │                       │
│         └─────────────────────┘                       │
└─────────────────────────────────────────────────────────┘
```

---

## 🔄 Typical Workflows

### End-User: Join Community
1. Receive challenge from admin
2. Generate keypair locally
3. Sign challenge with private key
4. Verify signature locally
5. Submit to admin
6. Get verified! ✓

### Admin: Verify Member
1. Generate unique challenge
2. Send to user
3. Receive signed response
4. Verify signature
5. Check on-chain stake (optional)
6. Register user in system
7. Export report

---

## 📋 Requirements

### System
- Windows 10/11
- PowerShell 5.1 or later
- .NET Framework 4.7.2+

### External Tools
- `cardano-cli.exe` - Cardano command-line interface
- `cardano-signer.exe` - Ed25519 signing utility

### Network
- Optional: Internet access for on-chain verification (Koios API)
- Fully offline capable (without on-chain features)

---

## 🛠️ File Structure

```
cardano-community-suite/          # Project root
├── Launcher.ps1                  # 🚀 Start here
├── QUICK_START.md                # Quick setup guide
├── STRUCTURE.md                  # File organization
├── README.md                      # This file
│
├── end-user-app/                 # End-user tools
│   ├── EndUserGUI.ps1
│   └── modules/
│       ├── Keygen.ps1
│       ├── SignOffline.ps1
│       ├── ExportWallet.ps1
│       └── VerifyLocal.ps1
│
├── community-admin/              # Admin tools
│   ├── AdminGUI.ps1
│   ├── modules/
│   │   ├── GenerateChallenge.ps1
│   │   ├── VerifySignature.ps1
│   │   ├── VerifyOnchain.ps1
│   │   ├── UserRegistry.ps1
│   │   └── ExportReports.ps1
│   ├── scripts/
│   │   ├── verify_stake.sh
│   │   └── batch_verify.py
│   ├── data/
│   │   └── user_registry.json
│   └── reports/
│
├── core-crypto/                  # Cryptography layer
│   ├── VerifySignature.ps1
│   ├── DeriveStake.ps1
│   ├── MessageFormat.json
│   └── SignatureFormat.json
│
└── docs/                         # Documentation
    ├── README.md
    ├── USER_FLOW_ENDUSER.md
    ├── USER_FLOW_ADMIN.md
    ├── API_SPEC.md
    ├── SECURITY_MODEL.md
    └── README.MVP.md
```

---

## 🔐 Security Highlights

### Private Key Protection
- Keys generated locally on user's machine
- Never transmitted over network
- Optional hardware wallet support
- Air-gapped signing capability

### Signature Verification
- Industry-standard Ed25519 algorithm
- Dual-layer verification (client + server)
- Challenge expiry prevents replay attacks
- Nonce uniqueness enforcement

### On-Chain Verification
- Public blockchain data queries
- Optional stake balance verification
- Uses trusted Koios API
- No private data exposure

See [docs/SECURITY_MODEL.md](docs/SECURITY_MODEL.md) for complete security details.

---

## 🚀 Production Ready

### Tested & Verified
- ✅ Cryptographic implementation validated
- ✅ User workflows tested in production
- ✅ Handles edge cases and errors
- ✅ Comprehensive logging and auditing

### Enterprise Features
- ✅ User registry with persistence
- ✅ Audit trails for compliance
- ✅ Report generation (JSON/CSV)
- ✅ Batch operations support
- ✅ API specification for integration

### Scalability
- ✅ Minimal resource usage
- ✅ Fast signature verification
- ✅ Efficient registry queries
- ✅ Supports hundreds of users

---

## 📚 Documentation Index

| Document | Audience | Purpose |
|----------|----------|---------|
| **QUICK_START.md** | Everyone | Get running quickly |
| **STRUCTURE.md** | Everyone | Understand organization |
| **docs/README.md** | Everyone | Feature overview |
| **docs/USER_FLOW_ENDUSER.md** | End-Users | How to use tools |
| **docs/USER_FLOW_ADMIN.md** | Admins | How to manage community |
| **docs/API_SPEC.md** | Developers | Complete API reference |
| **docs/SECURITY_MODEL.md** | Security | Architecture & best practices |

---

## 🤝 Integration

### As Library
```powershell
# Import modules directly
. ".\cardano-community-suite\end-user-app\modules\SignOffline.ps1"
$signature = Sign-MessageOffline -Message "test" -SkeyPath ".\keys\payment.skey"
```

### As Service
```powershell
# Run as service for continuous verification
# See docs/README.md for setup instructions
```

### As API
```powershell
# Modules can be wrapped in REST API (Flask, FastAPI)
# See Phase 2 roadmap in docs/README.md
```

---

## 🎯 Use Cases

### Primary
- **Community Membership Verification**: Verify membership without revealing financial data
- **Stake-Based Authentication**: Create access systems based on wallet delegation

### Secondary
- **Digital Signatures**: Sign contracts or documents
- **Identity Verification**: Prove Cardano wallet ownership
- **Governance Voting**: Create verifiable voting systems

### Advanced
- **Multi-Community Aggregation**: Manage multiple communities
- **Cross-Chain Integration**: Extend to other blockchains
- **Mobile Integration**: QR code signing for mobile users

---

## 🎓 Learning Path

### Beginner (5 min)
1. Run `Launcher.ps1`
2. Generate keypair
3. Sign a message
4. Read QUICK_START.md

### Intermediate (30 min)
1. Read USER_FLOW_ENDUSER.md
2. Try all end-user features
3. Setup as admin
4. Generate challenges

### Advanced (2 hours)
1. Read SECURITY_MODEL.md
2. Read API_SPEC.md
3. Understand architecture
4. Plan custom integration

---

## 📞 Support & Community

### Getting Help
- 📖 **Documentation**: Start with QUICK_START.md
- 🐛 **Issues**: Report on GitHub Issues
- 💬 **Questions**: Ask on GitHub Discussions
- 📧 **Email**: support@example.com

### Contributing
- Fork repository
- Create feature branch
- Submit pull request
- All contributions welcome!

---

## 📜 License

MIT License - Use freely in projects
See LICENSE file for details

---

## 🙏 Acknowledgments

Built for the Cardano community by developers, for developers.

Thanks to:
- Cardano Foundation
- Input Output Global (IOG)
- Cardano Developer Community
- All contributors

---

## 🎯 Next Steps

### Now
- ✅ Read this README
- ✅ Run QUICK_START.md
- ✅ Launch the application

### Soon
- 📖 Explore documentation
- 🔧 Try all features
- 💾 Setup user registry

### Later
- 🚀 Deploy to production
- 🤝 Integrate with systems
- 📊 Generate reports

---

**Ready to get started? → [QUICK_START.md](QUICK_START.md)**

**Questions? → [docs/README.md](docs/README.md)**

**Built with ❤️ for Cardano**
