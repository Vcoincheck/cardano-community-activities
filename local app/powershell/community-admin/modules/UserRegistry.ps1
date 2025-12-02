# ============================================
# COMMUNITY-ADMIN: User Registry
# ============================================
# Track verified community members

$script:userRegistry = @()
$script:registryPath = ".\community-admin\data\user_registry.json"

function Register-VerifiedUser {
    param(
        [string]$WalletAddress,
        [string]$StakeAddress,
        [string]$ChallengeId,
        [string]$CommunityId
    )
    
    Write-Host "Registering verified user..." -ForegroundColor Yellow
    
    $user = @{
        id = [guid]::NewGuid().ToString()
        walletAddress = $WalletAddress
        stakeAddress = $StakeAddress
        challengeId = $ChallengeId
        communityId = $CommunityId
        verificationDate = (Get-Date -Format 'o')
        status = "verified"
    }
    
    $script:userRegistry += $user
    
    # Persist to file
    $dirPath = Split-Path $script:registryPath
    if (-not (Test-Path $dirPath)) {
        New-Item -ItemType Directory -Path $dirPath | Out-Null
    }
    
    $script:userRegistry | ConvertTo-Json | Out-File -FilePath $script:registryPath -Encoding UTF8
    
    Write-Host "✓ User registered (ID: $($user.id))" -ForegroundColor Green
    return $user
}

function Get-RegistryStats {
    if (-not (Test-Path $script:registryPath)) {
        return @{ TotalUsers = 0; Communities = @{} }
    }
    
    $users = Get-Content $script:registryPath | ConvertFrom-Json
    $stats = @{
        TotalUsers = $users.Count
        VerifiedUsers = ($users | Where-Object { $_.status -eq "verified" }).Count
        Communities = ($users | Group-Object -Property communityId | ForEach-Object { @{ Name = $_.Name; Count = $_.Count } })
    }
    
    return $stats
}

function Export-RegistryReport {
    param(
        [string]$Format = "json",  # json, csv
        [string]$OutputPath = ".\community-admin\reports"
    )
    
    Write-Host "`n========== Registry Report Export ==========" -ForegroundColor Cyan
    
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath | Out-Null
    }
    
    if (-not (Test-Path $script:registryPath)) {
        Write-Host "No registry data found" -ForegroundColor Yellow
        return $false
    }
    
    $users = Get-Content $script:registryPath | ConvertFrom-Json
    $timestamp = Get-Date -Format 'yyyyMMddHHmmss'
    
    if ($Format -eq "json") {
        $reportFile = Join-Path $OutputPath "registry_report_$timestamp.json"
        $users | ConvertTo-Json | Out-File -FilePath $reportFile -Encoding UTF8
    }
    elseif ($Format -eq "csv") {
        $reportFile = Join-Path $OutputPath "registry_report_$timestamp.csv"
        $users | Export-Csv -Path $reportFile -NoTypeInformation
    }
    
    Write-Host "✓ Report exported: $reportFile" -ForegroundColor Green
    return $true
}
