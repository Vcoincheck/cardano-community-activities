# ============================================
# END-USER-APP: Multi-Address Keygen
# ============================================
# Generate multi-address wallet from mnemonic
# Pattern: Like midnightsigninformulti_v1.ps1 with parallel job processing

param(
    [Parameter(Mandatory=$false)]
    [int]$External = 5,
    
    [Parameter(Mandatory=$false)]
    [int]$Internal = 3
)

if ($External -lt 0 -or $Internal -lt 0) {
    Write-Host "✗ Số lượng không hợp lệ! (External: $External, Internal: $Internal)" -ForegroundColor Red
    exit 1
}

if ($External -eq 0 -and $Internal -eq 0) {
    Write-Host "✗ Ít nhất một trong hai (External hoặc Internal) phải lớn hơn 0!" -ForegroundColor Red
    exit 1
}

Write-Host "=== AUTO MULTI ADDRESS FLOW (MAINNET) ===" -ForegroundColor Cyan
Write-Host "External addresses (0/`$i): $External" -ForegroundColor Yellow
Write-Host "Internal addresses (1/`$i): $Internal" -ForegroundColor Yellow

# =============================================
# Find required executables
# =============================================
$possibleCardanoAddress = @(".\tools\cardano-addresses\cardano-address.exe", ".\tools\cardano-addresses\cardano-address", ".\cardano-address.exe", ".\cardano-address")
$cardanoAddressExe = $possibleCardanoAddress | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $cardanoAddressExe) {
    Write-Host "✗ cardano-address not found" -ForegroundColor Red
    exit 1
}

try {
    $cardanoAddressFull = (Resolve-Path $cardanoAddressExe).Path
} catch {
    Write-Host "✗ Cannot resolve cardano-address: $_" -ForegroundColor Red
    exit 1
}

$possibleCardanoCli = @(".\tools\cardano-cli\cardano-cli.exe", ".\tools\cardano-cli\cardano-cli", ".\cardano-cli-win64\cardano-cli.exe", ".\cardano-cli.exe")
$cardanoCliExe = $possibleCardanoCli | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $cardanoCliExe) {
    Write-Host "✗ cardano-cli not found" -ForegroundColor Red
    exit 1
}

try {
    $cardanoCliFull = (Resolve-Path $cardanoCliExe).Path
} catch {
    Write-Host "✗ Cannot resolve cardano-cli: $_" -ForegroundColor Red
    exit 1
}

Write-Host "✓ Found cardano-address: $cardanoAddressFull" -ForegroundColor Green
Write-Host "✓ Found cardano-cli: $cardanoCliFull" -ForegroundColor Green

# =============================================
# Load BIP39 wordlist
# =============================================
function Load-BIP39Wordlist {
    $wordlistPath = ".\wordlist.txt"
    if (-not (Test-Path $wordlistPath)) {
        $wordlistPath = ".\end-user-app\wordlist.txt"
    }
    if (-not (Test-Path $wordlistPath)) {
        Write-Host "⚠ Wordlist not found, autocomplete disabled" -ForegroundColor Yellow
        return @()
    }
    
    try {
        return (Get-Content $wordlistPath | Where-Object { $_ -match '^\w+$' })
    } catch {
        Write-Host "⚠ Error loading wordlist: $_" -ForegroundColor Yellow
        return @()
    }
}

# =============================================
# GUI: Mnemonic input or file selection
# =============================================
Add-Type -AssemblyName System.Windows.Forms

