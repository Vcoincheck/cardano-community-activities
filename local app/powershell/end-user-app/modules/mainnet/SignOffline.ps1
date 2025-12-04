# ============================================
# END-USER-APP: Sign Message Offline
# ============================================
# Sign arbitrary messages offline using cardano-signer

Add-Type -AssemblyName System.Windows.Forms

function Sign-MessageOffline {
    param(
        [string]$Message = "",
        [string]$SkeyPath = "",
        [string]$SignerExePath = ""
    )
    
    Write-Host "`n========== Offline Message Signing ==========" -ForegroundColor Cyan
    
    # Find cardano-signer
    if ([string]::IsNullOrEmpty($SignerExePath)) {
        $SignerExePath = $null
        @(".\tools\cardano-signer\cardano-signer", ".\tools\cardano-signer\cardano-signer.exe", ".\cardano-signer.exe", ".\cardano-signer") | ForEach-Object {
            if (Test-Path $_) { $SignerExePath = (Resolve-Path $_).Path; return }
        }
    }
    
    if (-not $SignerExePath) {
        Write-Host "✗ cardano-signer not found" -ForegroundColor Red
        return $null
    }
    
    Write-Host "Using cardano-signer: $SignerExePath" -ForegroundColor Yellow
    
    # Get message if not provided
    if ([string]::IsNullOrEmpty($Message)) {
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Enter Message to Sign"
        $form.Size = New-Object System.Drawing.Size(500, 300)
        $form.StartPosition = "CenterScreen"
        $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
        
        $label = New-Object System.Windows.Forms.Label
        $label.Text = "Enter message:"
        $label.AutoSize = $true
        $label.ForeColor = [System.Drawing.Color]::Cyan
        $label.Location = New-Object System.Drawing.Point(10, 10)
        
        $textBox = New-Object System.Windows.Forms.TextBox
        $textBox.Multiline = $true
        $textBox.Size = New-Object System.Drawing.Size(460, 180)
        $textBox.Location = New-Object System.Drawing.Point(10, 40)
        $textBox.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
        $textBox.ForeColor = [System.Drawing.Color]::Lime
        $textBox.ScrollBars = [System.Windows.Forms.ScrollBars]::Vertical
        
        $btnOK = New-Object System.Windows.Forms.Button
        $btnOK.Text = "Sign"
        $btnOK.Size = New-Object System.Drawing.Size(100, 30)
        $btnOK.Location = New-Object System.Drawing.Point(200, 230)
        $btnOK.BackColor = [System.Drawing.Color]::FromArgb(50, 120, 180)
        $btnOK.ForeColor = [System.Drawing.Color]::White
        $btnOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
        
        $btnCancel = New-Object System.Windows.Forms.Button
        $btnCancel.Text = "Cancel"
        $btnCancel.Size = New-Object System.Drawing.Size(100, 30)
        $btnCancel.Location = New-Object System.Drawing.Point(310, 230)
        $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
        $btnCancel.ForeColor = [System.Drawing.Color]::White
        $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
        
        $form.Controls.Add($label)
        $form.Controls.Add($textBox)
        $form.Controls.Add($btnOK)
        $form.Controls.Add($btnCancel)
        
        $result = $form.ShowDialog()
        $Message = $textBox.Text
        $form.Dispose()
        
        if ($result -ne [System.Windows.Forms.DialogResult]::OK) {
            Write-Host "✗ Cancelled by user" -ForegroundColor Yellow
            return $null
        }
    }
    
    # Get signing key path if not provided
    if ([string]::IsNullOrEmpty($SkeyPath)) {
        $form = New-Object System.Windows.Forms.OpenFileDialog
        $form.Title = "Select Signing Key (.xsk or .skey)"
        $form.Filter = "Key files (*.xsk, *.skey)|*.xsk;*.skey|All files (*.*)|*.*"
        $form.InitialDirectory = ".\wallets"
        
        if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
            $SkeyPath = $form.FileName
        } else {
            Write-Host "✗ No key file selected" -ForegroundColor Yellow
            return $null
        }
    }
    
    if (-not (Test-Path $SkeyPath)) {
        Write-Host "✗ Signing key file not found at $SkeyPath" -ForegroundColor Red
        return $null
    }
    
    Write-Host "Message: $Message" -ForegroundColor Yellow
    Write-Host "Key file: $SkeyPath" -ForegroundColor Yellow
    
    try {
        $tempDir = [System.IO.Path]::GetTempPath()
        $msgFile = Join-Path $tempDir "msg_$(Get-Date -Format 'yyyyMMddHHmmss').txt"
        
        # Write message to temp file
        $Message | Out-File -FilePath $msgFile -Encoding UTF8 -NoNewline
        Write-Host "Message file: $msgFile" -ForegroundColor Gray
        
        # Create signature
        Write-Host "Creating signature..." -ForegroundColor Yellow
        $signature = & $SignerExePath sign --message-file $msgFile --secret-key-file $SkeyPath 2>&1
        
        # Cleanup
        Remove-Item $msgFile -ErrorAction SilentlyContinue
        
        if ($signature -and $signature.ToString().Length -gt 10) {
            Write-Host "✓ Signature created successfully" -ForegroundColor Green
            Write-Host "Signature: $signature" -ForegroundColor Cyan
            return @{
                Message = $Message
                Signature = $signature.ToString().Trim()
                Timestamp = Get-Date -Format 'o'
                SkeyPath = $SkeyPath
            }
        } else {
            Write-Host "✗ Failed to create signature (empty result)" -ForegroundColor Red
            Write-Host "Output: $signature" -ForegroundColor Red
            return $null
        }
    }
    catch {
        Write-Host "✗ Error signing message: $_" -ForegroundColor Red
        Write-Host "Stack trace: $($_.Exception.StackTrace)" -ForegroundColor Red
        return $null
    }
}
