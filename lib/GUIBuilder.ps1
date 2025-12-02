# ============================================
# GUIBUILDER.PS1 - GUI Form Construction
# ============================================
# Build and initialize all GUI elements

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Build-MainForm {
    # ============================================
    # GUI SETUP
    # ============================================

    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Scavenger Donation Manager v4.1 - Enhanced"
    $form.Size = New-Object System.Drawing.Size(1200, 700)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "Sizable"
    $form.MaximizeBox = $true
    $form.MinimumSize = New-Object System.Drawing.Size(1000, 600)

    # ====== SPLIT CONTAINER (Main Layout) ======
    $splitContainer = New-Object System.Windows.Forms.SplitContainer
    $splitContainer.Dock = [System.Windows.Forms.DockStyle]::Fill
    $splitContainer.Orientation = [System.Windows.Forms.Orientation]::Vertical
    $splitContainer.SplitterDistance = 800
    $splitContainer.SplitterWidth = 5
    $splitContainer.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $form.Controls.Add($splitContainer)

    # ====== LEFT PANEL (Address Management) ======
    $leftPanel = $splitContainer.Panel1

    # Title Label
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Location = New-Object System.Drawing.Point(10, 10)
    $lblTitle.Size = New-Object System.Drawing.Size(780, 30)
    $lblTitle.Text = "ORIGINAL ADDRESSES MANAGEMENT"
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $lblTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $lblTitle.BackColor = [System.Drawing.Color]::LightSteelBlue
    $lblTitle.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $leftPanel.Controls.Add($lblTitle)

    # Scrollable Container for Addresses
    $global:addressContainer = New-Object System.Windows.Forms.Panel
    $global:addressContainer.Location = New-Object System.Drawing.Point(10, 50)
    $global:addressContainer.Size = New-Object System.Drawing.Size(780, 350)
    $global:addressContainer.AutoScroll = $true
    $global:addressContainer.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $global:addressContainer.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $leftPanel.Controls.Add($global:addressContainer)

    # Add Address Button
    $global:btnAddAddress = New-Object System.Windows.Forms.Button
    $global:btnAddAddress.Location = New-Object System.Drawing.Point(10, 10)
    $global:btnAddAddress.Size = New-Object System.Drawing.Size(760, 35)
    $global:btnAddAddress.Text = "+ Add Original Address"
    $global:btnAddAddress.BackColor = [System.Drawing.Color]::LightGreen
    $global:btnAddAddress.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $global:btnAddAddress.Add_Click({ Add-AddressPanel })
    $global:addressContainer.Controls.Add($global:btnAddAddress)

    # Bottom Panel for Destination and Batch Execute
    $bottomPanel = New-Object System.Windows.Forms.Panel
    $bottomPanel.Location = New-Object System.Drawing.Point(10, 410)
    $bottomPanel.Size = New-Object System.Drawing.Size(780, 150)
    $bottomPanel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    $bottomPanel.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $leftPanel.Controls.Add($bottomPanel)

    # Destination Address Section
    $lblDestination = New-Object System.Windows.Forms.Label
    $lblDestination.Location = New-Object System.Drawing.Point(10, 10)
    $lblDestination.Size = New-Object System.Drawing.Size(150, 20)
    $lblDestination.Text = "Destination Address:"
    $lblDestination.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $bottomPanel.Controls.Add($lblDestination)

    $global:txtDestination = New-Object System.Windows.Forms.TextBox
    $global:txtDestination.Location = New-Object System.Drawing.Point(10, 35)
    $global:txtDestination.Size = New-Object System.Drawing.Size(760, 25)
    $global:txtDestination.Font = New-Object System.Drawing.Font("Consolas", 9)
    $global:txtDestination.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $bottomPanel.Controls.Add($global:txtDestination)

    # Batch Execute Button
    $global:btnBatchExecute = New-Object System.Windows.Forms.Button
    $global:btnBatchExecute.Location = New-Object System.Drawing.Point(10, 75)
    $global:btnBatchExecute.Size = New-Object System.Drawing.Size(760, 60)
    $global:btnBatchExecute.Text = "Execute All (Batch Mode)"
    $global:btnBatchExecute.BackColor = [System.Drawing.Color]::Orange
    $global:btnBatchExecute.ForeColor = [System.Drawing.Color]::White
    $global:btnBatchExecute.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
    $global:btnBatchExecute.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right
    $global:btnBatchExecute.Add_Click({ Execute-BatchAddresses })
    $bottomPanel.Controls.Add($global:btnBatchExecute)

    # ====== RIGHT PANEL (Log Display) ======
    $rightPanel = $splitContainer.Panel2

    # Log Title
    $lblLog = New-Object System.Windows.Forms.Label
    $lblLog.Dock = [System.Windows.Forms.DockStyle]::Top
    $lblLog.Height = 40
    $lblLog.Text = "EXECUTION LOG"
    $lblLog.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $lblLog.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $lblLog.BackColor = [System.Drawing.Color]::LightYellow
    $rightPanel.Controls.Add($lblLog)

    # Button Panel at Bottom
    $logButtonPanel = New-Object System.Windows.Forms.Panel
    $logButtonPanel.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $logButtonPanel.Height = 50
    $rightPanel.Controls.Add($logButtonPanel)

    # Clear Log Button
    $btnClearLog = New-Object System.Windows.Forms.Button
    $btnClearLog.Location = New-Object System.Drawing.Point(10, 5)
    $btnClearLog.Size = New-Object System.Drawing.Size(165, 40)
    $btnClearLog.Text = "Clear Log"
    $btnClearLog.BackColor = [System.Drawing.Color]::LightGray
    $btnClearLog.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $btnClearLog.Add_Click({
        $script:logBox.Clear()
        Write-Log "Log cleared" "Green"
    })
    $logButtonPanel.Controls.Add($btnClearLog)

    # Reset Button
    $btnReset = New-Object System.Windows.Forms.Button
    $btnReset.Location = New-Object System.Drawing.Point(185, 5)
    $btnReset.Size = New-Object System.Drawing.Size(165, 40)
    $btnReset.Text = "Reset All"
    $btnReset.BackColor = [System.Drawing.Color]::LightCoral
    $btnReset.ForeColor = [System.Drawing.Color]::White
    $btnReset.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $btnReset.Add_Click({
        $result = [System.Windows.Forms.MessageBox]::Show(
            "Reset all addresses and log?",
            "Confirm Reset",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )
        
        if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
            Reset-AllAddresses
        }
    })
    $logButtonPanel.Controls.Add($btnReset)

    # Auto-fill button: populate first panel from addr.delegated and addr.skey
    $btnAutoFill = New-Object System.Windows.Forms.Button
    $btnAutoFill.Location = New-Object System.Drawing.Point(360, 5)
    $btnAutoFill.Size = New-Object System.Drawing.Size(165, 40)
    $btnAutoFill.Text = "Auto-fill From Signer"
    $btnAutoFill.BackColor = [System.Drawing.Color]::LightSkyBlue
    $btnAutoFill.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $btnAutoFill.Add_Click({
        # Prefer a temp summary produced by the generator GUI
        $tempFile = Join-Path $PSScriptRoot 'delegated_temp.txt'
        $loaded = $false

        if (Test-Path $tempFile) {
            try {
                $lines = Get-Content -Path $tempFile -ErrorAction Stop
                $objs = @()
                foreach ($ln in $lines) {
                    if ([string]::IsNullOrWhiteSpace($ln)) { continue }
                    $parts = $ln -split '\|'
                    if ($parts.Count -ge 3) {
                        $objs += [pscustomobject]@{ File = $parts[0]; Wallet = $parts[1]; Address = $parts[2] }
                    }
                }

                    if ($objs.Count -gt 0) {
                        Write-Log "Loading $($objs.Count) address(es) from delegated_temp.txt" "Gray"
                        $ok = Populate-PanelsFromSelected -SelectedAddresses $objs
                        if ($ok) { Write-Log "Auto-fill from delegated_temp completed." "Green"; $loaded = $true }
                    }
            } catch {
                Write-Log "Failed reading delegated_temp.txt, will fallback to scanning." "Yellow"
            }
        }

        if (-not $loaded) {
            $ok = Load-FromMidnightSigner
            if (-not $ok) {
                [System.Windows.Forms.MessageBox]::Show("Auto-fill failed. Ensure 'addr.delegated' exists in the script folder or run the generator again.", "Auto-fill", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
            }
        }
    }.GetNewClosure())
    $logButtonPanel.Controls.Add($btnAutoFill)

    # Rescan button: open folder chooser and perform fast scan
    $btnRescan = New-Object System.Windows.Forms.Button
    $btnRescan.Location = New-Object System.Drawing.Point(530, 5)
    $btnRescan.Size = New-Object System.Drawing.Size(165, 40)
    $btnRescan.Text = "Rescan Generated Keys"
    $btnRescan.BackColor = [System.Drawing.Color]::LightYellow
    $btnRescan.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $btnRescan.Add_Click({
        $ok = Show-RescanDialog
        if (-not $ok) { Write-Log "Rescan did not load any addresses." "Gray" }
    }.GetNewClosure())
    $logButtonPanel.Controls.Add($btnRescan)

    # Button: Load from generation.log
    $btnLoadLog = New-Object System.Windows.Forms.Button
    $btnLoadLog.Location = New-Object System.Drawing.Point(700, 5)
    $btnLoadLog.Size = New-Object System.Drawing.Size(165, 40)
    $btnLoadLog.Text = "Load From generation.log"
    $btnLoadLog.BackColor = [System.Drawing.Color]::LightCyan
    $btnLoadLog.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $btnLoadLog.Add_Click({
        $ok = Show-LogScanDialog
        if (-not $ok) { Write-Log "Log-scan did not load addresses." "Gray" }
    }.GetNewClosure())
    $logButtonPanel.Controls.Add($btnLoadLog)

    # Log RichTextBox (Fill remaining space) - supports per-line color
    $script:logBox = New-Object System.Windows.Forms.RichTextBox
    $script:logBox.Dock = [System.Windows.Forms.DockStyle]::Fill
    $script:logBox.Font = New-Object System.Drawing.Font("Consolas", 9)
    $script:logBox.ReadOnly = $true
    $script:logBox.Multiline = $true
    $script:logBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Both
    $script:logBox.BackColor = [System.Drawing.Color]::FromArgb(11,15,19)
    $script:logBox.ForeColor = [System.Drawing.Color]::FromArgb(230,238,240)
    $script:logBox.BorderStyle = [System.Windows.Forms.BorderStyle]::None
    $script:logBox.HideSelection = $false
    $rightPanel.Controls.Add($script:logBox)

    return $form
}

function Show-WelcomeMessage {
    Write-Log "================================================" "Blue"
    Write-Log "SCAVENGER DONATION MANAGER v4.1 - ENHANCED" "Blue"
    Write-Log "================================================" "Blue"
    Write-Log "KEY FEATURES:" "Purple"
    Write-Log "  ✓ Single origin address donation" "Blue"
    Write-Log "  ✓ Multi origin address donation" "Purple"
    Write-Log "  ✓ Auto sign and execute" "Green"
    Write-Log "  ✓ Recovery phrase support" "Green"
    Write-Log "================================================" "Blue"
    Write-Log "Instructions:" "Gray"
    Write-Log "  1. Enter Original Address(es)" "Gray"
    Write-Log "  2. Load .skey file for EACH address" "Gray"
    Write-Log "  3. Enter Destination Address" "Gray"
    Write-Log "  4. Choose Execute single OR Execute All" "Gray"
    Write-Log "================================================" "Blue"
    Write-Log "Ready!" "Blue"
}
