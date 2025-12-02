# ============================================
# CORE.PS1 - Helper Functions & API Layer
# ============================================
# Logging, API calls, and common utilities

$script:apiBase = "https://mine.defensio.io/api"

function Write-Log {
    param([string]$Message, [string]$Color = "Black")

    if ($null -eq $script:logBox) { return }

    $timestamp = Get-Date -Format "HH:mm:ss"
    $logMessage = "[$timestamp] $Message`r`n"

    # Map logical color names to actual System.Drawing.Color
    switch ($Color.ToLower()) {
        'softred' { $col = [System.Drawing.Color]::FromArgb(255,107,107) }
        'red'     { $col = [System.Drawing.Color]::FromArgb(255,80,80) }
        'green'   { $col = [System.Drawing.Color]::FromArgb(126, 231, 135) }
        'blue'    { $col = [System.Drawing.Color]::FromArgb(154,209,255) }
        'yellow'  { $col = [System.Drawing.Color]::FromArgb(255,184,107) }
        'orange'  { $col = [System.Drawing.Color]::FromArgb(255,165,0) }
        'purple'  { $col = [System.Drawing.Color]::FromArgb(170,120,255) }
        'gray'    { $col = [System.Drawing.Color]::FromArgb(154,166,178) }
        default   { $col = [System.Drawing.Color]::FromArgb(230,238,240) }
    }

    try {
        # If logBox is a RichTextBox we can set selection color per append
        if ($script:logBox -is [System.Windows.Forms.RichTextBox]) {
            $start = $script:logBox.TextLength
            $script:logBox.SelectionStart = $start
            $script:logBox.SelectionColor = $col
            $script:logBox.AppendText($logMessage)
            $script:logBox.SelectionColor = $script:logBox.ForeColor
            $script:logBox.ScrollToCaret()
        } else {
            # Fallback to TextBox behavior
            $script:logBox.AppendText($logMessage)
            $script:logBox.Refresh()
        }
    } catch {
        # Ignore logging errors to avoid breaking UI flows
    }
}

function Get-Statistics {
    param([string]$Address)
    
    try {
        $statUrl = "$script:apiBase/statistics/$Address"
        $response = Invoke-RestMethod -Uri $statUrl -Method GET -TimeoutSec 10 -ErrorAction Stop
        
        if ($response.PSObject.Properties.Name -contains 'local' -and 
            $response.local.PSObject.Properties.Name -contains 'crypto_receipts') {
            return [int]$response.local.crypto_receipts
        }
        return 0
    } catch {
        Write-Log "⚠ Cannot get stats for ${Address}: $($_.Exception.Message)" "Orange"
        return 0
    }
}

function Create-Signature {
    param(
        [string]$OriginalAddress,
        [string]$DestinationAddress,
        [string]$SkeyPath,
        [string]$Message = "Assign accumulated Scavenger rights to: $DestinationAddress"
    )
    
    if ([string]::IsNullOrWhiteSpace($Message)) {
        $Message = "Assign accumulated Scavenger rights to: $DestinationAddress"
    }
    $signatureFile = "signature_temp_$(Get-Date -Format 'yyyyMMddHHmmss').json"
    
    try {
        # Find cardano-signer
        $signerPath = ".\cardano-signer.exe"
        if (-not (Test-Path $signerPath)) {
            try {
                $null = Get-Command cardano-signer -ErrorAction Stop
                $signerPath = "cardano-signer"
            } catch {
                throw "Cannot find cardano-signer.exe"
            }
        }
        
        # Create signature
        & $signerPath sign --cip30 `
            --data "$Message" `
            --secret-key "$SkeyPath" `
            --address "$OriginalAddress" `
            --json-extended > $signatureFile
        
        if ($LASTEXITCODE -ne 0) {
            throw "cardano-signer returned error"
        }
        
        $sigJson = Get-Content $signatureFile | ConvertFrom-Json
        $signature = $sigJson.output.COSE_Sign1_hex
        
        # Remove temp file
        Remove-Item $signatureFile -ErrorAction SilentlyContinue
        
        return $signature
    } catch {
        Write-Log "ERROR creating signature: $($_.Exception.Message)" "SoftRed"
        if (Test-Path $signatureFile) {
            Remove-Item $signatureFile -ErrorAction SilentlyContinue
        }
        return $null
    }
}

