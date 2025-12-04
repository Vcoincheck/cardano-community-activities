# ============================================
# END-USER-APP: Export Wallet
# ============================================
# Export wallet data and keys for backup/recovery

function Export-WalletData {
    param(
        [string]$WalletPath = ".\keys",
        [string]$ExportPath = ".\exports",
        [string]$Format = "json"  # json, csv, encrypted
    )
    
    Write-Host "`n========== Wallet Export ==========" -ForegroundColor Cyan
    
    if (-not (Test-Path $WalletPath)) {
        Write-Host "✗ Wallet path not found: $WalletPath" -ForegroundColor Red
        return $false
    }
    
    if (-not (Test-Path $ExportPath)) {
        New-Item -ItemType Directory -Path $ExportPath | Out-Null
    }
    
    try {
        $timestamp = Get-Date -Format 'yyyyMMddHHmmss'
        $exportFile = Join-Path $ExportPath "wallet_export_$timestamp.$Format"
        
        # Get all key files
        $keyFiles = Get-ChildItem -Path $WalletPath -Filter "*.vkey", "*.skey" -ErrorAction SilentlyContinue
        
        Write-Host "Found $($keyFiles.Count) key files" -ForegroundColor Yellow
        
        if ($Format -eq "json") {
            $walletData = @{
                exportDate = (Get-Date -Format 'o')
                walletPath = $WalletPath
                keyCount = $keyFiles.Count
                keys = @()
            }
            
            foreach ($file in $keyFiles) {
                $content = Get-Content $file.FullName -Raw
                $walletData.keys += @{
                    filename = $file.Name
                    size = $file.Length
                    modified = $file.LastWriteTime
                }
            }
            
            $walletData | ConvertTo-Json | Out-File -FilePath $exportFile -Encoding UTF8
        }
        
        Write-Host "✓ Wallet exported to: $exportFile" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "✗ Error exporting wallet: $_" -ForegroundColor Red
        return $false
    }
}
