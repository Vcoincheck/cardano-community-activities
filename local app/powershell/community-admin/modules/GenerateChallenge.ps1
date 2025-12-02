# ============================================
# COMMUNITY-ADMIN: Generate Challenge
# ============================================
# Create cryptographic challenges with nonce and community ID

function Generate-SigningChallenge {
    param(
        [string]$CommunityId = "cardano-community",
        [string]$Action = "verify_membership",
        [string]$CustomMessage = $null
    )
    
    Write-Host "`n========== Challenge Generation ==========" -ForegroundColor Cyan
    
    $challengeId = [guid]::NewGuid().ToString()
    $nonce = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes((Get-Random).ToString() + (Get-Date).Ticks))
    $timestamp = [int][double]::Parse((Get-Date -UFormat %s))
    $expiry = $timestamp + 3600  # 1 hour validity
    
    if ([string]::IsNullOrWhiteSpace($CustomMessage)) {
        $message = "I hereby verify my membership and sign this challenge for $CommunityId"
    } else {
        $message = $CustomMessage
    }
    
    $challenge = @{
        challenge_id = $challengeId
        community_id = $CommunityId
        nonce = $nonce
        timestamp = $timestamp
        action = $Action
        message = $message
        expiry = $expiry
    }
    
    Write-Host "✓ Challenge generated:" -ForegroundColor Green
    Write-Host "  Challenge ID: $challengeId" -ForegroundColor Cyan
    Write-Host "  Community: $CommunityId" -ForegroundColor Cyan
    Write-Host "  Action: $Action" -ForegroundColor Cyan
    Write-Host "  Message: $message" -ForegroundColor Cyan
    Write-Host "  Expires: $(Get-Date -UnixTimeSeconds $expiry -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Yellow
    
    return $challenge
}
