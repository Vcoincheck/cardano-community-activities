# ============================================
# CORE-CRYPTO: Verify Signature (ed25519)
# ============================================
# Low-level ed25519 signature verification using cardano-signer

function Verify-Ed25519Signature {
    param(
        [string]$PublicKey,
        [string]$Message,
        [string]$Signature,
        [string]$SignerExePath = ".\cardano-signer.exe"
    )
    
    Write-Host "Verifying signature..." -ForegroundColor Yellow
    
    if (-not (Test-Path $SignerExePath)) {
        Write-Host "Error: cardano-signer.exe not found at $SignerExePath" -ForegroundColor Red
        return $false
    }
    
    try {
        $tempDir = [System.IO.Path]::GetTempPath()
        $msgFile = Join-Path $tempDir "msg_$(Get-Date -Format 'yyyyMMddHHmmss').txt"
        $sigFile = Join-Path $tempDir "sig_$(Get-Date -Format 'yyyyMMddHHmmss').txt"
        
        # Write message and signature to temp files
        $Message | Out-File -FilePath $msgFile -Encoding UTF8 -NoNewline
        $Signature | Out-File -FilePath $sigFile -Encoding UTF8 -NoNewline
        
        # Run verification
        $output = & $SignerExePath verify --message-file $msgFile --signature $Signature --public-key $PublicKey 2>&1
        
        # Cleanup
        Remove-Item $msgFile -ErrorAction SilentlyContinue
        Remove-Item $sigFile -ErrorAction SilentlyContinue
        
        if ($output -match "true|valid") {
            Write-Host "✓ Signature valid" -ForegroundColor Green
            return $true
        } else {
            Write-Host "✗ Signature invalid" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "Error verifying signature: $_" -ForegroundColor Red
        return $false
    }
}
