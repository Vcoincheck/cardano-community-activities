# ============================================
# MIDNIGHTSIGNERINTEGRATION.PS1 - Recovery Phrase & Key Generation
# ============================================
# Load from recovery phrases, file watchers, queue processing

# Thread-safe queue and watcher for delegated_summary.txt lines
$script:summaryQueue = New-Object System.Collections.ArrayList
$script:queueLock = New-Object Object
$script:summaryOffsets = @{}

function Process-DelegatedSummaryAppend {
    param([string]$SummaryFile, [string]$PhraseFolder)
    try {
        $lines = Get-Content -Path $SummaryFile -ErrorAction Stop
    } catch { return }

    $prev = 0
    if ($script:summaryOffsets.ContainsKey($SummaryFile)) { $prev = [int]$script:summaryOffsets[$SummaryFile] }
    $total = $lines.Count
    if ($total -le $prev) { return }

    $newLines = $lines[$prev..($total - 1)]
    foreach ($ln in $newLines) {
        if ([string]::IsNullOrWhiteSpace($ln)) { continue }
        $parts = $ln -split '\|'
        if ($parts.Count -ge 2) {
            $wallet = $parts[0]
            $addr = $parts[1]
            $delegatedPath = Join-Path $PhraseFolder (Join-Path 'generated_keys' (Join-Path $wallet 'delegated.addr'))
            $obj = [pscustomobject]@{ File = $delegatedPath; Wallet = $wallet; Address = $addr }
            [System.Threading.Monitor]::Enter($script:queueLock)
            try { [void]$script:summaryQueue.Add($obj) } finally { [System.Threading.Monitor]::Exit($script:queueLock) }
        }
    }

    $script:summaryOffsets[$SummaryFile] = $total
}

function Start-DelegatedSummaryWatchers {
    # Register watchers for each phrase folder's delegated_summary.txt
    try {
        $phrases = Get-ChildItem -Path $PSScriptRoot -Directory | Where-Object { $_.Name -match '^phrase\d+$' }
    } catch { return }

    foreach ($pf in $phrases) {
        $folder = $pf.FullName
        $summaryFile = Join-Path $folder 'delegated_summary.txt'

        # If summary exists already, process existing lines
        if (Test-Path $summaryFile) { Process-DelegatedSummaryAppend -SummaryFile $summaryFile -PhraseFolder $folder }

        try {
            $fsw = New-Object System.IO.FileSystemWatcher $folder, 'delegated_summary.txt'
            $fsw.NotifyFilter = [System.IO.NotifyFilters]'LastWrite,FileName'

            Register-ObjectEvent -InputObject $fsw -EventName Changed -Action {
                param($s, $e)
                try { Process-DelegatedSummaryAppend -SummaryFile $e.FullPath -PhraseFolder $s.Path } catch {}
            } | Out-Null

            Register-ObjectEvent -InputObject $fsw -EventName Created -Action {
                param($s, $e)
                try { Process-DelegatedSummaryAppend -SummaryFile $e.FullPath -PhraseFolder $s.Path } catch {}
            } | Out-Null

            $fsw.EnableRaisingEvents = $true
        } catch {}
    }
}

