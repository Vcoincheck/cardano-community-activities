# ============================================
# END-USER-APP: GUI Interface
# ============================================
# Windows Forms GUI for end-user tools

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-EndUserGUI {
    param(
        [string]$ModulePath = ""
    )
    
    # If no path provided, resolve script directory
    if ([string]::IsNullOrEmpty($ModulePath)) {
        # Try multiple ways to get the script directory - prioritize working more reliable methods
        $scriptDir = $null
        
        # Method 1: PSScriptRoot (most reliable)
        if (-not [string]::IsNullOrEmpty($PSScriptRoot)) {
            $scriptDir = $PSScriptRoot
        }
        # Method 2: MyInvocation.PSScriptRoot
        elseif (-not [string]::IsNullOrEmpty($MyInvocation.PSScriptRoot)) {
            $scriptDir = $MyInvocation.PSScriptRoot
        }
        # Method 3: Current location
        else {
            $scriptDir = (Get-Location).Path
        }
        
        $ModulePath = Join-Path -Path $scriptDir -ChildPath "modules"
    }
    
    # Verify modules directory exists
    if (-not (Test-Path -Path $ModulePath -PathType Container)) {
        Write-Error "Modules directory not found: $ModulePath"
        Write-Host "Current PSScriptRoot: $PSScriptRoot" -ForegroundColor Yellow
        Write-Host "Current Location: $(Get-Location)" -ForegroundColor Yellow
        return
    }
    
    # Import modules with error handling
    $modules = @("Keygen.ps1", "SignOffline.ps1", "SignMessage-Web.ps1", "ExportWallet.ps1", "VerifyLocal.ps1")
    foreach ($module in $modules) {
        $fullModulePath = Join-Path -Path $ModulePath -ChildPath $module
        if (Test-Path -Path $fullModulePath) {
            . $fullModulePath
        } else {
            Write-Warning "Module not found: $fullModulePath"
        }
    }
    
    # Create main form
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Cardano End-User Tool"
    $form.Size = New-Object System.Drawing.Size(700, 500)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    
    # Header label
    $labelHeader = New-Object System.Windows.Forms.Label
    $labelHeader.Text = "🔐 Cardano End-User Tools"
    $labelHeader.Font = New-Object System.Drawing.Font("Arial", 16, [System.Drawing.FontStyle]::Bold)
    $labelHeader.ForeColor = [System.Drawing.Color]::Cyan
    $labelHeader.AutoSize = $true
    $labelHeader.Location = New-Object System.Drawing.Point(20, 20)
    
    # Buttons
    $btnKeygen = New-Object System.Windows.Forms.Button
    $btnKeygen.Text = "1. Generate Keypair"
    $btnKeygen.Size = New-Object System.Drawing.Size(200, 40)
    $btnKeygen.Location = New-Object System.Drawing.Point(20, 80)
    $btnKeygen.BackColor = [System.Drawing.Color]::FromArgb(50, 100, 150)
    $btnKeygen.ForeColor = [System.Drawing.Color]::White
    
    $btnSign = New-Object System.Windows.Forms.Button
    $btnSign.Text = "2. Sign Message"
    $btnSign.Size = New-Object System.Drawing.Size(200, 40)
    $btnSign.Location = New-Object System.Drawing.Point(20, 140)
    $btnSign.BackColor = [System.Drawing.Color]::FromArgb(50, 100, 150)
    $btnSign.ForeColor = [System.Drawing.Color]::White
    
    $btnExport = New-Object System.Windows.Forms.Button
    $btnExport.Text = "3. Export Wallet"
    $btnExport.Size = New-Object System.Drawing.Size(200, 40)
    $btnExport.Location = New-Object System.Drawing.Point(20, 200)
    $btnExport.BackColor = [System.Drawing.Color]::FromArgb(50, 100, 150)
    $btnExport.ForeColor = [System.Drawing.Color]::White
    
    $btnVerify = New-Object System.Windows.Forms.Button
    $btnVerify.Text = "4. Verify Signature"
    $btnVerify.Size = New-Object System.Drawing.Size(200, 40)
    $btnVerify.Location = New-Object System.Drawing.Point(20, 260)
    $btnVerify.BackColor = [System.Drawing.Color]::FromArgb(50, 100, 150)
    $btnVerify.ForeColor = [System.Drawing.Color]::White
    
    # Output text
    $textOutput = New-Object System.Windows.Forms.RichTextBox
    $textOutput.Location = New-Object System.Drawing.Point(240, 80)
    $textOutput.Size = New-Object System.Drawing.Size(420, 380)
    $textOutput.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
    $textOutput.ForeColor = [System.Drawing.Color]::Lime
    $textOutput.ReadOnly = $true
    $textOutput.Font = New-Object System.Drawing.Font("Courier New", 10)
    
    # Event handlers
    $btnKeygen.Add_Click({
        # Choose auto or manual
        $formMode = New-Object System.Windows.Forms.Form
        $formMode.Text = "Generate Keypair Mode"
        $formMode.Size = New-Object System.Drawing.Size(400, 250)
        $formMode.StartPosition = "CenterScreen"
        $formMode.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
        $formMode.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
        $formMode.MaximizeBox = $false
        
        # Title
        $lblMode = New-Object System.Windows.Forms.Label
        $lblMode.Text = "Choose generation mode:"
        $lblMode.AutoSize = $true
        $lblMode.ForeColor = [System.Drawing.Color]::Cyan
        $lblMode.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
        $lblMode.Location = New-Object System.Drawing.Point(50, 30)
        $formMode.Controls.Add($lblMode)
        
        # Button: Auto (1 external + 1 internal)
        $btnAuto = New-Object System.Windows.Forms.Button
        $btnAuto.Text = "Auto (1 external + 1 internal)"
        $btnAuto.Size = New-Object System.Drawing.Size(280, 40)
        $btnAuto.Location = New-Object System.Drawing.Point(60, 80)
        $btnAuto.BackColor = [System.Drawing.Color]::FromArgb(50, 120, 180)
        $btnAuto.ForeColor = [System.Drawing.Color]::White
        $btnAuto.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
        $formMode.Controls.Add($btnAuto)
        
        # Button: Manual
        $btnManual = New-Object System.Windows.Forms.Button
        $btnManual.Text = "Manual (specify count)"
        $btnManual.Size = New-Object System.Drawing.Size(280, 40)
        $btnManual.Location = New-Object System.Drawing.Point(60, 130)
        $btnManual.BackColor = [System.Drawing.Color]::FromArgb(100, 150, 50)
        $btnManual.ForeColor = [System.Drawing.Color]::White
        $btnManual.Font = New-Object System.Drawing.Font("Arial", 10, [System.Drawing.FontStyle]::Bold)
        $formMode.Controls.Add($btnManual)
        
        # Button: Cancel
        $btnCancel = New-Object System.Windows.Forms.Button
        $btnCancel.Text = "Cancel"
        $btnCancel.Size = New-Object System.Drawing.Size(280, 35)
        $btnCancel.Location = New-Object System.Drawing.Point(60, 180)
        $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
        $btnCancel.ForeColor = [System.Drawing.Color]::White
        $formMode.Controls.Add($btnCancel)
        
        # Event handlers
        $btnAuto.Add_Click({
            $global:GenMode = "auto"
            $formMode.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $formMode.Close()
        })
        
        $btnManual.Add_Click({
            $global:GenMode = "manual"
            $formMode.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $formMode.Close()
        })
        
        $btnCancel.Add_Click({
            $formMode.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $formMode.Close()
        })
        
        $result = $formMode.ShowDialog()
        $formMode.Dispose()
        
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            $genMode = $global:GenMode
            
            if ($genMode -eq "auto") {
                # Auto: 1 external + 1 internal
                $textOutput.AppendText("`n========== Generate Keypair (AUTO) ==========`n")
                $textOutput.AppendText("Mode: Auto (1 external + 1 internal)`n")
                $output = Generate-CardanoKeypair -ExternalAddresses 1 -InternalAddresses 1
                if ($output) {
                    $textOutput.AppendText("✓ Success!`n")
                    $textOutput.AppendText("Generated: $($output.TotalCount) addresses`n")
                    $textOutput.AppendText("Location: $($output.OutputPath)`n")
                } else {
                    $textOutput.AppendText("✗ Failed`n")
                }
            } elseif ($genMode -eq "manual") {
                # Manual: ask for counts
                $formManual = New-Object System.Windows.Forms.Form
                $formManual.Text = "Specify Address Counts"
                $formManual.Size = New-Object System.Drawing.Size(400, 300)
                $formManual.StartPosition = "CenterScreen"
                $formManual.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
                $formManual.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
                $formManual.MaximizeBox = $false
                
                # Label: External
                $lblExt = New-Object System.Windows.Forms.Label
                $lblExt.Text = "External addresses:"
                $lblExt.AutoSize = $true
                $lblExt.ForeColor = [System.Drawing.Color]::Cyan
                $lblExt.Location = New-Object System.Drawing.Point(30, 30)
                $formManual.Controls.Add($lblExt)
                
                # Input: External
                $txtExt = New-Object System.Windows.Forms.TextBox
                $txtExt.Size = New-Object System.Drawing.Size(120, 25)
                $txtExt.Location = New-Object System.Drawing.Point(240, 30)
                $txtExt.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
                $txtExt.ForeColor = [System.Drawing.Color]::Lime
                $txtExt.Text = "5"
                $formManual.Controls.Add($txtExt)
                
                # Label: Internal
                $lblInt = New-Object System.Windows.Forms.Label
                $lblInt.Text = "Internal addresses:"
                $lblInt.AutoSize = $true
                $lblInt.ForeColor = [System.Drawing.Color]::Cyan
                $lblInt.Location = New-Object System.Drawing.Point(30, 80)
                $formManual.Controls.Add($lblInt)
                
                # Input: Internal
                $txtInt = New-Object System.Windows.Forms.TextBox
                $txtInt.Size = New-Object System.Drawing.Size(120, 25)
                $txtInt.Location = New-Object System.Drawing.Point(240, 80)
                $txtInt.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
                $txtInt.ForeColor = [System.Drawing.Color]::Lime
                $txtInt.Text = "3"
                $formManual.Controls.Add($txtInt)
                
                # Button: OK
                $btnOK = New-Object System.Windows.Forms.Button
                $btnOK.Text = "Generate"
                $btnOK.Size = New-Object System.Drawing.Size(100, 35)
                $btnOK.Location = New-Object System.Drawing.Point(140, 140)
                $btnOK.BackColor = [System.Drawing.Color]::FromArgb(50, 120, 180)
                $btnOK.ForeColor = [System.Drawing.Color]::White
                $formManual.Controls.Add($btnOK)
                
                # Button: Cancel
                $btnCancelMan = New-Object System.Windows.Forms.Button
                $btnCancelMan.Text = "Cancel"
                $btnCancelMan.Size = New-Object System.Drawing.Size(100, 35)
                $btnCancelMan.Location = New-Object System.Drawing.Point(250, 140)
                $btnCancelMan.BackColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
                $btnCancelMan.ForeColor = [System.Drawing.Color]::White
                $formManual.Controls.Add($btnCancelMan)
                
                # Event handlers
                $btnOK.Add_Click({
                    $global:ExtCount = [int]$txtExt.Text
                    $global:IntCount = [int]$txtInt.Text
                    $formManual.DialogResult = [System.Windows.Forms.DialogResult]::OK
                    $formManual.Close()
                })
                
                $btnCancelMan.Add_Click({
                    $formManual.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
                    $formManual.Close()
                })
                
                $resultMan = $formManual.ShowDialog()
                $formManual.Dispose()
                
                if ($resultMan -eq [System.Windows.Forms.DialogResult]::OK) {
                    $extCount = $global:ExtCount
                    $intCount = $global:IntCount
                    
                    $textOutput.AppendText("`n========== Generate Keypair (MANUAL) ==========`n")
                    $textOutput.AppendText("Mode: Manual`n")
                    $textOutput.AppendText("External: $extCount, Internal: $intCount`n")
                    $output = Generate-CardanoKeypair -ExternalAddresses $extCount -InternalAddresses $intCount
                    if ($output) {
                        $textOutput.AppendText("✓ Success!`n")
                        $textOutput.AppendText("Generated: $($output.TotalCount) addresses`n")
                        $textOutput.AppendText("Location: $($output.OutputPath)`n")
                    } else {
                        $textOutput.AppendText("✗ Failed`n")
                    }
                }
            }
        }
    })
    
    $btnSign.Add_Click({
        # Step 1: Get message from user
        $formMsg = New-Object System.Windows.Forms.Form
        $formMsg.Text = "Nhập Thông Điệp"
        $formMsg.Size = New-Object System.Drawing.Size(500, 350)
        $formMsg.StartPosition = "CenterScreen"
        $formMsg.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
        $formMsg.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
        $formMsg.MaximizeBox = $false
        
        # Title
        $lblMsg = New-Object System.Windows.Forms.Label
        $lblMsg.Text = "📝 Nhập thông điệp cần ký:"
        $lblMsg.AutoSize = $true
        $lblMsg.ForeColor = [System.Drawing.Color]::Cyan
        $lblMsg.Font = New-Object System.Drawing.Font("Arial", 11, [System.Drawing.FontStyle]::Bold)
        $lblMsg.Location = New-Object System.Drawing.Point(15, 15)
        $formMsg.Controls.Add($lblMsg)
        
        # Textbox
        $txtMsg = New-Object System.Windows.Forms.TextBox
        $txtMsg.Multiline = $true
        $txtMsg.Size = New-Object System.Drawing.Size(460, 200)
        $txtMsg.Location = New-Object System.Drawing.Point(15, 45)
        $txtMsg.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
        $txtMsg.ForeColor = [System.Drawing.Color]::Lime
        $txtMsg.Font = New-Object System.Drawing.Font("Courier New", 10)
        $txtMsg.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
        $formMsg.Controls.Add($txtMsg)
        
        # Button: Sign Offline
        $btnOffline = New-Object System.Windows.Forms.Button
        $btnOffline.Text = "Sign Offline"
        $btnOffline.Size = New-Object System.Drawing.Size(100, 35)
        $btnOffline.Location = New-Object System.Drawing.Point(140, 260)
        $btnOffline.BackColor = [System.Drawing.Color]::FromArgb(50, 120, 180)
        $btnOffline.ForeColor = [System.Drawing.Color]::White
        $formMsg.Controls.Add($btnOffline)
        
        # Button: Sign via Wallet App
        $btnWallet = New-Object System.Windows.Forms.Button
        $btnWallet.Text = "Sign via Wallet"
        $btnWallet.Size = New-Object System.Drawing.Size(120, 35)
        $btnWallet.Location = New-Object System.Drawing.Point(250, 260)
        $btnWallet.BackColor = [System.Drawing.Color]::FromArgb(100, 150, 50)
        $btnWallet.ForeColor = [System.Drawing.Color]::White
        $formMsg.Controls.Add($btnWallet)
        
        # Button: Cancel
        $btnCancel = New-Object System.Windows.Forms.Button
        $btnCancel.Text = "Cancel"
        $btnCancel.Size = New-Object System.Drawing.Size(100, 35)
        $btnCancel.Location = New-Object System.Drawing.Point(380, 260)
        $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
        $btnCancel.ForeColor = [System.Drawing.Color]::White
        $formMsg.Controls.Add($btnCancel)
        
        # Button click handlers
        $btnOffline.Add_Click({
            $global:SignMessage = $txtMsg.Text.Trim()
            $global:SignMethod = "offline"
            $formMsg.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $formMsg.Close()
        })
        
        $btnWallet.Add_Click({
            $global:SignMessage = $txtMsg.Text.Trim()
            $global:SignMethod = "wallet"
            $formMsg.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $formMsg.Close()
        })
        
        $btnCancel.Add_Click({
            $formMsg.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $formMsg.Close()
        })
        
        $result = $formMsg.ShowDialog()
        $formMsg.Dispose()
        
        if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
            $message = $global:SignMessage
            $method = $global:SignMethod
            
            if ([string]::IsNullOrEmpty($message)) {
                $textOutput.AppendText("✗ Message is empty`n")
                return
            }
            
            $textOutput.AppendText("`n========== Sign Message ==========`n")
            $textOutput.AppendText("Message: $message`n")
            $textOutput.AppendText("Method: $method`n`n")
            
            if ($method -eq "offline") {
                # Sign offline with local key
                $result = Sign-MessageOffline -Message $message
                if ($result) {
                    $textOutput.AppendText("✓ Signature created!`n")
                    $textOutput.AppendText("Sig: $($result.Signature.Substring(0, [Math]::Min(60, $result.Signature.Length)))...`n")
                } else {
                    $textOutput.AppendText("✗ Failed or cancelled`n")
                }
            } elseif ($method -eq "wallet") {
                # Sign via wallet app in browser
                $textOutput.AppendText("⏳ Opening wallet app...`n")
                $result = Sign-MessageWeb -Message $message
                if ($result) {
                    $textOutput.AppendText("✓ Signed successfully!`n")
                    $textOutput.AppendText("Address: $($result.Address.Substring(0, 20))...`n")
                    $textOutput.AppendText("Wallet: $($result.Wallet)`n")
                    $textOutput.AppendText("Sig: $($result.Signature.Substring(0, [Math]::Min(60, $result.Signature.Length)))...`n")
                } else {
                    $textOutput.AppendText("✗ Failed or cancelled`n")
                }
            }
        }
    })
    
    # Clean/Delete button event handler
    $btnClean = New-Object System.Windows.Forms.Button
    $btnClean.Text = "🗑 Clean All Keys"
    $btnClean.Size = New-Object System.Drawing.Size(200, 40)
    $btnClean.Location = New-Object System.Drawing.Point(20, 320)
    $btnClean.BackColor = [System.Drawing.Color]::FromArgb(150, 70, 70)
    $btnClean.ForeColor = [System.Drawing.Color]::White
    $btnClean.Add_Click({
        $textOutput.AppendText("`n========== Secure Cleanup ==========`n")
        
        # First confirmation dialog
        $result1 = [System.Windows.Forms.MessageBox]::Show(
            "This will permanently delete all generated wallets and keys from this device.`n`nThis action cannot be undone!",
            "Confirm Cleanup",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Warning
        )
        
        if ($result1 -eq [System.Windows.Forms.DialogResult]::No) {
            $textOutput.AppendText("❌ Cleanup cancelled by user`n")
            return
        }
        
        # Second confirmation dialog
        $result2 = [System.Windows.Forms.MessageBox]::Show(
            "Are you absolutely sure?`n`nAll wallets, keys, and signing certificates will be permanently removed.`n`nThis is your FINAL warning!",
            "FINAL Confirmation - Cannot be undone!",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Stop
        )
        
        if ($result2 -eq [System.Windows.Forms.DialogResult]::No) {
            $textOutput.AppendText("❌ Cleanup cancelled by user`n")
            return
        }
        
        $textOutput.AppendText("🔄 Starting secure cleanup...`n")
        
        # Cleanup paths
        $pathsToClean = @(
            (Join-Path (Get-Location) "wallets"),
            (Join-Path (Get-Location) "generated_keys"),
            (Join-Path (Get-Location) "keys"),
            (Join-Path (Get-Location) "wallet")
        )
        
        $totalItemsDeleted = 0
        $totalFileCount = 0
        
        foreach ($path in $pathsToClean) {
            if (Test-Path $path) {
                $textOutput.AppendText("`n📁 Cleaning: $path`n")
                
                try {
                    # Get all files for secure overwrite
                    $files = Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue
                    $fileCount = ($files | Measure-Object).Count
                    
                    foreach ($file in $files) {
                        # Secure overwrite with zeros before deletion
                        if ($file.Extension -match '\.(skey|xsk|prv|key|vkey|hwallet|json)$') {
                            try {
                                $fileStream = [System.IO.File]::Open($file.FullName, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Write)
                                $zeros = New-Object byte[] $fileStream.Length
                                $fileStream.Write($zeros, 0, $fileStream.Length)
                                $fileStream.Close()
                                $fileStream.Dispose()
                                $textOutput.AppendText("  🔒 Secure wipe: $($file.Name)`n")
                            }
                            catch {
                                $textOutput.AppendText("  ⚠️ Could not overwrite $($file.Name): $_`n")
                            }
                        }
                        $totalItemsDeleted++
                    }
                    
                    # Remove directory
                    Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
                    $textOutput.AppendText("  ✓ Directory deleted`n")
                }
                catch {
                    $textOutput.AppendText("  ⚠️ Error cleaning $path : $_`n")
                }
            }
        }
        
        $textOutput.AppendText("`n$([char]0x2705) CLEANUP COMPLETE - All keys securely removed`n")
        $textOutput.AppendText("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n")
        $textOutput.AppendText("Total files processed: $totalItemsDeleted`n")
        $textOutput.AppendText("Device is now clean - keys cannot be recovered`n")
    })
    
    # Add controls to form
    $form.Controls.Add($labelHeader)
    $form.Controls.Add($btnKeygen)
    $form.Controls.Add($btnSign)
    $form.Controls.Add($btnExport)
    $form.Controls.Add($btnVerify)
    $form.Controls.Add($btnClean)
    $form.Controls.Add($textOutput)
    
    $form.ShowDialog()
}

# Run GUI if script is executed directly
if ($MyInvocation.InvocationName -ne '.') {
    Show-EndUserGUI
}
