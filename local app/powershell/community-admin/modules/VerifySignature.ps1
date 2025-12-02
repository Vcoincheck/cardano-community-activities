# ============================================
# COMMUNITY-ADMIN: Verify Signature
# ============================================
# Verify user signatures server-side

# Load VerifySignature module from core-crypto
$cryptoPath = Join-Path -Path (Split-Path -Parent -Path (Split-Path -Parent $PSScriptRoot)) -ChildPath "core-crypto\VerifySignature.ps1"
if (Test-Path $cryptoPath) {
    . $cryptoPath
} else {
    Write-Warning "Core crypto module not found at: $cryptoPath"
}

function Verify-UserSignature {
    param(
        [hashtable]$Challenge,
        [hashtable]$SignatureData,
        [bool]$CheckExpiry = $true
    )
    
    Write-Host "`n========== Server-Side Signature Verification ==========" -ForegroundColor Cyan
    
    # Check challenge expiry
    if ($CheckExpiry) {
        $now = [int][double]::Parse((Get-Date -UFormat %s))
        if ($now -gt $Challenge.expiry) {
            Write-Host "✗ Challenge expired" -ForegroundColor Red
            return $false
        }
    }
    
    # Check challenge ID matches
    if ($SignatureData.challenge_id -ne $Challenge.challenge_id) {
        Write-Host "✗ Challenge ID mismatch" -ForegroundColor Red
        return $false
    }
    
    # Verify signature
    $result = Verify-Ed25519Signature -PublicKey $SignatureData.public_key `
                                      -Message $Challenge.message `
                                      -Signature $SignatureData.signature
    
    if ($result) {
        Write-Host "✓ Signature valid and challenge verified!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ Signature verification failed" -ForegroundColor Red
        return $false
    }
}