function Load-FromMidnightSigner {
    try {
        # Tìm tất cả phrase folders
        $phraseFolders = Get-ChildItem -Path $PSScriptRoot -Directory | Where-Object { $_.Name -match '^phrase\d+$' }
        
        if (-not $phraseFolders) {
            Write-Log "⚠ No phrase folders found" "Orange"
            
            # Fallback: thử tìm addr.delegated và addr.skey ở root (legacy mode)
            $addrFile = Join-Path $PSScriptRoot "addr.delegated"
            $skeyFile = Join-Path $PSScriptRoot "addr.skey"
            
            if ((Test-Path $addrFile) -and (Test-Path $skeyFile)) {
                Write-Log "Found legacy files in root folder" "Gray"
                
                $addr = (Get-Content $addrFile -Raw -ErrorAction Stop).Trim()
                
                if ([string]::IsNullOrWhiteSpace($addr)) {
                    Write-Log "✗ addr.delegated is empty!" "SoftRed"
                    return $false
                }
                
                if (-not $addr.StartsWith("addr1")) {
                    Write-Log "⚠ Address format may be invalid: $addr" "Orange"
                }
                
                if ($script:addressPanels.Count -eq 0) { Add-AddressPanel }
                
                $firstPanel = $script:addressPanels[0]
                $firstPanel.TextBoxOriginal.Text = $addr
                
                try {
                    $fullSkeyPath = (Resolve-Path $skeyFile -ErrorAction Stop).Path
                    $firstPanel.TextBoxSkey.Text = $fullSkeyPath
                    Write-Log "✓ Legacy Mode: Loaded $($addr.Substring(0,20))..." "Green"
                    return $true
                } catch {
                    $firstPanel.TextBoxSkey.Text = $skeyFile
                    Write-Log "✓ Legacy Mode: Loaded (relative path)" "Green"
                    return $true
                }
            }
            
            return $false
        }

        # Sắp xếp và lấy phrase folder mới nhất
        $latestPhraseFolder = $phraseFolders | Sort-Object { [int]($_.Name -replace 'phrase','') } -Descending | Select-Object -First 1
        $generatedKeysPath = Join-Path $latestPhraseFolder.FullName "generated_keys"

        if (-not (Test-Path $generatedKeysPath)) {
            Write-Log "⚠ No generated_keys folder in $($latestPhraseFolder.Name)" "Orange"
            Write-Log "⏳ Please run Multi-Address Script first" "Yellow"
            return $false
        }

        Write-Log "📂 Scanning $($latestPhraseFolder.Name)/generated_keys..." "Blue"

        # Tìm tất cả wallet folders (external và internal)
        $walletFolders = Get-ChildItem -Path $generatedKeysPath -Directory | Where-Object { 
            $_.Name -match '^wallet_(external|internal)_\d+$' 
        } | Sort-Object Name

        if ($walletFolders.Count -eq 0) {
            Write-Log "⚠ No wallet folders found" "Orange"
            return $false
        }

        Write-Log "✓ Found $($walletFolders.Count) wallet(s)" "Green"

        # Đảm bảo có đủ panels
        $neededPanels = $walletFolders.Count
        while ($script:addressPanels.Count -lt $neededPanels) {
            Add-AddressPanel
        }

        # Load từng wallet vào panel
        $loadedCount = 0
        for ($i = 0; $i -lt $walletFolders.Count; $i++) {
            $wallet = $walletFolders[$i]
            $delegatedFile = Join-Path $wallet.FullName "delegated.addr"
            $skeyFile = Join-Path $wallet.FullName "addr.skey"

            # Kiểm tra files tồn tại
            if (-not (Test-Path $delegatedFile)) {
                Write-Log "⚠ Missing delegated.addr in $($wallet.Name)" "Orange"
                continue
            }

            if (-not (Test-Path $skeyFile)) {
                Write-Log "⚠ Missing addr.skey in $($wallet.Name)" "Orange"
                continue
            }

            try {
                # Đọc địa chỉ
                $addr = (Get-Content $delegatedFile -Raw -ErrorAction Stop).Trim()
                
                if ([string]::IsNullOrWhiteSpace($addr)) {
                    Write-Log "⚠ Empty delegated.addr in $($wallet.Name)" "Orange"
                    continue
                }

                # Validate địa chỉ Cardano
                if (-not $addr.StartsWith("addr1")) {
                    Write-Log "⚠ Invalid address format in $($wallet.Name)" "Orange"
                }

                # Lấy panel tương ứng
                $panel = $script:addressPanels[$i]
                
                # Fill địa chỉ
                $panel.TextBoxOriginal.Text = $addr

                # Fill skey path (prefer absolute path)
                try {
                    $fullSkeyPath = (Resolve-Path $skeyFile -ErrorAction Stop).Path
                    $panel.TextBoxSkey.Text = $fullSkeyPath
                } catch {
                    $panel.TextBoxSkey.Text = $skeyFile
                }

                # Parse wallet name để hiển thị thông tin rõ ràng
                if ($wallet.Name -match '^wallet_(external|internal)_(\d+)$') {
                    $type = $matches[1]
                    $index = $matches[2]
                    $typeLabel = if ($type -eq "external") { "0/$index" } else { "1/$index" }
                    $typeColor = if ($type -eq "external") { "Green" } else { "Purple" }
                    
                    Write-Log "✓ Panel #$($i+1) [$typeLabel]: $($addr.Substring(0,20))..." $typeColor
                } else {
                    Write-Log "✓ Panel #$($i+1): $($wallet.Name) - $($addr.Substring(0,20))..." "Green"
                }

                $loadedCount++

            } catch {
                Write-Log "✗ Error loading $($wallet.Name): $($_.Exception.Message)" "SoftRed"
                continue
            }
        }

        if ($loadedCount -eq 0) {
            Write-Log "✗ No wallets loaded successfully" "SoftRed"
            return $false
        }

        Write-Log "================================================" "Blue"
        Write-Log "✓ Successfully loaded $loadedCount wallet(s) from $($latestPhraseFolder.Name)" "Green"
        Write-Log "   External (0/X): $(($walletFolders | Where-Object { $_.Name -match 'external' }).Count)" "Green"
        Write-Log "   Internal (1/X): $(($walletFolders | Where-Object { $_.Name -match 'internal' }).Count)" "Purple"
        Write-Log "================================================" "Blue"
        
        return $true

    } catch {
        Write-Log "✗ Auto-fill error: $($_.Exception.Message)" "SoftRed"
        return $false
    }
}

