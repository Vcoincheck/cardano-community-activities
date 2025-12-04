# ============================================
# END-USER-APP: Verify Local
# ============================================
# Local verification of signatures before submitting

# Load VerifySignature module from core-crypto
$cryptoPath = Join-Path -Path (Split-Path -Parent -Path (Split-Path -Parent $PSScriptRoot)) -ChildPath "core-crypto\VerifySignature.ps1"
if (Test-Path $cryptoPath) {
    . $cryptoPath
} else {
    Write-Warning "Core crypto module not found at: $cryptoPath"
}

function Verify-SignatureLocal {
    param(
        [string]$PublicKey,
        [string]$Message,
        [string]$Signature
    )
    
    Write-Host "`n========== Local Signature Verification ==========" -ForegroundColor Cyan
    
    $result = Verify-Ed25519Signature -PublicKey $PublicKey -Message $Message -Signature $Signature
    
    if ($result) {
        Write-Host "✓ Signature verified locally - safe to submit!" -ForegroundColor Green
        return $true
    } else {
        Write-Host "✗ Signature verification failed - do NOT submit!" -ForegroundColor Red
        return $false
    }
}
