# Cardano Community Suite - API Specification

## Overview
Complete REST API specification for all endpoints and operations.

## Core Concepts

### Challenge
A one-time verification request issued by admin to user.
```json
{
  "challenge_id": "uuid-v4",
  "community_id": "string",
  "nonce": "base64",
  "timestamp": "unix-timestamp",
  "action": "verify_membership|authorize_action|sign_document",
  "message": "string",
  "expiry": "unix-timestamp"
}
```

### Signature Response
Signed response from user.
```json
{
  "signature_id": "uuid-v4",
  "challenge_id": "uuid-v4",
  "wallet_address": "addr1...",
  "public_key": "hex-string",
  "signature": "hex-string",
  "timestamp": "unix-timestamp",
  "signing_method": "cip30|cli|hardware_wallet"
}
```

### User Registration
Verified user entry in registry.
```json
{
  "id": "uuid-v4",
  "wallet_address": "addr1...",
  "stake_address": "stake1...",
  "challenge_id": "uuid-v4",
  "community_id": "string",
  "verification_date": "iso-8601",
  "status": "verified|pending|rejected"
}
```

## Endpoints (PowerShell Functions)

### Challenge Management

#### Generate-SigningChallenge
Generate a new challenge for user verification.
```powershell
Generate-SigningChallenge `
  -CommunityId "string" `
  -Action "verify_membership" `
  -CustomMessage "optional string"
```
**Returns**: Challenge object

#### Verify-UserSignature
Verify a submitted signature against challenge.
```powershell
Verify-UserSignature `
  -Challenge $challengeObject `
  -SignatureData $signatureObject `
  -CheckExpiry $true
```
**Returns**: Boolean (true/false)

### User Management

#### Register-VerifiedUser
Register a user in the community registry.
```powershell
Register-VerifiedUser `
  -WalletAddress "addr1..." `
  -StakeAddress "stake1..." `
  -ChallengeId "uuid" `
  -CommunityId "string"
```
**Returns**: User registration object

#### Get-RegistryStats
Get statistics from user registry.
```powershell
Get-RegistryStats
```
**Returns**: Statistics object with user counts and community breakdown

#### Export-RegistryReport
Export user registry in various formats.
```powershell
Export-RegistryReport `
  -Format "json|csv" `
  -OutputPath ".\path"
```
**Returns**: File path

### On-Chain Verification

#### Verify-OnChainStake
Check wallet balance and stake on-chain.
```powershell
Verify-OnChainStake `
  -StakeAddress "stake1..." `
  -ApiProvider "koios|blockfrost"
```
**Returns**: Stake information object

### Wallet Management

#### Generate-CardanoKeypair
Generate new keypair for user.
```powershell
Generate-CardanoKeypair `
  -OutputPath ".\keys" `
  -CardanoCliPath ".\cardano-cli.exe"
```
**Returns**: Keypair object with paths

#### Sign-MessageOffline
Sign a message offline.
```powershell
Sign-MessageOffline `
  -Message "string" `
  -SkeyPath ".\keys\payment.skey" `
  -SignerExePath ".\cardano-signer.exe"
```
**Returns**: Signature object

## Error Handling

### Common Errors
- `Challenge Expired`: Challenge timestamp > expiry
- `Invalid Signature`: Ed25519 verification failed
- `Challenge ID Mismatch`: Signature doesn't match challenge
- `Wallet Not Found`: Stake address doesn't exist on-chain
- `Insufficient Stake`: Wallet balance below minimum

### Error Response Format
```json
{
  "error": "error_code",
  "message": "Human-readable error description",
  "timestamp": "iso-8601"
}
```

## Rate Limiting
- Challenge generation: 10 per minute per community
- Signature verification: 100 per minute per community
- On-chain queries: 5 per second per API provider

## Security Headers
- Implement HTTPS for all endpoints
- Validate all inputs server-side
- Never transmit private keys
- Use authentication for admin endpoints
- Implement CORS for web clients