function Invoke-RecoveryPhraseAuto {
    param($TxtRecovery, $BtnEnterRecovery)
    
    $recoveryText = $TxtRecovery.Text.Trim()
    
    if ([string]::IsNullOrWhiteSpace($recoveryText)) { 
        [System.Windows.Forms.MessageBox]::Show(
            "Please enter your recovery phrase!",
            "Warning",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        return 
    }
    
    # Validate recovery phrase (15 hoặc 24 từ)
    $words = $recoveryText.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
    if ($words.Count -ne 12 -and $words.Count -ne 15 -and $words.Count -ne 24) {
        $result = [System.Windows.Forms.MessageBox]::Show(
            "Recovery phrase should be 12,15,24 words. You entered $($words.Count) words.`n`nContinue anyway?",
            "Warning",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
            return
        }
    }
    
    Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Blue"
    Write-Log "🔑 Processing recovery phrase..." "Yellow"
    
    # Lưu phrase vào file
    $phraseFile = Join-Path $PSScriptRoot "phrase.prv"
    try {
        Set-Content -Path $phraseFile -Value $recoveryText -Force -Encoding UTF8
        Write-Log "✓ Recovery phrase saved to phrase.prv" "Green"
    } catch {
        Write-Log "✗ Failed to save phrase: $($_.Exception.Message)" "SoftRed"
        return
    }
    
    # Kiểm tra script tồn tại
    $scriptPath = Join-Path $PSScriptRoot "midnightsigninfo.ps1"
    if (-not (Test-Path $scriptPath)) {
        Write-Log "✗ midnightsigninfo.ps1 not found!" "SoftRed"
        [System.Windows.Forms.MessageBox]::Show(
            "midnightsigninfo.ps1 not found in script folder!",
            "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        return
    }
    
    # Disable button
    $BtnEnterRecovery.Enabled = $false
    $originalText = $BtnEnterRecovery.Text
    $BtnEnterRecovery.Text = "⏳"
    
    Write-Log "⏳ Generating keys from recovery phrase..." "Yellow"
    Write-Log "   (This may take 10-30 seconds, please wait)" "Gray"
    
    try {
        # Chạy script và đợi
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell.exe"
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
        $psi.UseShellExecute = $true
        $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
        
        $process = [System.Diagnostics.Process]::Start($psi)
        $process.WaitForExit()
        
        $exitCode = $process.ExitCode
        
        # Restore button
        $BtnEnterRecovery.Text = $originalText
        $BtnEnterRecovery.Enabled = $true
        
        if ($exitCode -eq 0) {
            Write-Log "✓ Key generation completed!" "Green"
            
            # Đợi file system sync
            Start-Sleep -Milliseconds 1500
            
            # Auto-load vào panel
            Write-Log "⏳ Loading generated keys into form..." "Yellow"
            $success = Load-FromMidnightSigner
            
            if ($success) {
                Write-Log "✓ Keys loaded successfully!" "Green"
                Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Blue"
                
                [System.Windows.Forms.MessageBox]::Show(
                    "Keys generated and loaded successfully!",
                    "Success",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Information
                )
            } else {
                Write-Log "⚠ Keys generated but failed to load into form" "Orange"
                Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Blue"
            }
            
        } else {
            Write-Log "✗ Key generation failed (exit code: $exitCode)" "SoftRed"
            Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Blue"
            
            [System.Windows.Forms.MessageBox]::Show(
                "Key generation failed!`nPlease check the recovery phrase.",
                "Error",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
        
    } catch {
        $BtnEnterRecovery.Text = $originalText
        $BtnEnterRecovery.Enabled = $true
        
        Write-Log "✗ Error running signer: $($_.Exception.Message)" "SoftRed"
        Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Blue"
    }
}

function Invoke-RecoveryPhraseManual {
    param($TxtRecovery)
    
    $recoveryText = $TxtRecovery.Text.Trim()
    
    if ([string]::IsNullOrWhiteSpace($recoveryText)) { 
        [System.Windows.Forms.MessageBox]::Show(
            "Please enter your recovery phrase!",
            "Warning",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        return 
    }
    
    # Validate recovery phrase (12, 15 hoặc 24 từ)
    $words = $recoveryText.Split(' ', [System.StringSplitOptions]::RemoveEmptyEntries)
    if ($words.Count -ne 12 -and $words.Count -ne 15 -and $words.Count -ne 24) {
        $result = [System.Windows.Forms.MessageBox]::Show(
            "Recovery phrase should be 12, 15, or 24 words. You entered $($words.Count) words`n`nContinue anyway?",
            "Warning",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
            return
        }
    }
    
    Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Blue"
    Write-Log "🔧 Preparing Manual GUI..." "Yellow"
    
    # Tìm folder phraseX tiếp theo
    $phraseIndex = 1
    while (Test-Path (Join-Path $PSScriptRoot "phrase$phraseIndex")) {
        $phraseIndex++
    }
    
    $phraseFolder = Join-Path $PSScriptRoot "phrase$phraseIndex"
    
    try {
        # Tạo thư mục phraseX
        New-Item -Path $phraseFolder -ItemType Directory -Force | Out-Null
        Write-Log "✓ Created folder: phrase$phraseIndex" "Green"
        
        # Lưu phrase.prv vào thư mục phraseX
        $phraseFile = Join-Path $phraseFolder "phrase.prv"
        Set-Content -Path $phraseFile -Value $recoveryText -Force -Encoding UTF8
        Write-Log "✓ Saved phrase.prv to phrase$phraseIndex/" "Green"
        
    } catch {
        Write-Log "✗ Failed to create phrase folder: $($_.Exception.Message)" "SoftRed"
        return
    }
    
    # Kiểm tra script GUI tồn tại
    $guiScriptPath = Join-Path $PSScriptRoot "midnightsign_gui_v1.ps1"
    if (-not (Test-Path $guiScriptPath)) {
        Write-Log "✗ midnightsign_gui_v1.ps1 not found!" "SoftRed"
        [System.Windows.Forms.MessageBox]::Show(
            "midnightsign_gui_v1.ps1 not found in script folder!",
            "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
        return
    }
    
    Write-Log "⏳ Launching Manual GUI for phrase$phraseIndex..." "Yellow"
    
    try {
        # Chạy GUI script với working directory = phraseFolder
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "powershell.exe"
        $psi.Arguments = "-NoProfile -ExecutionPolicy Bypass -File `"$guiScriptPath`""
        $psi.WorkingDirectory = $phraseFolder  # Set working directory
        $psi.UseShellExecute = $true
        $psi.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Normal
        
        $process = [System.Diagnostics.Process]::Start($psi)
        
        Write-Log "✓ Manual GUI launched for phrase$phraseIndex" "Green"
        Write-Log "   (Waiting for user to complete operations...)" "Gray"
        
        # Đợi GUI window đóng
        $process.WaitForExit()
        
        Write-Log "✓ Manual GUI closed" "Green"
        Write-Log "⏳ Scanning for generated keys in phrase$phraseIndex/generated_keys..." "Yellow"
        Start-Sleep -Milliseconds 1500
        
        $generatedKeysPath = Join-Path $phraseFolder "generated_keys"
        
        if (-not (Test-Path $generatedKeysPath)) {
            Write-Log "ℹ No generated_keys folder found in phrase$phraseIndex" "Gray"
            Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Blue"
            [System.Windows.Forms.MessageBox]::Show(
                "No keys were generated in phrase$phraseIndex folder.",
                "Info",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
            return
        }

        # Scan multiple times with increasing wait, always collect ALL files found
        Write-Log "⏳ Scanning for all delegated.addr files (10 passes, 2 sec intervals)..." "Yellow"
        
        $allFoundFiles = @()
        $maxFound = 0
        
        # Do 10 full scans with 2-second delays, collecting all files
        for ($scanPass = 1; $scanPass -le 10; $scanPass++) {
            $currentScan = @(Get-ChildItem -Path $generatedKeysPath -Filter "delegated.addr" -File -Recurse -ErrorAction SilentlyContinue)
            $scanCount = $currentScan.Count
            Write-Log "   Pass $scanPass : Found $scanCount file(s)" "Gray"
            
            if ($scanCount -gt $maxFound) {
                $maxFound = $scanCount
                Write-Log "      → New maximum: $maxFound files" "Blue"
            }
            
            # Add all files from this scan to the collection
            foreach ($file in $currentScan) {
                $allFoundFiles += $file
            }
            
            if ($scanPass -lt 10) {
                Start-Sleep -Milliseconds 2000
            }
        }

        # Remove duplicates (same full path) and sort
        $addrFiles = @($allFoundFiles | Sort-Object FullName -Unique)
        $foundCount = $addrFiles.Count
        
        Write-Log "✓ Total unique files collected: $foundCount (max in single pass: $maxFound)" "Green"

        if ($foundCount -eq 0) {
            Write-Log "✗ No delegated.addr files found" "SoftRed"
            Write-Log "  Path checked: $generatedKeysPath" "Gray"
            Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Blue"
            [System.Windows.Forms.MessageBox]::Show(
                "No delegated.addr files found in: `n$generatedKeysPath",
                "Info",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Information
            )
            return
        }

        Write-Log "✓ Found $foundCount delegated.addr file(s)" "Green"
        foreach ($f in $addrFiles) { 
            Write-Log "   - $($f.FullName)" "Gray"
        }

        # Show selection dialog
        Write-Log "📋 Opening address selection dialog..." "Yellow"
        $selectedAddresses = Show-AddressSelectionDialog -DelegatedFiles $addrFiles
        
        if ($selectedAddresses.Count -eq 0) {
            Write-Log "ℹ No addresses selected" "Gray"
            Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Blue"
            return
        }

        Write-Log "✓ User selected $($selectedAddresses.Count) address(es)" "Green"

        # Populate panels with selected addresses
        $success = Populate-PanelsFromSelected -SelectedAddresses $selectedAddresses
        
        if (-not $success) {
            Write-Log "ℹ Failed to load addresses into panels" "Gray"
            Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Blue"
            return
        }

        Write-Log "✓ Successfully loaded addresses into panels" "Green"
        Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Blue"
        
    } catch {
        Write-Log "✗ Error: $($_.Exception.Message)" "SoftRed"
        Write-Log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" "Blue"
    }
}
