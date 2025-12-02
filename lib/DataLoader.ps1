# ============================================
# DATALOADER.PS1 - File Scanning & Data Loading
# ============================================
# Parse logs, scan delegated files, show selection dialogs

function Show-AddressSelectionDialog {
    param([array]$DelegatedFiles)
    
    $addressList = @()
    
    # Ensure DelegatedFiles is treated as array
    if ($null -eq $DelegatedFiles) { return @() }
    if ($DelegatedFiles -is [string]) { $DelegatedFiles = @($DelegatedFiles) }
    
    Write-Log "DEBUG: Processing $($DelegatedFiles.Count) delegated.addr file(s)" "Gray"
    
    foreach ($f in $DelegatedFiles) {
        try {
            $filePath = if ($f -is [string]) { $f } else { $f.FullName }
            Write-Log "DEBUG: Reading $filePath" "Gray"
            
            $addr = (Get-Content -Path $filePath -ErrorAction SilentlyContinue).Trim()
            if ($addr) {
                $walletName = if ($f -is [string]) { 
                    Split-Path -Parent $f | Split-Path -Leaf 
                } else { 
                    Split-Path -Parent $f.FullName | Split-Path -Leaf 
                }
                
                $addressList += [PSCustomObject]@{
                    Address = $addr
                    File = $filePath
                    WalletName = $walletName
                }
                Write-Log "DEBUG: Added address from $walletName" "Gray"
            }
        } catch {
            Write-Log "DEBUG: Error reading file: $($_.Exception.Message)" "Gray"
        }
    }

    Write-Log "DEBUG: Total addresses loaded: $($addressList.Count)" "Gray"
    
    if ($addressList.Count -eq 0) { return @() }

    # Create selection form
    $selectionForm = New-Object System.Windows.Forms.Form
    $selectionForm.Text = "Select Addresses to Load"
    $selectionForm.Width = 700
    $selectionForm.Height = 450
    $selectionForm.StartPosition = "CenterScreen"
    $selectionForm.FormBorderStyle = "FixedDialog"
    $selectionForm.MaximizeBox = $false

    # Instruction label
    $lblInstr = New-Object System.Windows.Forms.Label
    $lblInstr.Location = New-Object System.Drawing.Point(10, 10)
    $lblInstr.Size = New-Object System.Drawing.Size(680, 30)
    $lblInstr.Text = "Select addresses to load into panels (check/uncheck):"
    $lblInstr.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $selectionForm.Controls.Add($lblInstr)

    # CheckedListBox for addresses
    $listBox = New-Object System.Windows.Forms.CheckedListBox
    $listBox.Location = New-Object System.Drawing.Point(10, 45)
    $listBox.Size = New-Object System.Drawing.Size(680, 300)
    $listBox.Font = New-Object System.Drawing.Font("Consolas", 9)
    
    foreach ($item in $addressList) {
        $display = "$($item.Address.Substring(0,30))...  [$($item.WalletName)]"
        $listBox.Items.Add($display, $true) | Out-Null
    }
    
    Write-Log "DEBUG: ListBox contains $($listBox.Items.Count) items" "Gray"
    
    $selectionForm.Controls.Add($listBox)

    # Buttons
    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Location = New-Object System.Drawing.Point(520, 360)
    $btnOk.Size = New-Object System.Drawing.Size(80, 35)
    $btnOk.Text = "OK"
    $btnOk.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $selectionForm.Controls.Add($btnOk)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Location = New-Object System.Drawing.Point(610, 360)
    $btnCancel.Size = New-Object System.Drawing.Size(80, 35)
    $btnCancel.Text = "Cancel"
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $selectionForm.Controls.Add($btnCancel)

    $selectionForm.AcceptButton = $btnOk
    $selectionForm.CancelButton = $btnCancel

    $result = $selectionForm.ShowDialog()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $selected = @()
        Write-Log "DEBUG: Checking listbox selection ($($listBox.Items.Count) total items)" "Gray"
        
        for ($i = 0; $i -lt $listBox.Items.Count; $i++) {
            if ($listBox.GetItemChecked($i)) {
                $selected += $addressList[$i]
                Write-Log "DEBUG: Selected item $i - $($addressList[$i].WalletName)" "Gray"
            }
        }
        
        Write-Log "DEBUG: Total selected: $($selected.Count)" "Gray"
        $selectionForm.Dispose()
        return $selected
    }
    
    $selectionForm.Dispose()
    return @()
}

