# Cardano Community Suite - Security Model

## Threat Model

### Level 1: Client-Side Threats
**Threat**: Malicious software on user's computer intercepts private keys
**Mitigation**:
- Offline signing recommended for high-value operations
- Air-gapped signing on separate machine
- Hardware wallet integration for critical keys

### Level 2: Network Threats
**Threat**: Man-in-the-middle (MITM) attack intercepts challenge or signature
**Mitigation**:
- All communication over HTTPS/TLS 1.3+
- Certificate pinning for critical endpoints
- Challenge includes nonce (prevents replay)

### Level 3: Server-Side Threats
**Threat**: Compromised server accepts forged signatures
**Mitigation**:
- Rigorous Ed25519 signature verification
- Challenge expiry (1 hour default)
- Nonce validation (one-time use)
- Rate limiting on verification attempts

### Level 4: Regulatory Threats
**Threat**: Unauthorized access to user registry
**Mitigation**:
- Encrypt user registry at rest
- Access control and audit logging
- GDPR compliance for data retention
- Regular security audits

## Cryptographic Foundation

### Ed25519 Signatures
- Algorithm: EdDSA with Curve25519
- Key size: 32 bytes (256 bits)
- Signature size: 64 bytes (512 bits)
- Implementation: cardano-signer (trustworthy Cardano community tool)

### Message Hashing (Future)
- Algorithm: SHA-256 (can be SHA-3)
- Used for: Audit trail, consistency verification
- Never used alone for signature (full message signed)

### Nonce Generation
- Method: Cryptographically secure random
- Size: Minimum 32 bytes
- Purpose: Prevent challenge replay attacks

## Access Control

### End-User Access
- No special authentication needed
- Challenges are one-time use
- All keys remain client-side
- Operations: Keygen, sign, verify locally

### Admin Access
- Dashboard requires admin password (optional)
- Admin actions: Challenge generation, user registration, registry management
- API calls require API key (optional)
- Rate limiting enforced

## Data Protection

### In Transit
- HTTPS/TLS 1.3+ enforced
- Forward secrecy (ephemeral keys)
- Certificate validation

### At Rest
- User registry: Encrypted JSON
- Private keys: Never stored server-side
- Audit logs: Tamper-evident logging
- Backups: Encrypted with separate key

### Data Retention
- Challenge: 1 hour (auto-delete after expiry)
- User registry: Indefinite (admin configurable)
- Audit logs: 12 months minimum
- Signatures: Indefinite (for verification trail)

## Verification Procedures

### Challenge Verification
1. Check challenge_id format (UUID v4)
2. Validate community_id exists
3. Verify nonce uniqueness
4. Check timestamp reasonableness
5. Validate expiry > current time

### Signature Verification
1. Verify challenge_id present
2. Validate public_key format (hex, 64 chars)
3. Check signature format (hex, 128 chars)
4. Perform Ed25519 verification
5. Log verification attempt

### On-Chain Verification (Optional)
1. Query Koios API for stake address
2. Verify wallet exists on-chain
3. Check minimum balance (if configured)
4. Verify delegation (if configured)
5. Log query timestamp

## Security Best Practices for Admins

### Key Management
- Store admin API keys in secure vault
- Rotate keys monthly
- Use different keys for dev/staging/production
- Never commit keys to version control

### Challenge Generation
- Set appropriate expiry (default 1 hour)
- Use strong, unique messages
- Include action type for audit trail
- Log all challenges generated

### Registry Management
- Regular backups (encrypted)
- Access control on sensitive fields
- Audit all modifications
- Implement retention policies

### Monitoring & Logging
- Monitor failed verification attempts
- Alert on unusual patterns (brute force)
- Log all admin actions
- Regular log analysis

## Compliance

### Standards
- NIST SP 800-175B (Ed25519)
- RFC 8037 (EdDSA signing)
- OWASP Top 10 (application security)

### Recommendations
- Penetration testing annually
- Code audit by independent security firm
- Security awareness training for admins
- Incident response plan