function Create-MnemonicInput {
    param(
        [int]$WordCount = 12
    )
    
    $wordlist = Load-BIP39Wordlist
    
    # Create form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Enter Mnemonic - $WordCount Words"
    $form.Size = New-Object System.Drawing.Size(800, 600)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    
    # Header
    $lblHeader = New-Object System.Windows.Forms.Label
    $lblHeader.Text = "Enter your $WordCount-word mnemonic:"
    $lblHeader.AutoSize = $true
    $lblHeader.ForeColor = [System.Drawing.Color]::Cyan
    $lblHeader.Location = New-Object System.Drawing.Point(10, 10)
    $form.Controls.Add($lblHeader)
    
    # Create word input fields with autocomplete
    $textBoxes = @()
    $colCount = 3
    $rowCount = [Math]::Ceiling($WordCount / $colCount)
    $boxWidth = 240
    $boxHeight = 25
    $startX = 10
    $startY = 40
    $spacingX = 260
    $spacingY = 35
    
    for ($i = 0; $i -lt $WordCount; $i++) {
        $col = [int]($i % $colCount)
        $row = [int]([Math]::Floor($i / $colCount))
        
        [int]$x = $startX + ($col * $spacingX)
        [int]$y = $startY + ($row * $spacingY)
        
        # Label with word number
        $lbl = New-Object System.Windows.Forms.Label
        $lbl.Text = "$($i + 1):"
        $lbl.AutoSize = $true
        $lbl.ForeColor = [System.Drawing.Color]::Gray
        $lbl.Location = New-Object System.Drawing.Point([int]($x), [int]($y - 20))
        $form.Controls.Add($lbl)
        
        # Textbox with autocomplete
        $txtBox = New-Object System.Windows.Forms.TextBox
        $txtBox.Size = New-Object System.Drawing.Size($boxWidth, $boxHeight)
        $txtBox.Location = New-Object System.Drawing.Point([int]($x), [int]($y))
        $txtBox.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
        $txtBox.ForeColor = [System.Drawing.Color]::Lime
        $txtBox.AutoCompleteMode = [System.Windows.Forms.AutoCompleteMode]::SuggestAppend
        $txtBox.AutoCompleteSource = [System.Windows.Forms.AutoCompleteSource]::CustomSource
        
        # Add wordlist to autocomplete
        if ($wordlist.Count -gt 0) {
            $customSource = New-Object System.Windows.Forms.AutoCompleteStringCollection
            $wordlist | ForEach-Object { $customSource.Add($_) | Out-Null }
            $txtBox.AutoCompleteCustomSource = $customSource
        }
        
        $form.Controls.Add($txtBox)
        $textBoxes += $txtBox
    }
    
    # OK Button
    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Text = "Generate"
    $btnOK.Size = New-Object System.Drawing.Size(100, 35)
    $btnOK.Location = New-Object System.Drawing.Point(300, $($startY + ($rowCount * $spacingY) + 20))
    $btnOK.BackColor = [System.Drawing.Color]::FromArgb(50, 120, 180)
    $btnOK.ForeColor = [System.Drawing.Color]::White
    $btnOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($btnOK)
    
    # Cancel Button
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Size = New-Object System.Drawing.Size(100, 35)
    $btnCancel.Location = New-Object System.Drawing.Point(410, $($startY + ($rowCount * $spacingY) + 20))
    $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
    $btnCancel.ForeColor = [System.Drawing.Color]::White
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.Controls.Add($btnCancel)
    
    $result = $form.ShowDialog()
    
    if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
        $form.Dispose()
        return $null
    }
    
    # Collect words from textboxes
    $words = @()
    foreach ($txtBox in $textBoxes) {
        $word = $txtBox.Text.Trim().ToLower()
        if ($word) {
            $words += $word
        }
    }
    
    $form.Dispose()
    
    if ($words.Count -ne $WordCount) {
        Write-Host "✗ Expected $WordCount words but got $($words.Count)" -ForegroundColor Red
        return $null
    }
    
    return ($words -join " ")
}