function Scan-DelegatedFilesFast {
    param([string]$PhraseFolder)

    $results = @()
    if (-not (Test-Path $PhraseFolder)) { return $results }

    $genRoot = Join-Path $PhraseFolder 'generated_keys'
    if (-not (Test-Path $genRoot)) { return $results }

    try {
        # Use .NET enumerator for speed (returns filenames fast without creating FileInfo objects)
        $files = [System.IO.Directory]::EnumerateFiles($genRoot, 'delegated.addr', [System.IO.SearchOption]::AllDirectories)
        foreach ($f in $files) {
            $wallet = Split-Path (Split-Path $f -Parent) -Leaf
            $results += [pscustomobject]@{ File = $f; Wallet = $wallet; Address = '' }
        }
    } catch {
        Write-Log "Scan error: $($_.Exception.Message)" "Yellow"
    }

    return $results
}

function Parse-GenerationLog {
    param([string]$LogPath)
    $entries = @()
    if (-not (Test-Path $LogPath)) { return $entries }

    try {
        $lines = Get-Content -Path $LogPath -ErrorAction Stop
        foreach ($ln in $lines) {
            # Match lines exactly like:
            # [timestamp] ✓ Created wallet_6/ (delegated: addr1..., skey: OK)
            if ($ln -match '^(?:\[.*?\]\s*)?(?:✓\s*)?Created\s+wallet_(\d+)/\s*\(delegated:\s*([^,\)]+),\s*skey:\s*([^\)]+)\)') {
                $idx = $matches[1]
                $addr = $matches[2].Trim()
                $entries += [pscustomobject]@{ Index = [int]$idx; Address = $addr }
            }
        }

        # deduplicate by index keeping first occurrence
        $uniq = @{}
        $out = @()
        foreach ($e in $entries) {
            if (-not $uniq.ContainsKey($e.Index)) {
                $uniq[$e.Index] = $true
                $out += $e
            }
        }
        return $out
    } catch {
        Write-Log "Failed parsing generation.log: $($_.Exception.Message)" "Yellow"
        return @()
    }
}

