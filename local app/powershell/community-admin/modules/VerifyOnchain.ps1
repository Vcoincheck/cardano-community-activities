# ============================================
# COMMUNITY-ADMIN: Verify On-Chain
# ============================================
# Verify wallet balance and stake using Koios/Blockfrost API

function Verify-OnChainStake {
    param(
        [string]$StakeAddress,
        [string]$ApiProvider = "koios",  # koios or blockfrost
        [string]$ApiKey = ""
    )
    
    Write-Host "`n========== On-Chain Stake Verification ==========" -ForegroundColor Cyan
    Write-Host "Verifying stake address: $StakeAddress" -ForegroundColor Yellow
    
    if ($ApiProvider -eq "koios") {
        $apiUrl = "https://api.koios.rest/api/v0/account_info"
        
        try {
            $response = Invoke-RestMethod -Uri "$apiUrl?_stake_addresses=`"$StakeAddress`"" `
                                         -Method Get `
                                         -ContentType "application/json" `
                                         -ErrorAction Stop
            
            if ($response -and $response.Count -gt 0) {
                $account = $response[0]
                $balance = [long]$account.balance
                $lovelacePerAda = 1000000
                $ada = $balance / $lovelacePerAda
                
                Write-Host "✓ Stake address found on-chain" -ForegroundColor Green
                Write-Host "  Balance: $ada ADA ($balance Lovelace)" -ForegroundColor Cyan
                Write-Host "  Status: $($account.status)" -ForegroundColor Cyan
                
                return @{
                    StakeAddress = $StakeAddress
                    Balance = $balance
                    BalanceAda = $ada
                    Status = $account.status
                    Verified = $true
                }
            } else {
                Write-Host "✗ Stake address not found or has no ADA" -ForegroundColor Red
                return @{ Verified = $false }
            }
        }
        catch {
            Write-Host "✗ Error checking on-chain: $_" -ForegroundColor Red
            return @{ Verified = $false }
        }
    }
    else {
        Write-Host "✗ API provider '$ApiProvider' not yet implemented" -ForegroundColor Red
        return $null
    }
}
