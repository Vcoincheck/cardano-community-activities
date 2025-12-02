# Cardano Community Suite - Quick Start Guide

## Installation (60 seconds)

### Step 1: Prerequisites
```powershell
# Check PowerShell version (need 5.1+)
$PSVersionTable.PSVersion

# Download Cardano CLI
# From: https://github.com/input-output-hk/cardano-cli/releases
# Extract to: cardano-community-suite/cardano-cli-win64/

# Download cardano-signer
# From: https://github.com/input-output-hk/cardano-signer/releases
# Copy to: cardano-community-suite/
```

### Step 2: Launch
```powershell
cd cardano-community-suite
.\Launcher.ps1
```

### Step 3: Choose Your Role
- 👤 **End-User**: Manage wallets, sign messages
- 👨‍💼 **Admin**: Verify users, manage community

---

## End-User Quick Start (5 min)

### Generate Your First Keypair
```powershell
1. Click "👤 End-User Tools"
2. Click "1. Generate Keypair"
3. Keys saved to: ./keys/payment_TIMESTAMP.skey|vkey
```

**Keys explained:**
- `.vkey` = Public key (share with others)
- `.skey` = Private key (KEEP SECRET!)

### Sign a Message
```powershell
1. Click "2. Sign Message"
2. Enter message: "Hello Cardano Community!"
3. Select your .skey file
4. Get signature output
```

### Verify Signature (Before Submitting)
```powershell
1. Click "4. Verify Signature"
2. Paste your public key
3. Paste your signature
4. Verify locally ✓ before sending to admin
```

### Export Wallet Backup
```powershell
1. Click "3. Export Wallet"
2. Keys backed up as JSON
3. Store in safe location
```

---

## Admin Quick Start (5 min)

### Generate Challenge for User
```powershell
1. Click "👨‍💼 Admin Dashboard"
2. Click "Generate Challenge"
3. Challenge created with unique ID
4. Send to user (user has 1 hour to respond)
```

### Verify User Signature
```powershell
1. Receive signed response from user
2. Click "Verify Signature"
3. System checks:
   ✓ Challenge not expired
   ✓ Signature is valid
   ✓ Public key matches
4. User verified!
```

### Check User's On-Chain Stake (Optional)
```powershell
1. Click "Check On-Chain Stake"
2. Enter stake address: stake1qy2z5r8v9w...
3. System queries Koios API
4. Shows: ADA balance, delegation status
```

### View Verified Users
```powershell
1. Click "View Registry"
2. See all verified community members
3. Track: Wallet, Community, Verification Date
```

### Export Report
```powershell
1. Click "Export Report"
2. Choose format: JSON or CSV
3. Report saved to: ./community-admin/reports/
4. Use for analytics and auditing
```

---

## Common Workflows

### Scenario 1: Community Member Joins
```
ADMIN                          USER
  │
  ├─ Generate Challenge ──────→ │
  │                             │
  │                    ← Read Challenge
  │                             │
  │                    ← Generate Keypair
  │                             │
  │                    ← Sign Message with Private Key
  │                             │
  │ ← Submit Signature          │
  │                             │
  ├─ Verify Signature           │
  │                             │
  ├─ Check On-Chain Stake       │
  │                             │
  ├─ Register User              │
  │                             │
  ├─ Generate Report ───────────→ Approved! ✓
```

### Scenario 2: Offline Signing (Secure)
```
INTERNET-CONNECTED            AIR-GAPPED COMPUTER
Machine: Generate challenge           │
                    │ (USB drive) ─→ │
                    │                 │
                    │     ← Sign message on offline computer
                    │     (private key never touches internet)
                    │    │
                    │    (USB drive)─→ Submit signature
                    │
Verify on internet-connected machine
```

---

## Troubleshooting

### "cardano-signer.exe not found"
- Download from: https://github.com/input-output-hk/cardano-signer
- Place in: `cardano-community-suite/` root directory

### "Challenge expired"
- Challenges expire after 1 hour
- Request new challenge from admin

### "Signature verification failed"
- Check: Message matches exactly
- Check: Correct private key used
- Check: No extra whitespace

### "On-chain lookup failed"
- Check: Koios API is accessible (koios.rest)
- Check: Stake address format is correct
- Retry after a few seconds

---

## Security Reminders ⚠️

1. **Never share .skey files**
   - Your private key = complete access to wallet
   - Treat like passwords

2. **Verify before submitting**
   - Always verify signature locally first
   - Don't trust just one verification

3. **Use offline signing for high-value operations**
   - Air-gapped computer = maximum security
   - USB drive to transfer data

4. **Backup your keys**
   - Multiple encrypted backups
   - Different physical locations
   - Test restore process

5. **Check challenge expiry**
   - Challenges expire after 1 hour
   - Prevents old signatures from working

---

## Next Steps

- Read full documentation: `./docs/README.md`
- Understand security model: `./docs/SECURITY_MODEL.md`
- Explore API reference: `./docs/API_SPEC.md`
- Try advanced features in docs

---

## Support & Help

- 📖 Documentation: `./docs/`
- 🐛 Issues: GitHub Issues
- 💬 Questions: GitHub Discussions
- 📧 Contact: support@example.com

**Happy signing! 🚀**