function Show-LogScanDialog {
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.Description = 'Select the phrase folder containing generation.log (e.g. phrase4)'
    $fbd.ShowNewFolderButton = $false
    try {
        $pf = Get-ChildItem -Path $PSScriptRoot -Directory | Where-Object { $_.Name -match '^phrase\d+$' } | Sort-Object { [int]($_.Name -replace 'phrase','') } -Descending | Select-Object -First 1
        if ($pf) { $fbd.SelectedPath = $pf.FullName }
    } catch {}
    if ($fbd.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { return $false }
    $chosen = $fbd.SelectedPath

    $logFile = Join-Path $chosen 'generation.log'
    if (-not (Test-Path $logFile)) {
        [System.Windows.Forms.MessageBox]::Show("generation.log not found in selected folder.", "Log Scan", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return $false
    }

    $entries = Parse-GenerationLog -LogPath $logFile
    if ($entries.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No created-wallet entries found in generation.log.", "Log Scan", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return $false
    }

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Load From generation.log"
    $form.Width = 800
    $form.Height = 500
    $form.StartPosition = 'CenterScreen'

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Location = New-Object System.Drawing.Point(10,10)
    $lbl.Size = New-Object System.Drawing.Size(760,20)
    $lbl.Text = "Found $($entries.Count) entries in generation.log. Select which to load."
    $form.Controls.Add($lbl)

    $list = New-Object System.Windows.Forms.CheckedListBox
    $list.Location = New-Object System.Drawing.Point(10,40)
    $list.Size = New-Object System.Drawing.Size(760,360)
    $list.Font = New-Object System.Drawing.Font('Consolas',9)

    foreach ($e in $entries) {
        $display = "wallet_$($e.Index)    $($e.Address)"
        $list.Items.Add($display, $true) | Out-Null
    }
    $form.Controls.Add($list)

    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Location = New-Object System.Drawing.Point(600,410)
    $btnOk.Size = New-Object System.Drawing.Size(80,30)
    $btnOk.Text = 'OK'
    $btnOk.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($btnOk)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Location = New-Object System.Drawing.Point(690,410)
    $btnCancel.Size = New-Object System.Drawing.Size(80,30)
    $btnCancel.Text = 'Cancel'
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.Controls.Add($btnCancel)

    $form.AcceptButton = $btnOk
    $form.CancelButton = $btnCancel

    $res = $form.ShowDialog()
    if ($res -ne [System.Windows.Forms.DialogResult]::OK) { $form.Dispose(); return $false }

    $selected = @()
    for ($i=0; $i -lt $list.Items.Count; $i++) {
        if ($list.GetItemChecked($i)) {
            $entry = $entries[$i]
            $delegatedPath = Join-Path $chosen (Join-Path 'generated_keys' (Join-Path ("wallet_$($entry.Index)") 'delegated.addr'))
            $selected += [pscustomobject]@{ File = $delegatedPath; Wallet = "wallet_$($entry.Index)"; Address = $entry.Address }
        }
    }

    $form.Dispose()

    if ($selected.Count -eq 0) { Write-Log "No entries selected from generation.log." "Gray"; return $false }

    $ok = Populate-PanelsFromSelected -SelectedAddresses $selected
    if ($ok) { Write-Log "Loaded $($selected.Count) address(es) from generation.log" "Green" }
    return $ok
}

function Show-RescanDialog {
    # Let user choose a folder (prefer phrase* folder). Use FolderBrowserDialog for simplicity.
    $fbd = New-Object System.Windows.Forms.FolderBrowserDialog
    $fbd.Description = 'Select the phrase folder that contains generated_keys (e.g. phrase12)'
    $fbd.ShowNewFolderButton = $false
    try {
        $pf = Get-ChildItem -Path $PSScriptRoot -Directory | Where-Object { $_.Name -match '^phrase\d+$' } | Sort-Object { [int]($_.Name -replace 'phrase','') } -Descending | Select-Object -First 1
        if ($pf) { $fbd.SelectedPath = $pf.FullName }
    } catch {}

    if ($fbd.ShowDialog() -ne [System.Windows.Forms.DialogResult]::OK) { return $false }
    $chosen = $fbd.SelectedPath

    # Fast enumerate delegated.addr files
    $items = Scan-DelegatedFilesFast -PhraseFolder $chosen
    if ($items.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No delegated.addr files found under selected folder's generated_keys.", "Rescan", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        return $false
    }

    # Build selection form
    $selForm = New-Object System.Windows.Forms.Form
    $selForm.Text = "Rescan - Select delegated.addr files"
    $selForm.Width = 800
    $selForm.Height = 500
    $selForm.StartPosition = 'CenterScreen'
    $selForm.FormBorderStyle = 'Sizable'

    $lbl = New-Object System.Windows.Forms.Label
    $lbl.Location = New-Object System.Drawing.Point(10,10)
    $lbl.Size = New-Object System.Drawing.Size(760,20)
    $lbl.Text = "Found $($items.Count) delegated.addr file(s). Select which to load (reading addresses only for selected)."
    $selForm.Controls.Add($lbl)

    $list = New-Object System.Windows.Forms.CheckedListBox
    $list.Location = New-Object System.Drawing.Point(10,40)
    $list.Size = New-Object System.Drawing.Size(760,360)
    $list.Font = New-Object System.Drawing.Font('Consolas',9)

    for ($i=0; $i -lt $items.Count; $i++) {
        $it = $items[$i]
        $display = "[$($it.Wallet)]  $($it.File)"
        $list.Items.Add($display, $true) | Out-Null
    }
    $selForm.Controls.Add($list)

    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Location = New-Object System.Drawing.Point(600,410)
    $btnOk.Size = New-Object System.Drawing.Size(80,30)
    $btnOk.Text = 'OK'
    $btnOk.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $selForm.Controls.Add($btnOk)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Location = New-Object System.Drawing.Point(690,410)
    $btnCancel.Size = New-Object System.Drawing.Size(80,30)
    $btnCancel.Text = 'Cancel'
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $selForm.Controls.Add($btnCancel)

    $selForm.AcceptButton = $btnOk
    $selForm.CancelButton = $btnCancel

    $res = $selForm.ShowDialog()
    if ($res -ne [System.Windows.Forms.DialogResult]::OK) { $selForm.Dispose(); return $false }

    # Collect selected items and read their addresses
    $selected = @()
    for ($i=0; $i -lt $list.Items.Count; $i++) {
        if ($list.GetItemChecked($i)) {
            $obj = $items[$i]
            try {
                $addr = (Get-Content -Path $obj.File -ErrorAction Stop).Trim()
            } catch { $addr = '' }
            if ($addr) { $selected += [pscustomobject]@{ File = $obj.File; Wallet = $obj.Wallet; Address = $addr } }
        }
    }

    $selForm.Dispose()

    if ($selected.Count -eq 0) { Write-Log "No addresses selected after rescan." "Gray"; return $false }

    # Populate panels from selected addresses
    $ok = Populate-PanelsFromSelected -SelectedAddresses $selected
    if ($ok) { Write-Log "Rescan loaded $($selected.Count) address(es)." "Green" }
    return $ok
}

function Populate-PanelsFromSelected {
    param([array]$SelectedAddresses)
    
    if ($SelectedAddresses.Count -eq 0) {
        Write-Log "ℹ No addresses were selected" "Gray"
        return $false
    }

    if (-not $script:addressPanels) { $script:addressPanels = @() }

    $panelIndex = 0
    foreach ($item in $SelectedAddresses) {
        try {
            $address = $item.Address
            # support multiple property names for file path
            $filePath = $null
            if ($item.PSObject.Properties.Name -contains 'File') { $filePath = $item.File }
            elseif ($item.PSObject.Properties.Name -contains 'FullPath') { $filePath = $item.FullPath }
            elseif ($item.PSObject.Properties.Name -contains 'Path') { $filePath = $item.Path }
            else { $filePath = $null }

            $skeyFile = $null
            if ($filePath) { $skeyFile = Join-Path (Split-Path -Parent $filePath) "addr.skey" }

            while ($panelIndex -ge $script:addressPanels.Count) {
                Add-AddressPanel
            }

            $panel = $script:addressPanels[$panelIndex]
            if (-not $panel -or -not $panel.TextBoxOriginal) { continue }

            $panel.TextBoxOriginal.Text = $address
            Write-Log "✓ Panel #$($panelIndex + 1): Loaded $($address.Substring(0,20))..." "Green"

            if (Test-Path $skeyFile) {
                $absoluteSkeyPath = (Resolve-Path $skeyFile -ErrorAction Stop).Path
                $panel.TextBoxSkey.Text = $absoluteSkeyPath
                Write-Log "✓ Panel #$($panelIndex + 1): Auto-filled skey" "Green"
            }

            $panelIndex++
        } catch {
            Write-Log "✗ Error: $($_.Exception.Message)" "SoftRed"
        }
    }

    return ($panelIndex -gt 0)
}