function Execute-Donation {
    param(
        [string]$OriginalAddress,
        [string]$DestinationAddress,
        [string]$Signature
    )
    
    try {
        $donateUrl = "$script:apiBase/donate_to/$DestinationAddress/$OriginalAddress/$Signature"
        $resp = Invoke-RestMethod -Uri $donateUrl -Method POST -ErrorAction Stop
        return $resp
    } catch {
        $errorMsg = $_.Exception.Message
        if ($_.Exception.Response) {
            try {
                $reader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
                $errorBody = $reader.ReadToEnd()
                $errorMsg += "`n$errorBody"
            } catch {}
        }
        Write-Log "ERROR API: $errorMsg" "SoftRed"
        return $null
    }
}

function Process-Response {
    param($Response, [string]$OriginalAddr, [string]$DestAddr)
    
    $logContent = @"
================================================
Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Original: $OriginalAddr
Destination: $DestAddr
================================================

"@
    
    if ($Response.status -eq "success") {
        $msg = $Response.message
        $solutionsMoved = if ($Response.PSObject.Properties.Name -contains "Solutions_consolidated") { 
            $Response.Solutions_consolidated 
        } else { 0 }
        
        Write-Log "SUCCESS: $msg" "Green"
        $logContent += "SUCCESS`n$msg`n"
        
        if ($solutionsMoved -gt 0) {
            Write-Log "Transferred: $solutionsMoved solutions" "Blue"
            $logContent += "Transferred: $solutionsMoved solutions`n"
        } else {
            Write-Log "No solutions to transfer (0)" "Orange"
            $logContent += "No solutions to transfer (0)`n"
        }
        
        if ($Response.original_address -eq $Response.destination_address) {
            Write-Log "UNDO operation (transfer back to original wallet)" "Purple"
            $logContent += "UNDO operation`n"
        }
        
    } elseif ($Response.statusCode -eq 409) {
        Write-Log "CONFLICT: Wallet already has active donation to this address" "Orange"
        Write-Log "-> $($Response.message)" "Orange"
        $logContent += "CONFLICT (409)`n$($Response.message)`n"
        
    } elseif ($Response.statusCode -eq 400) {
        Write-Log "SIGNATURE ERROR: Invalid" "SoftRed"
        Write-Log "-> $($Response.message)" "SoftRed"
        $logContent += "Bad Request (400)`n$($Response.message)`n"
        
    } elseif ($Response.statusCode -eq 404) {
        Write-Log "WALLET NOT FOUND: Not registered in system" "SoftRed"
        Write-Log "-> $($Response.message)" "SoftRed"
        $logContent += "Not Found (404)`n$($Response.message)`n"
        
    } else {
        Write-Log "Other result from server" "Blue"
        $logContent += "Other result`n"
    }
    
    $rawJson = $Response | ConvertTo-Json -Depth 10
    $logContent += "`n=== RAW JSON ===`n$rawJson`n`n"
    
    return $logContent
}

function Save-FullLog {
    param([string]$Content)
    
    $logFile = "donation_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $header = 'Timestamp,Origin,Destination,Result'
    $csvLines = @($header)
    $lines = $Content -split "`n"
    foreach ($line in $lines) {
        if ($line -match 'Time: (.+)') { $ts = $matches[1] }
        if ($line -match 'Original: (.+)') { $orig = $matches[1] }
        if ($line -match 'Destination: (.+)') { $dest = $matches[1] }
        if ($line -match 'SUCCESS') { $result = 'SUCCESS' }
        elseif ($line -match 'No solutions to transfer') { $result = 'NO_SOLUTIONS' }
        elseif ($line -match 'CONFLICT') { $result = 'CONFLICT' }
        elseif ($line -match 'SIGNATURE ERROR') { $result = 'SIGNATURE_ERROR' }
        elseif ($line -match 'WALLET NOT FOUND') { $result = 'NOT_FOUND' }
        elseif ($line -match 'Other result') { $result = 'OTHER' }
        if ($line -match '=== RAW JSON ===') {
            $csvLines += "$ts,$orig,$dest,$result"
            $ts = $orig = $dest = $result = ''
        }
    }
    $csvLines | Out-File -FilePath $logFile -Encoding UTF8
    Write-Log "Log saved: $logFile" "Blue"
    # Open log file
    Start-Process notepad.exe $logFile
}
