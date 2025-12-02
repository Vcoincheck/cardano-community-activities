# Quick Reference - Cardano Community Suite

## 🚀 Getting Started (60 seconds)

### Windows
```bash
# 1. Extract repository
cd Guitool\cardano-community-suite

# 2. Run setup
.\setup.bat

# 3. Set up PATH
.\setup-env.bat

# 4. Verify
cardano-cli --version
```

### Linux/macOS
```bash
# 1. Navigate to project
cd Guitool/cardano-community-suite

# 2. Make executable and run
chmod +x setup.sh
./setup.sh

# 3. Add to PATH
source ./setup-env.sh

# 4. Verify
cardano-cli --version
```

---

## 📋 Common Commands

### Cardano CLI

```bash
# Show version
cardano-cli --version

# Query network status
cardano-cli query tip --mainnet

# Generate payment keys
cardano-cli address key-gen \
  --verification-key-file payment.vkey \
  --signing-key-file payment.skey

# Derive payment address
cardano-cli address build \
  --payment-verification-key-file payment.vkey \
  --mainnet \
  --out-file payment.addr

# Create transaction
cardano-cli transaction build \
  --tx-in "input_utxo#0" \
  --tx-out "$(cat payment.addr)+2000000" \
  --change-address "$(cat payment.addr)" \
  --mainnet \
  --out-file tx.raw

# Sign transaction
cardano-cli transaction sign \
  --tx-body-file tx.raw \
  --signing-key-file payment.skey \
  --mainnet \
  --out-file tx.signed

# Submit transaction
cardano-cli transaction submit \
  --tx-file tx.signed \
  --mainnet
```

### Cardano Addresses

```bash
# Show version
cardano-address --version

# Inspect address
cardano-address address inspect <<< "addr1q..."

# Generate new address from mnemonic
cardano-address address from-seed "twelve word seed phrase..."

# Derive stake address
cardano-address key from-seed "seed phrase" | \
  cardano-address key child 1852H/1815H/0H/2/0 > stake.xsk
```

### Cardano Signer

```bash
# Show version
cardano-signer.exe --version  # Windows
cardano-signer --version      # Linux/Mac

# Sign message
cardano-signer sign \
  --signing-key-file payment.skey \
  --message "Hello Cardano"

# Verify signature
cardano-signer verify \
  --public-key "your_public_key" \
  --signature "signature_hex" \
  --message "Hello Cardano"

# Sign transaction
cardano-signer sign \
  --tx-body-file tx.raw \
  --signing-key-file payment.skey
```

---

## 📁 Directory Structure

```
cardano-community-suite/
├── tools/                      # All Cardano tools
│   ├── cardano-addresses/      # Address management
│   ├── cardano-cli/            # Blockchain CLI
│   └── cardano-signer/         # Transaction signing
├── end-user-app/               # End-user GUI (PowerShell)
├── community-admin/            # Admin GUI (PowerShell)
├── core-crypto/                # Cryptographic modules
├── lib/                        # PowerShell libraries
├── setup.sh                    # Linux/Mac setup
├── setup.bat                   # Windows setup
├── SETUP_GUIDE.md              # This setup guide
└── .env.example                # Configuration template
```

---

## 🔑 Key Concepts

| Term | Meaning | Example |
|------|---------|---------|
| **Address** | Unique wallet identifier | `addr1q2y...` |
| **UTXO** | Unspent transaction output | `abc123#0` |
| **Lovelace** | Smallest unit of ADA | 1 ADA = 1,000,000 Lovelace |
| **TX Fee** | Transaction cost | ~0.17 ADA (~170,000 Lovelace) |
| **Verification Key** | Public key file | `payment.vkey` |
| **Signing Key** | Private key file | `payment.skey` |
| **Event** | Challenge-response authentication | Used for signatures |

---

## 🔗 Network Configuration

| Network | Magic | Explorer | Node Endpoint |
|---------|-------|----------|---------------|
| **Mainnet** | 764824073 | cexplorer.io | mainnet |
| **Testnet** | 1097911063 | testnet.cexplorer.io | testnet |
| **Preview** | 2 | preview.cexplorer.io | preview |
| **Preprod** | 1 | preprod.cexplorer.io | preprod |

---

## 🐛 Troubleshooting

| Problem | Solution |
|---------|----------|
| `cardano-cli: command not found` | Run `./setup-env.sh` (Linux/Mac) or `setup-env.bat` (Windows) |
| Download fails | Check internet, try again (GitHub has rate limits) |
| Extract fails | Delete `tools/downloads/` and re-run setup |
| Permission denied | Run `chmod +x setup.sh` (Linux/Mac) |
| PowerShell blocked | Run `Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process` |
| Out of disk space | Need 2GB+, check with `df -h` (Linux/Mac) or `Get-Volume` (Windows) |

---

## 📚 API Endpoints (Web Suite)

