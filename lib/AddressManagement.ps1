# ============================================
# ADDRESSMANAGEMENT.PS1 - Address Panel Management
# ============================================
# Create, update, delete address panels in UI

$script:addressPanels = @()

function Add-AddressPanel {
    $panelHeight = 135
    $panelY = 10 + ($script:addressPanels.Count * ($panelHeight + 10))

    # Container Panel
    $addrPanel = New-Object System.Windows.Forms.Panel
    $addrPanel.Location = New-Object System.Drawing.Point(10, $panelY)
    $addrPanel.Size = New-Object System.Drawing.Size(760, $panelHeight)
    $addrPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $addrPanel.BackColor = [System.Drawing.Color]::WhiteSmoke

    # Label number
    $lblNum = New-Object System.Windows.Forms.Label
    $lblNum.Location = New-Object System.Drawing.Point(5, 8)
    $lblNum.Size = New-Object System.Drawing.Size(30, 20)
    $lblNum.Text = "#$($script:addressPanels.Count + 1)"
    $lblNum.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $addrPanel.Controls.Add($lblNum)

    # Original Address Label
    $lblOriginal = New-Object System.Windows.Forms.Label
    $lblOriginal.Location = New-Object System.Drawing.Point(40, 8)
    $lblOriginal.Size = New-Object System.Drawing.Size(100, 20)
    $lblOriginal.Text = "Original Address:"
    $lblOriginal.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
    $addrPanel.Controls.Add($lblOriginal)

    # Original Address TextBox
    $txtOriginal = New-Object System.Windows.Forms.TextBox
    $txtOriginal.Location = New-Object System.Drawing.Point(145, 8)
    $txtOriginal.Size = New-Object System.Drawing.Size(390, 20)
    $txtOriginal.Text = ""
    $addrPanel.Controls.Add($txtOriginal)

    # Check Button (same row as Original Address)
    $btnCheck = New-Object System.Windows.Forms.Button
    $btnCheck.Location = New-Object System.Drawing.Point(550, 5)
    $btnCheck.Size = New-Object System.Drawing.Size(80, 50)
    $btnCheck.Text = "Check"
    $btnCheck.BackColor = [System.Drawing.Color]::LightBlue
    $btnCheck.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)

    $btnCheck.Add_Click({
        $btnCheck.Enabled = $false
        $btnCheck.Text = 'Wait...'
        $solutions = Get-Statistics -Address $txtOriginal.Text.Trim()
        $lblSolutions.Text = "Solutions: $solutions"
        $lblSolutions.ForeColor = if ($solutions -gt 0) { [System.Drawing.Color]::Green } else { [System.Drawing.Color]::Red }
        Write-Log "Checked: $($txtOriginal.Text.Trim()) - $solutions solutions" "Blue"
        $btnCheck.Text = 'Check'
        $btnCheck.Enabled = $true
    }.GetNewClosure())

    $addrPanel.Controls.Add($btnCheck)

    # Execute Button (same row as Original Address)
    $btnExecute = New-Object System.Windows.Forms.Button
    $btnExecute.Location = New-Object System.Drawing.Point(640, 5)
    $btnExecute.Size = New-Object System.Drawing.Size(80, 50)
    $btnExecute.Text = "Execute"
    $btnExecute.BackColor = [System.Drawing.Color]::LightGreen
    $btnExecute.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $btnExecute.Add_Click({
        if ($script:isExecuting) {
            [System.Windows.Forms.MessageBox]::Show('Execution in progress, please wait!', 'Info', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            return
        }
        Execute-SingleAddress -Panel $addrPanel
    }.GetNewClosure())
    $addrPanel.Controls.Add($btnExecute)

    # Remove Button (same row as Original Address)
    $btnRemove = New-Object System.Windows.Forms.Button
    $btnRemove.Location = New-Object System.Drawing.Point(730, 5)
    $btnRemove.Size = New-Object System.Drawing.Size(25, 50)
    $btnRemove.Text = "X"
    $btnRemove.BackColor = [System.Drawing.Color]::LightCoral
    $btnRemove.ForeColor = [System.Drawing.Color]::White
    $btnRemove.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
    $btnRemove.Add_Click({ Remove-AddressPanel -Panel $addrPanel }.GetNewClosure())
    $addrPanel.Controls.Add($btnRemove)

    # Private Key Label
    $lblSkey = New-Object System.Windows.Forms.Label
    $lblSkey.Location = New-Object System.Drawing.Point(40, 35)
    $lblSkey.Size = New-Object System.Drawing.Size(100, 20)
    $lblSkey.Text = "Private Key (.skey):"
    $lblSkey.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
    $addrPanel.Controls.Add($lblSkey)

    # Per-panel SKey TextBox (readonly) and Load button
    $txtPanelSkey = New-Object System.Windows.Forms.TextBox
    $txtPanelSkey.Location = New-Object System.Drawing.Point(145, 35)
    $txtPanelSkey.Size = New-Object System.Drawing.Size(365, 20)
    $txtPanelSkey.ReadOnly = $true
    $txtPanelSkey.Font = New-Object System.Drawing.Font("Consolas", 8)
    $txtPanelSkey.BackColor = [System.Drawing.Color]::White
    $txtPanelSkey.Multiline = $false
    $addrPanel.Controls.Add($txtPanelSkey)

    $btnLoadSkey = New-Object System.Windows.Forms.Button
    $btnLoadSkey.Location = New-Object System.Drawing.Point(515, 35)
    $btnLoadSkey.Size = New-Object System.Drawing.Size(30, 20)
    $btnLoadSkey.Text = "..."
    $btnLoadSkey.Font = New-Object System.Drawing.Font("Segoe UI", 8)
    $btnLoadSkey.Add_Click({
        $fd = New-Object System.Windows.Forms.OpenFileDialog
        $fd.Filter = "Key Files (*.skey;*.json)|*.skey;*.json|All Files (*.*)|*.*"
        if ($fd.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $file = $fd.FileName
            $txtPanelSkey.Text = $file
            Write-Log "✓ Selected key: $(Split-Path $file -Leaf)" "Green"
        }
    }.GetNewClosure())
    $addrPanel.Controls.Add($btnLoadSkey)

    # Recovery Label
    $lblRecovery = New-Object System.Windows.Forms.Label
    $lblRecovery.Location = New-Object System.Drawing.Point(40, 60)
    $lblRecovery.Size = New-Object System.Drawing.Size(100, 20)
    $lblRecovery.Text = "Recovery:"
    $addrPanel.Controls.Add($lblRecovery)

    # Recovery TextBox
    $txtRecovery = New-Object System.Windows.Forms.TextBox
    $txtRecovery.Location = New-Object System.Drawing.Point(145, 60)
    $txtRecovery.Size = New-Object System.Drawing.Size(365, 20)
    $addrPanel.Controls.Add($txtRecovery)

    # Recovery Enter Button
    $btnEnterRecovery = New-Object System.Windows.Forms.Button
    $btnEnterRecovery.Location = New-Object System.Drawing.Point(515, 58)
    $btnEnterRecovery.Size = New-Object System.Drawing.Size(60, 24)
    $btnEnterRecovery.Text = "Auto"
    $btnEnterRecovery.Add_Click({
        Invoke-RecoveryPhraseAuto -TxtRecovery $txtRecovery -BtnEnterRecovery $btnEnterRecovery
    }.GetNewClosure())
    $addrPanel.Controls.Add($btnEnterRecovery)

    # Manual Button (bên cạnh Auto button)
    $btnManualRecovery = New-Object System.Windows.Forms.Button
    $btnManualRecovery.Location = New-Object System.Drawing.Point(580, 58)
    $btnManualRecovery.Size = New-Object System.Drawing.Size(60, 24)
    $btnManualRecovery.Text = "Manual"
    $btnManualRecovery.BackColor = [System.Drawing.Color]::LightBlue
    $btnManualRecovery.Add_Click({
        Invoke-RecoveryPhraseManual -TxtRecovery $txtRecovery
    }.GetNewClosure())
    $addrPanel.Controls.Add($btnManualRecovery)

    # Message Label
    $lblMessage = New-Object System.Windows.Forms.Label
    $lblMessage.Location = New-Object System.Drawing.Point(40, 85)
    $lblMessage.Size = New-Object System.Drawing.Size(80, 20)
    $lblMessage.Text = "Message:"
    $lblMessage.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
    $addrPanel.Controls.Add($lblMessage)

    # Message TextBox
    $txtMessage = New-Object System.Windows.Forms.TextBox
    $txtMessage.Location = New-Object System.Drawing.Point(125, 85)
    $txtMessage.Size = New-Object System.Drawing.Size(630, 20)
    $txtMessage.Font = New-Object System.Drawing.Font("Consolas", 8)
    $txtMessage.Text = "Assign accumulated Scavenger rights to: "
    $addrPanel.Controls.Add($txtMessage)

    # Solutions Label
    $lblSolutions = New-Object System.Windows.Forms.Label
    $lblSolutions.Location = New-Object System.Drawing.Point(40, 110)
    $lblSolutions.Size = New-Object System.Drawing.Size(500, 20)
    $lblSolutions.Text = "Solutions: Not checked"
    $lblSolutions.ForeColor = [System.Drawing.Color]::Gray
    $lblSolutions.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $addrPanel.Controls.Add($lblSolutions)

    # Drag & Drop for panel skey
    $txtPanelSkey.AllowDrop = $true
    $txtPanelSkey.Add_DragEnter({ param($s,$e) if ($e.Data.GetDataPresent([Windows.Forms.DataFormats]::FileDrop)) { $e.Effect = [Windows.Forms.DragDropEffects]::Copy } })
    $txtPanelSkey.Add_DragDrop({
        param($s,$e)
        $files = $e.Data.GetData([Windows.Forms.DataFormats]::FileDrop)
        if ($files.Count -gt 0) {
            $f = $files[0]
            if (Test-Path $f -PathType Leaf) {
                $txtPanelSkey.Text = $f
                Write-Log "✓ Dropped key: $(Split-Path $f -Leaf)" "Green"
            }
        }
    }.GetNewClosure())

    # Add to tracking array
    $panelObj = @{
        Panel = $addrPanel
        TextBoxOriginal = $txtOriginal
        TextBoxSkey = $txtPanelSkey
        TextBoxMessage = $txtMessage
        LabelSolutions = $lblSolutions
        ButtonCheck = $btnCheck
        ButtonExecute = $btnExecute
        ButtonRemove = $btnRemove
    }
    $script:addressPanels += $panelObj

    # Add to scrollable panel
    $addressContainer.Controls.Add($addrPanel)

    # Update add button position
    Update-AddButtonPosition
}

