# ============================================
# END-USER-APP: Multi-Address Keygen
# ============================================
# Generate multi-address wallet from mnemonic (like midnightsigninformulti_v1)

Add-Type -AssemblyName System.Windows.Forms

# Load BIP39 wordlist
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
    
    # Find cardano-address and cardano-cli
    $cardanoAddressExe = $null
    @(".\tools\cardano-addresses\cardano-address", ".\tools\cardano-addresses\cardano-address.exe", ".\cardano-address", ".\cardano-address.exe") | ForEach-Object {
        if (Test-Path $_) { $cardanoAddressExe = (Resolve-Path $_).Path; return }
    }
    
    $cardanoCliExe = $null
    @(".\tools\cardano-cli\cardano-cli", ".\tools\cardano-cli\cardano-cli.exe", ".\cardano-cli-win64\cardano-cli.exe") | ForEach-Object {
        if (Test-Path $_) { $cardanoCliExe = (Resolve-Path $_).Path; return }
    }
    
    if (-not $cardanoAddressExe) {
        Write-Host "✗ cardano-address not found" -ForegroundColor Red
        return $null
    }
    
    if (-not $cardanoCliExe) {
        Write-Host "✗ cardano-cli not found" -ForegroundColor Red
        return $null
    }
    
    Write-Host "Using cardano-address: $cardanoAddressExe" -ForegroundColor Yellow
    Write-Host "Using cardano-cli: $cardanoCliExe" -ForegroundColor Yellow
    
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
    
    # Normalize mnemonic (just validate, already trimmed from dialog)
    $mnemonic = $mnemonic.Trim()
    $words = ($mnemonic -split '\s+')
    
    Write-Host "✓ Mnemonic: $($words.Count) words" -ForegroundColor Green
    
    try {
        # Generate root key
        Write-Host "Generating root key..." -ForegroundColor Yellow
        $rootKey = ($mnemonic | & $cardanoAddressExe key from-recovery-phrase Shelley).Trim()
        
        if (-not $rootKey) {
            Write-Host "✗ Failed to generate root key" -ForegroundColor Red
            return $null
        }
        
        $tempRootPath = Join-Path $OutputPath "root.xsk"
        Set-Content -Path $tempRootPath -Value $rootKey -Encoding ASCII
        
        # Generate addresses
        $addresses = @()
        $networkTag = "mainnet"
        
        # External addresses (0/i)
        Write-Host "Generating $ExternalAddresses external addresses..." -ForegroundColor Yellow
        for ($i = 0; $i -lt $ExternalAddresses; $i++) {
            $walletFolder = Join-Path $OutputPath "wallet_external_$i"
            if (-not (Test-Path $walletFolder)) {
                New-Item -Path $walletFolder -ItemType Directory -Force | Out-Null
            }
            
            # Payment key derivation
            $paymentPath = "1852H/1815H/0H/0/$i"
            $paymentKey = ($rootKey | & $cardanoAddressExe key child $paymentPath).Trim()
            
            $paymentPub = ($paymentKey | & $cardanoAddressExe key public --without-chain-code).Trim()
            $paymentAddr = ($paymentPub | & $cardanoAddressExe address payment --network-tag $networkTag).Trim()
            
            # Stake key derivation
            $stakePath = "1852H/1815H/0H/2/$i"
            $stakeKey = ($rootKey | & $cardanoAddressExe key child $stakePath).Trim()
            
            $stakePub = ($stakeKey | & $cardanoAddressExe key public --without-chain-code).Trim()
            $delegatedAddr = ($paymentAddr | & $cardanoAddressExe address delegation $stakePub).Trim()
            
            # Save files
            Set-Content -Path (Join-Path $walletFolder "payment.addr") -Value $paymentAddr -Encoding ASCII
            Set-Content -Path (Join-Path $walletFolder "delegated.addr") -Value $delegatedAddr -Encoding ASCII
            Set-Content -Path (Join-Path $walletFolder "addr.xsk") -Value $paymentKey -Encoding ASCII
            
            $addresses += @{
                Type = "external"
                Index = $i
                PaymentAddr = $paymentAddr
                DelegatedAddr = $delegatedAddr
                Path = $walletFolder
            }
            
            Write-Host "  ✓ external_$i" -ForegroundColor Green
        }
        
        # Internal addresses (1/i)
        Write-Host "Generating $InternalAddresses internal addresses..." -ForegroundColor Yellow
        for ($i = 0; $i -lt $InternalAddresses; $i++) {
            $walletFolder = Join-Path $OutputPath "wallet_internal_$i"
            if (-not (Test-Path $walletFolder)) {
                New-Item -Path $walletFolder -ItemType Directory -Force | Out-Null
            }
            
            # Payment key derivation
            $paymentPath = "1852H/1815H/0H/1/$i"
            $paymentKey = ($rootKey | & $cardanoAddressExe key child $paymentPath).Trim()
            
            $paymentPub = ($paymentKey | & $cardanoAddressExe key public --without-chain-code).Trim()
            $paymentAddr = ($paymentPub | & $cardanoAddressExe address payment --network-tag $networkTag).Trim()
            
            # Stake key derivation
            $stakePath = "1852H/1815H/0H/2/$i"
            $stakeKey = ($rootKey | & $cardanoAddressExe key child $stakePath).Trim()
            
            $stakePub = ($stakeKey | & $cardanoAddressExe key public --without-chain-code).Trim()
            $delegatedAddr = ($paymentAddr | & $cardanoAddressExe address delegation $stakePub).Trim()
            
            # Save files
            Set-Content -Path (Join-Path $walletFolder "payment.addr") -Value $paymentAddr -Encoding ASCII
            Set-Content -Path (Join-Path $walletFolder "delegated.addr") -Value $delegatedAddr -Encoding ASCII
            Set-Content -Path (Join-Path $walletFolder "addr.xsk") -Value $paymentKey -Encoding ASCII
            
            $addresses += @{
                Type = "internal"
                Index = $i
                PaymentAddr = $paymentAddr
                DelegatedAddr = $delegatedAddr
                Path = $walletFolder
            }
            
            Write-Host "  ✓ internal_$i" -ForegroundColor Green
        }
        
        # Cleanup
        Remove-Item -Path $tempRootPath -ErrorAction SilentlyContinue
        
        Write-Host "✓ Multi-address generation complete!" -ForegroundColor Green
        Write-Host "Generated: $($ExternalAddresses + $InternalAddresses) addresses" -ForegroundColor Green
        Write-Host "Location: $OutputPath" -ForegroundColor Green
        
        return @{
            Addresses = $addresses
            OutputPath = $OutputPath
            Count = $addresses.Count
        }
    }
    catch {
        Write-Host "✗ Error: $_" -ForegroundColor Red
        return $null
    }
}
