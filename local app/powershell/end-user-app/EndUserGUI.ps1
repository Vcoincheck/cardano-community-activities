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
        $output = "Generating keypair...\n"
        $result = Generate-CardanoKeypair -ExternalAddresses 5 -InternalAddresses 3
        if ($result) {
            $output += "✓ Success!\n"
            $output += "Generated: $($result.Count) addresses\n"
            $output += "Location: $($result.OutputPath)\n"
        } else {
            $output += "✗ Failed\n"
        }
        $textOutput.Text += $output
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
    
    # Add controls to form
    $form.Controls.Add($labelHeader)
    $form.Controls.Add($btnKeygen)
    $form.Controls.Add($btnSign)
    $form.Controls.Add($btnExport)
    $form.Controls.Add($btnVerify)
    $form.Controls.Add($textOutput)
    
    $form.ShowDialog()
}

# Run GUI if script is executed directly
if ($MyInvocation.InvocationName -ne '.') {
    Show-EndUserGUI
}