function Remove-AddressPanel {
    param($Panel)
    
    if ($null -eq $Panel) { return }

    if ($script:addressPanels -eq $null -or $script:addressPanels.Count -le 1) {
        [System.Windows.Forms.MessageBox]::Show("Must have at least 1 address!", "Warning", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }

    try {
        if ($addressContainer.Controls.Contains($Panel)) { $addressContainer.Controls.Remove($Panel) }
    } catch {}

    # Rebuild the panels array excluding the removed panel and any invalid entries
    $script:addressPanels = @($script:addressPanels | Where-Object { $_ -and $_.Panel -and $_.Panel -ne $Panel })

    # Re-position remaining panels safely
    for ($i = 0; $i -lt $script:addressPanels.Count; $i++) {
        $entry = $script:addressPanels[$i]
        if ($null -eq $entry -or $null -eq $entry.Panel) { continue }
        try { $entry.Panel.Location = New-Object System.Drawing.Point(10, (10 + ($i * 120))) } catch {}
        if ($entry.Panel.Controls -and $entry.Panel.Controls.Count -gt 0) {
            try { $entry.Panel.Controls[0].Text = "#$($i + 1)" } catch {}
        }
    }

    Update-AddButtonPosition
}

function Update-AddButtonPosition {
    $lastY = 10
    if ($script:addressPanels.Count -gt 0) {
        $lastEntry = $script:addressPanels[-1]
        if ($null -ne $lastEntry -and $null -ne $lastEntry.Panel) {
            try {
                $lastY = $lastEntry.Panel.Location.Y + $lastEntry.Panel.Height + 10
            } catch { $lastY = 10 }
        }
    }

    try { $btnAddAddress.Location = New-Object System.Drawing.Point(10, $lastY) } catch {}
}

function Reset-AllAddresses {
    # Clear all panels except the first one
    while ($script:addressPanels.Count -gt 1) {
        $lastPanel = $script:addressPanels[-1].Panel
        Remove-AddressPanel -Panel $lastPanel
    }
    
    # Clear first panel
    if ($script:addressPanels.Count -gt 0) {
        $script:addressPanels[0].TextBoxOriginal.Text = ""
        $script:addressPanels[0].TextBoxSkey.Text = ""
        $script:addressPanels[0].LabelSolutions.Text = "Solutions: Not checked"
        $script:addressPanels[0].LabelSolutions.ForeColor = [System.Drawing.Color]::Gray
    }
    
    # Clear destination
    $txtDestination.Text = ""
    
    # Clear log
    $script:logBox.Clear()
    Write-Log "Reset completed" "Green"
    
    # Re-enable main buttons and reset per-panel buttons
    try {
        if ($btnBatchExecute -ne $null) {
            $btnBatchExecute.Enabled = $true
            $btnBatchExecute.Text = "Execute All"
        }
        if ($btnAddAddress -ne $null) {
            $btnAddAddress.Enabled = $true
        }
        foreach ($p in $script:addressPanels) {
            if ($p.ButtonExecute -ne $null) {
                $p.ButtonExecute.Enabled = $true
                $p.ButtonExecute.Text = "Execute"
                $p.ButtonExecute.BackColor = [System.Drawing.Color]::LightGreen
            }
            if ($p.ButtonCheck -ne $null) {
                $p.ButtonCheck.Enabled = $true
                $p.ButtonCheck.Text = "Check"
            }
        }
    } catch {
        # ignore UI re-enable errors
    }
}
