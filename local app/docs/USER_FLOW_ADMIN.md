# Cardano Community Suite - User Flow (Admin)

## Overview
Admins manage community verification by generating challenges, verifying signatures, and maintaining user registry.

## Workflow

### Step 1: Initialize Community
- Setup community configuration
- Define verification rules (stake requirement, etc.)
- Create challenge generation policy

### Step 2: Create Challenge
- Generate unique challenge for user
- Includes: challenge_id, nonce, message, expiry
- Challenge expires after 1 hour by default
- Example usage:
```powershell
$challenge = Generate-SigningChallenge `
  -CommunityId "cardano-devs-ph" `
  -Action "verify_membership"
```

### Step 3: Send Challenge to User
- Distribute challenge via secure channel (email, UI, etc.)
- User receives JSON payload
- User has limited time window to respond

### Step 4: Receive Signed Response
- User submits signed response with signature + public key
- Admin receives submission

### Step 5: Verify Signature
- Server-side signature verification using ed25519
- Check challenge expiry
- Validate challenge_id matches
- Example:
```powershell
$verified = Verify-UserSignature `
  -Challenge $challenge `
  -SignatureData $submission
```

### Step 6: Verify On-Chain (Optional)
- Query Koios API for wallet stake
- Verify minimum stake balance
- Check if wallet is delegated
- Example:
```powershell
$stake = Verify-OnChainStake -StakeAddress $userStakeAddr
```

### Step 7: Register User
- Store verified user in registry
- Record verification timestamp
- Track community membership
- Example:
```powershell
Register-VerifiedUser `
  -WalletAddress $walletAddr `
  -StakeAddress $stakeAddr `
  -ChallengeId $challengeId `
  -CommunityId "cardano-devs-ph"
```

### Step 8: Generate Reports
- Export user registry
- Generate community statistics
- Track verification trends
- Formats: JSON, CSV, HTML

## File Organization
```
community-admin/
├── modules/
│   ├── GenerateChallenge.ps1    # Create challenges
│   ├── VerifySignature.ps1      # Verify signatures
│   ├── VerifyOnchain.ps1        # Check on-chain data
│   ├── UserRegistry.ps1         # Manage users
│   └── ExportReports.ps1        # Generate reports
├── AdminGUI.ps1                 # GUI dashboard
├── scripts/
│   ├── verify_stake.sh          # Batch verification
│   └── batch_verify.py          # Bulk operations
└── data/
    └── user_registry.json       # User database
```

## API Integration

### Koios API
- Endpoint: `https://api.koios.rest/api/v0/`
- Query account info by stake address
- No authentication required

### Blockfrost (Alternative)
- Endpoint: `https://cardano-mainnet.blockfrost.io/`
- Requires API key
- Rate limited

## Security Considerations
1. **Challenge Expiry**: Set appropriate expiry window (default 1 hour)
2. **Nonce Randomness**: Ensure nonce is truly random
3. **Replay Protection**: Validate nonce uniqueness per challenge
4. **Rate Limiting**: Implement rate limits on challenge generation
5. **Signature Validation**: Always verify server-side (don't trust client)
6. **On-Chain Verification**: Optional but recommended for high-security applications

## Maintenance Tasks
- Regular user registry cleanup (remove inactive users)
- Export verification logs for auditing
- Monitor API rate limits
- Update verification rules as needed
