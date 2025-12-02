# Cardano Community Suite - User Flow (End-User)

## Overview
End-users can manage Cardano wallets, sign messages offline, and verify signatures locally without exposing private keys.

## Workflow

### Step 1: Generate Keypair
- User generates new Ed25519 keypair for wallet
- Files: `payment.skey`, `payment.vkey`, `staking.skey`, `staking.vkey`
- **Important**: Keep `.skey` files private and secure

### Step 2: Receive Challenge
- Admin creates and shares a signing challenge (JSON)
- Challenge contains: `challenge_id`, `community_id`, `nonce`, `message`, `expiry`
- Example:
```json
{
  "challenge_id": "550e8400-e29b-41d4-a716-446655440000",
  "community_id": "cardano-devs-ph",
  "message": "I hereby verify my membership...",
  "expiry": 1733047200
}
```

### Step 3: Sign Message
- User signs challenge message using their private key
- Uses cardano-signer executable for Ed25519 signing
- Output: signature (hex-encoded)

### Step 4: Create Signature Package
- Combine challenge + signature into submission package
- Include public key for verification
- Package format: JSON

### Step 5: Local Verification (Optional)
- Verify signature locally before submitting
- Ensures signature is valid before sending to admin
- Reduces server-side processing

### Step 6: Submit to Admin
- Submit signature package to admin endpoint
- Admin performs server-side verification
- User receives confirmation or rejection

## File Organization
```
end-user-app/
├── modules/
│   ├── Keygen.ps1           # Generate keys
│   ├── SignOffline.ps1      # Sign messages
│   ├── ExportWallet.ps1     # Export wallet data
│   └── VerifyLocal.ps1      # Verify signature locally
└── EndUserGUI.ps1           # GUI interface
```

## Security Best Practices
1. **Private Key Storage**: Keep `.skey` files in secure location (preferably encrypted)
2. **Air-Gapped Signing**: Consider using offline computer for sensitive operations
3. **Backup Keys**: Backup private keys in multiple secure locations
4. **Verify Before Submit**: Always verify signature locally before submission
5. **Check Expiry**: Always verify challenge expiry before signing

## Error Handling
- Invalid keypair format → regenerate keys
- Signature verification failed → check message format
- Challenge expired → request new challenge from admin