function Generate-CardanoKeypair {
    param(
        [string]$OutputPath = ".\wallets",
        [int]$ExternalAddresses = 5,
        [int]$InternalAddresses = 3
    )
    
    Write-Host "`n========== Multi-Address Generation ==========" -ForegroundColor Cyan
    Write-Host "External addresses (0/i): $ExternalAddresses" -ForegroundColor Yellow
    Write-Host "Internal addresses (1/i): $InternalAddresses" -ForegroundColor Yellow
    
    # Find cardano-address and cardano-cli
    $possibleCardanoAddress = @(".\cardano-address.exe", ".\cardano-address")
    $cardanoAddressExe = $possibleCardanoAddress | Where-Object { Test-Path $_ } | Select-Object -First 1
    
    if (-not $cardanoAddressExe) {
        Write-Host "✗ cardano-address executable not found in script folder." -ForegroundColor Red
        return $null
    }
    
    try {
        $cardanoAddressFull = (Resolve-Path $cardanoAddressExe).Path
    } catch {
        Write-Host "✗ Không thể resolve cardano-address path: $_" -ForegroundColor Red
        return $null
    }
    
    $cardanoCliRel = ".\cardano-cli-win64\cardano-cli.exe"
    if (-not (Test-Path $cardanoCliRel)) {
        Write-Host "✗ cardano-cli not found at $cardanoCliRel" -ForegroundColor Red
        return $null
    }
    
    try {
        $cardanoCliFull = (Resolve-Path $cardanoCliRel).Path
    } catch {
        Write-Host "✗ Không thể resolve cardano-cli path: $_" -ForegroundColor Red
        return $null
    }
    
    Write-Host "Found cardano-address: $cardanoAddressFull" -ForegroundColor Green
    Write-Host "Found cardano-cli: $cardanoCliFull" -ForegroundColor Green
    
    # Create output folder
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath | Out-Null
        Write-Host "✓ Created wallet directory: $OutputPath" -ForegroundColor Green
    }
    
    # Dialog to choose word count
    $formWordCount = New-Object System.Windows.Forms.Form
    $formWordCount.Text = "Select Mnemonic Length"
    $formWordCount.Size = New-Object System.Drawing.Size(400, 250)
    $formWordCount.StartPosition = "CenterScreen"
    $formWordCount.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $formWordCount.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $formWordCount.MaximizeBox = $false
    
    # Label
    $lblChoose = New-Object System.Windows.Forms.Label
    $lblChoose.Text = "Choose mnemonic word count:"
    $lblChoose.AutoSize = $true
    $lblChoose.ForeColor = [System.Drawing.Color]::Cyan
    $lblChoose.Font = New-Object System.Drawing.Font("Arial", 12)
    $lblChoose.Location = New-Object System.Drawing.Point(50, 30)
    $formWordCount.Controls.Add($lblChoose)
    
    # Button 12 words
    $btn12 = New-Object System.Windows.Forms.Button
    $btn12.Text = "12 Words"
    $btn12.Size = New-Object System.Drawing.Size(120, 40)
    $btn12.Location = New-Object System.Drawing.Point(50, 80)
    $btn12.BackColor = [System.Drawing.Color]::FromArgb(50, 120, 180)
    $btn12.ForeColor = [System.Drawing.Color]::White
    $btn12.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
    $btn12.Add_Click({ $formWordCount.Tag = 12; $formWordCount.DialogResult = [System.Windows.Forms.DialogResult]::OK })
    $formWordCount.Controls.Add($btn12)
    
    # Button 15 words
    $btn15 = New-Object System.Windows.Forms.Button
    $btn15.Text = "15 Words"
    $btn15.Size = New-Object System.Drawing.Size(120, 40)
    $btn15.Location = New-Object System.Drawing.Point(190, 80)
    $btn15.BackColor = [System.Drawing.Color]::FromArgb(50, 120, 180)
    $btn15.ForeColor = [System.Drawing.Color]::White
    $btn15.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
    $btn15.Add_Click({ $formWordCount.Tag = 15; $formWordCount.DialogResult = [System.Windows.Forms.DialogResult]::OK })
    $formWordCount.Controls.Add($btn15)
    
    # Button 24 words
    $btn24 = New-Object System.Windows.Forms.Button
    $btn24.Text = "24 Words"
    $btn24.Size = New-Object System.Drawing.Size(120, 40)
    $btn24.Location = New-Object System.Drawing.Point(125, 140)
    $btn24.BackColor = [System.Drawing.Color]::FromArgb(50, 120, 180)
    $btn24.ForeColor = [System.Drawing.Color]::White
    $btn24.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
    $btn24.Add_Click({ $formWordCount.Tag = 24; $formWordCount.DialogResult = [System.Windows.Forms.DialogResult]::OK })
    $formWordCount.Controls.Add($btn24)
    
    $resultWordCount = $formWordCount.ShowDialog()
    $selectedWordCount = $formWordCount.Tag
    $formWordCount.Dispose()
    
    if ($resultWordCount -ne [System.Windows.Forms.DialogResult]::OK) {
        Write-Host "✗ Cancelled by user" -ForegroundColor Red
        return $null
    }
    
    if (-not $selectedWordCount) {
        Write-Host "✗ No word count selected" -ForegroundColor Red
        return $null
    }
    
    # Get mnemonic input
    $mnemonic = Create-MnemonicInput -WordCount $selectedWordCount
    if (-not $mnemonic) {
        Write-Host "✗ Cancelled by user" -ForegroundColor Red
        return $null
    }
    
    # Normalize mnemonic
    $mnemonic = $mnemonic -replace "[\r`n]+", " "
    $mnemonic = ($mnemonic -split '\s+') -join ' '
    $mnemonic = $mnemonic.Trim()
    
    $words = ($mnemonic -split '\s+')
    Write-Host "=== DEBUG MNEMONIC ===" -ForegroundColor Gray
    Write-Host ("Length: {0} chars" -f $mnemonic.Length) -ForegroundColor Gray
    Write-Host ("Words count: {0}" -f $words.Length) -ForegroundColor Gray
    Write-Host "======================" -ForegroundColor Gray
    
    if ($words.Length -lt 12) {
        Write-Host ("✗ Mnemonic seems too short ({0} words)." -f $words.Length) -ForegroundColor Red
        return $null
    }
    
    try {
        # Generate root.xsk
        Write-Host "Generating root.xsk..." -ForegroundColor Yellow
        $rootKey = ($mnemonic | & $cardanoAddressFull key from-recovery-phrase Shelley).Trim()
        
        if (-not $rootKey) {
            Write-Host "✗ rootKey empty" -ForegroundColor Red
            return $null
        }
        
        $rootKeyPath = Join-Path $OutputPath "root.xsk"
        Set-Content -Path $rootKeyPath -Value $rootKey -Encoding ASCII
        
        $networkTag = "mainnet"
        $maxParallel = 6
        $logFile = Join-Path $OutputPath "generation.log"
        "=== Start generation: $(Get-Date -Format u) ===" | Out-File -FilePath $logFile -Encoding utf8
        
        # Job script - accepts pathType parameter
        $jobScript = {
            param(
                $i,
                $pathType,
                $rootKeyPath,
                $OutputPath,
                $cardanoAddressFull,
                $cardanoCliFull,
                $networkTag,
                $logFile
            )
            
            try {
                Add-Content -Path $logFile -Value ("[{0}] Starting {1} index {2}" -f (Get-Date -Format o), $pathType, $i)
                
                $walletFolder = Join-Path $OutputPath "wallet_${pathType}_$i"
                if (-not (Test-Path $walletFolder)) {
                    New-Item -Path $walletFolder -ItemType Directory -Force | Out-Null
                }
                
                $rootContent = (Get-Content -Raw -Path $rootKeyPath).Trim()
                
                # PAYMENT PATH
                if ($pathType -eq "external") {
                    $payPath = "1852H/1815H/0H/0/$i"
                } else {
                    $payPath = "1852H/1815H/0H/1/$i"
                }
                
                $paymentKey = ($rootContent | & $cardanoAddressFull key child $payPath).Trim()
                Set-Content -Path (Join-Path $walletFolder ("addr_$i.xsk")) -Value $paymentKey -Encoding ASCII
                
                $paymentPub = ($paymentKey | & $cardanoAddressFull key public --without-chain-code).Trim()
                Set-Content -Path (Join-Path $walletFolder ("addr_$i.xvk")) -Value $paymentPub -Encoding ASCII
                
                $paymentAddr = ($paymentPub | & $cardanoAddressFull address payment --network-tag $networkTag).Trim()
                Set-Content -Path (Join-Path $walletFolder ("payment_$i.addr")) -Value $paymentAddr -Encoding ASCII
                
                # STAKE PATH
                $stakePath = "1852H/1815H/0H/2/$i"
                $stakeKey = ($rootContent | & $cardanoAddressFull key child $stakePath).Trim()
                Set-Content -Path (Join-Path $walletFolder ("stake_$i.xsk")) -Value $stakeKey -Encoding ASCII
                
                $stakePub = ($stakeKey | & $cardanoAddressFull key public --without-chain-code).Trim()
                Set-Content -Path (Join-Path $walletFolder ("stake_$i.xvk")) -Value $stakePub -Encoding ASCII
                
                $stakeAddr = ($stakePub | & $cardanoAddressFull address stake --network-tag $networkTag).Trim()
                Set-Content -Path (Join-Path $walletFolder ("stake_$i.addr")) -Value $stakeAddr -Encoding ASCII
                
                # DELEGATED ADDRESS
                $delegatedAddr = ($paymentAddr | & $cardanoAddressFull address delegation $stakePub).Trim()
                Set-Content -Path (Join-Path $walletFolder "delegated.addr") -Value $delegatedAddr -Encoding ASCII
                
                # CONVERT PRIVATE KEY TO .SKEY
                $addrXsk = (Get-Content -Raw -Path (Join-Path $walletFolder ("addr_$i.xsk"))).Trim()
                $cleanPath = (Join-Path $walletFolder ("addr_${i}_clean.xsk"))
                Set-Content -Path $cleanPath -Value $addrXsk -Encoding ASCII
                
                $outSkey = (Join-Path $walletFolder "addr.skey")
                $proc = Start-Process -FilePath $cardanoCliFull -ArgumentList @(
                    "key", "convert-cardano-address-key",
                    "--shelley-payment-key",
                    "--signing-key-file", $cleanPath,
                    "--out-file", $outSkey
                ) -NoNewWindow -Wait -PassThru
                
                if ($proc -and $proc.ExitCode -ne 0) {
                    Add-Content -Path $logFile -Value ("[{0}] ⚠ Failed to convert skey for wallet_{1}_{2} (exit {3})" -f (Get-Date -Format o), $pathType, $i, $proc.ExitCode)
                } else {
                    Add-Content -Path $logFile -Value ("[{0}] Converted addr.skey for wallet_{1}_{2}" -f (Get-Date -Format o), $pathType, $i)
                }
                
                Remove-Item -Path $cleanPath -ErrorAction SilentlyContinue
                
                $status = if (Test-Path $outSkey) { 'OK' } else { 'MISSING' }
                Add-Content -Path $logFile -Value ("[{0}] ✓ Created wallet_{1}_{2}/ (delegated: {3}, skey: {4})" -f (Get-Date -Format o), $pathType, $i, $delegatedAddr, $status)
                
                # Append summary
                try {
                    $summaryFile = Join-Path $OutputPath 'delegated_summary.txt'
                    $skeyFull = ''
                    if (Test-Path $outSkey) {
                        try { $skeyFull = (Resolve-Path $outSkey -ErrorAction Stop).Path } catch { $skeyFull = $outSkey }
                    }
                    $summaryLine = "wallet_${pathType}_$i|$delegatedAddr|$skeyFull"
                    [System.IO.File]::AppendAllText($summaryFile, $summaryLine + [Environment]::NewLine, [System.Text.Encoding]::UTF8)
                } catch {
                    Add-Content -Path $logFile -Value ("[{0}] ⚠ Failed to append summary for wallet_{1}_{2}: {3}" -f (Get-Date -Format o), $pathType, $i, $_.Exception.Message)
                }
            } catch {
                $err = $_
                Add-Content -Path $logFile -Value ("[{0}] ERROR {1} index {2}: {3}" -f (Get-Date -Format o), $pathType, $i, $err.ToString())
            }
        }
        
        # Launch jobs for External addresses
        $jobs = @()
        
        if ($ExternalAddresses -gt 0) {
            Write-Host "Creating $ExternalAddresses external addresses..." -ForegroundColor Yellow
            for ($i = 0; $i -lt $ExternalAddresses; $i++) {
                while ((Get-Job -State Running).Count -ge $maxParallel) {
                    Start-Sleep -Milliseconds 200
                }
                
                $job = Start-Job -ScriptBlock $jobScript -ArgumentList @(
                    $i,
                    "external",
                    $rootKeyPath,
                    $OutputPath,
                    $cardanoAddressFull,
                    $cardanoCliFull,
                    $networkTag,
                    $logFile
                )
                $jobs += $job
                Write-Host ("Started job for external index {0} (Id {1})" -f $i, $job.Id) -ForegroundColor Gray
            }
        }
        
        # Launch jobs for Internal addresses
        if ($InternalAddresses -gt 0) {
            Write-Host "Creating $InternalAddresses internal addresses..." -ForegroundColor Yellow
            for ($i = 0; $i -lt $InternalAddresses; $i++) {
                while ((Get-Job -State Running).Count -ge $maxParallel) {
                    Start-Sleep -Milliseconds 200
                }
                
                $job = Start-Job -ScriptBlock $jobScript -ArgumentList @(
                    $i,
                    "internal",
                    $rootKeyPath,
                    $OutputPath,
                    $cardanoAddressFull,
                    $cardanoCliFull,
                    $networkTag,
                    $logFile
                )
                $jobs += $job
                Write-Host ("Started job for internal index {0} (Id {1})" -f $i, $job.Id) -ForegroundColor Gray
            }
        }
        
        # Wait for all jobs
        Write-Host "Waiting for jobs to complete..." -ForegroundColor Yellow
        while ((Get-Job -State Running).Count -gt 0) {
            Start-Sleep -Seconds 1
        }
        
        foreach ($j in $jobs) {
            try {
                Receive-Job -Job $j -ErrorAction SilentlyContinue | Out-Null
            } catch {}
            try { Remove-Job -Job $j -Force -ErrorAction SilentlyContinue } catch {}
        }
        
        Add-Content -Path $logFile -Value ("=== End generation: $(Get-Date -Format u) ===")
        
        # Cleanup root key
        try {
            Remove-Item -Path $rootKeyPath -ErrorAction SilentlyContinue
        } catch {}
        
        Write-Host "" -ForegroundColor Green
        Write-Host "=== MULTI ADDRESS GENERATION DONE ===" -ForegroundColor Green
        Write-Host "Created $ExternalAddresses external + $InternalAddresses internal addresses" -ForegroundColor Green
        Write-Host "Location: $OutputPath" -ForegroundColor Green
        Write-Host "Log: $logFile" -ForegroundColor Green
        
        return @{
            OutputPath = $OutputPath
            ExternalCount = $ExternalAddresses
            InternalCount = $InternalAddresses
            TotalCount = $ExternalAddresses + $InternalAddresses
        }
    }
    catch {
        Write-Host "✗ Error: $_" -ForegroundColor Red
        return $null
    }
}