```bash
# Events/Challenges
POST   /api/events              # Create event
GET    /api/events/:id          # Get event
POST   /api/events/:id/verify   # Verify event response

# Signatures
POST   /api/signatures          # Submit signature
GET    /api/signatures/:id      # Get signature status
POST   /api/signatures/:id/verify # Verify signature

# Registry
GET    /api/registry            # List users
POST   /api/registry            # Register user
GET    /api/registry/:id        # Get user
PUT    /api/registry/:id        # Update user

# Reports
GET    /api/reports             # Get reports
POST   /api/reports/export      # Export data

# Wallets
GET    /api/wallets             # List wallets
POST   /api/wallets             # Create wallet
GET    /api/wallets/:id         # Get wallet address
```

---

## 🔐 Security Checklist

- [ ] Private keys stored securely offline
- [ ] Never share seed phrases
- [ ] Use testnet for development
- [ ] Verify addresses before sending ADA
- [ ] Enable 2FA if available
- [ ] Use strong passwords
- [ ] Keep .env file secret (.gitignore)
- [ ] Use HTTPS in production
- [ ] Regular backups of wallets
- [ ] Verify event/challenge signatures

---

## 💾 Backup & Recovery

```bash
# Backup wallet data
cp -r wallets/ wallets.backup
cp -r data/ data.backup

# Backup environment
cp .env .env.backup

# Create compressed backup
tar -czf cardano-suite-backup-$(date +%Y%m%d).tar.gz \
  wallets/ data/ .env
```

---

## 📝 Environment Variables Quick Ref

```bash
# Network
CARDANO_NETWORK=mainnet                    # mainnet, testnet, preview, preprod
KOIOS_API_URL=https://api.koios.rest/api/v1

# Tools
CARDANO_CLI_PATH=./tools/cardano-cli
CARDANO_ADDRESSES_PATH=./tools/cardano-addresses
CARDANO_SIGNER_PATH=./tools/cardano-signer

# App
NODE_ENV=production
APP_NAME="Cardano Community Suite"

# Security
JWT_SECRET=your_secret_key_here
SESSION_TIMEOUT=30

# Logging
LOG_LEVEL=info
LOG_FILE_PATH=./logs/app.log
```

---

## 🎯 Workflow Examples

### Example 1: Create & Sign Transaction

```bash
# 1. Generate keys
cardano-cli address key-gen \
  --verification-key-file payment.vkey \
  --signing-key-file payment.skey

# 2. Build address
cardano-cli address build \
  --payment-verification-key-file payment.vkey \
  --mainnet --out-file payment.addr

# 3. Get UTXOs
ADDR=$(cat payment.addr)
cardano-cli query utxo --address $ADDR --mainnet

# 4. Build transaction
cardano-cli transaction build \
  --tx-in "utxo_id#0" \
  --tx-out "$ADDR+2000000" \
  --change-address $ADDR \
  --mainnet --out-file tx.raw

# 5. Sign transaction
cardano-cli transaction sign \
  --tx-body-file tx.raw \
  --signing-key-file payment.skey \
  --mainnet --out-file tx.signed

# 6. Submit
cardano-cli transaction submit --tx-file tx.signed --mainnet
```

### Example 2: Verify Event Signature

```bash
# 1. Create event (admin)
curl -X POST http://localhost:3001/api/events \
  -H "Content-Type: application/json" \
  -d '{"user_id":"user1","action":"verify"}'

# 2. User signs event (offline)
cardano-signer sign \
  --signing-key-file payment.skey \
  --message "event_data"

# 3. Submit signature (user)
curl -X POST http://localhost:3001/api/signatures \
  -H "Content-Type: application/json" \
  -d '{"event_id":"event1","signature":"sig_hex"}'

# 4. Verify signature (automatic)
curl -X POST http://localhost:3001/api/events/event1/verify
```

---

## 🌐 URLs & Resources

| Resource | URL |
|----------|-----|
| **Cardano Docs** | https://docs.cardano.org |
| **Cardano CLI GitHub** | https://github.com/IntersectMBO/cardano-cli |
| **Cardano Addresses GitHub** | https://github.com/IntersectMBO/cardano-addresses |
| **Cardano Signer GitHub** | https://github.com/gitmachtl/cardano-signer |
| **Koios API** | https://api.koios.rest |
| **Mainnet Explorer** | https://cexplorer.io |
| **Testnet Explorer** | https://testnet.cexplorer.io |

---

## ⏱️ Performance Tips

- Cache network queries when possible
- Use local queries instead of mainnet when testing
- Batch transaction submissions
- Implement connection pooling
- Use prepared statements for database queries
- Enable compression for API responses
- Monitor tool performance with `top` or `Task Manager`

---

## 📞 Support

For issues or questions:
1. Check SETUP_GUIDE.md
2. Review FRONTEND_ARCHITECTURE.md
3. Check tool documentation on GitHub
4. Enable DEBUG mode for verbose logging
5. Check logs in `./logs/` directory

---

**Last Updated:** 2024
**Version:** 1.0
**Status:** Complete & Ready to Deploy
