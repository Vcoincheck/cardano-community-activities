# ============================================
# EXECUTIONENGINE.PS1 - Donation Execution Logic
# ============================================
# Single and batch execution, response handling

function Execute-SingleAddress {
    param($Panel)
    
    $panelObj = $script:addressPanels | Where-Object { $_.Panel -eq $Panel } | Select-Object -First 1
    if (-not $panelObj) { return }
    
    $originalAddr = $panelObj.TextBoxOriginal.Text.Trim()
    $destAddr = $txtDestination.Text.Trim()
    $skeyPath = $panelObj.TextBoxSkey.Text.Trim()
    $message = $panelObj.TextBoxMessage.Text.Trim()
    
    # Validation
    if ([string]::IsNullOrWhiteSpace($originalAddr)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter Original Address!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    if ([string]::IsNullOrWhiteSpace($destAddr)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter Destination Address!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    if ([string]::IsNullOrWhiteSpace($skeyPath)) {
        [System.Windows.Forms.MessageBox]::Show("Please select .skey file for this address!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    if ([string]::IsNullOrWhiteSpace($message)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter a message for signing!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    # Get statistics
    Write-Log "================================================" "Blue"
    Write-Log "Checking wallet: $originalAddr" "Blue"
    $solutions = Get-Statistics -Address $originalAddr
    $panelObj.LabelSolutions.Text = "Solutions: $solutions"
    $panelObj.LabelSolutions.ForeColor = if ($solutions -gt 0) { [System.Drawing.Color]::Green } else { [System.Drawing.Color]::Red }
    
    Write-Log "Wallet has $solutions solutions" "Blue"
    Write-Log "Will transfer to: $destAddr" "Blue"
    
    # Confirmation
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Confirm transfer $solutions solutions from:`n$originalAddr`n`nTo:`n$destAddr`n`nAre you sure?",
        "Confirm Donation",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
        Write-Log "Operation cancelled" "Orange"
        return
    }
    
    # Execute
    $script:isExecuting = $true
    $panelObj.ButtonExecute.Enabled = $false
    $panelObj.ButtonExecute.Text = "Wait..."
    
    Write-Log "Creating signature..." "Yellow"
    $signature = Create-Signature -OriginalAddress $originalAddr -DestinationAddress $destAddr -SkeyPath $skeyPath -Message $message
    
    if (-not $signature) {
        Write-Log "Cannot create signature!" "SoftRed"
        $script:isExecuting = $false
        $panelObj.ButtonExecute.Text = "Execute"
        $panelObj.ButtonExecute.Enabled = $true
        return
    }
    
    Write-Log "Signature created successfully" "Green"
    Write-Log "Sending donation request..." "Yellow"
    
    $response = Execute-Donation -OriginalAddress $originalAddr -DestinationAddress $destAddr -Signature $signature
    
    if ($response) {
        $logContent = Process-Response -Response $response -OriginalAddr $originalAddr -DestAddr $destAddr
        
        # Save individual log
        $logFile = "donation_single_$(Get-Date -Format 'yyyyMMddHHmmss').txt"
        $logContent | Out-File -FilePath $logFile -Encoding UTF8
        Write-Log "Detail log: $logFile" "Blue"
    }
    
    $script:isExecuting = $false
    $panelObj.ButtonExecute.Text = "Execute"
    $panelObj.ButtonExecute.Enabled = $true
    
    Write-Log "================================================" "Blue"
}

function Execute-BatchAddresses {
    $destAddr = $txtDestination.Text.Trim()
    
    # Validation
    if ([string]::IsNullOrWhiteSpace($destAddr)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter Destination Address!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    # Get all valid addresses
    $validAddresses = @()
    foreach ($panelObj in $script:addressPanels) {
        $addr = $panelObj.TextBoxOriginal.Text.Trim()
        $skey = $panelObj.TextBoxSkey.Text.Trim()
        $msg = $panelObj.TextBoxMessage.Text.Trim()
        
        if (-not [string]::IsNullOrWhiteSpace($addr) -and -not [string]::IsNullOrWhiteSpace($skey)) {
            $validAddresses += @{
                Address = $addr
                SkeyPath = $skey
                Message = if ([string]::IsNullOrWhiteSpace($msg)) { "Assign accumulated Scavenger rights to: " } else { $msg }
                Panel = $panelObj
            }
        }
    }
    
    if ($validAddresses.Count -eq 0) {
        [System.Windows.Forms.MessageBox]::Show("No valid addresses with .skey files!", "Error", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    # Summary statistics
    Write-Log "================================================" "Blue"
    Write-Log "BATCH CHECK - Total: $($validAddresses.Count) addresses" "Blue"
    
    $totalSolutions = 0
    foreach ($item in $validAddresses) {
        $solutions = Get-Statistics -Address $item.Address
        $item.Solutions = $solutions
        $totalSolutions += $solutions
        
        $item.Panel.LabelSolutions.Text = "Solutions: $solutions"
        $item.Panel.LabelSolutions.ForeColor = if ($solutions -gt 0) { [System.Drawing.Color]::Green } else { [System.Drawing.Color]::Red }
        
        Write-Log "  - $($item.Address): $solutions solutions" "Blue"
    }
    
    Write-Log "TOTAL: $totalSolutions solutions" "Blue"
    Write-Log "Will transfer to: $destAddr" "Blue"
    
    # Confirmation
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Will transfer TOTAL $totalSolutions solutions from $($validAddresses.Count) wallets`n`nTo: $destAddr`n`nAre you sure?",
        "Confirm Batch Donation",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    
    if ($result -ne [System.Windows.Forms.DialogResult]::Yes) {
        Write-Log "Batch operation cancelled" "Orange"
        return
    }
    
    # Execute batch
    $script:isExecuting = $true
    $btnBatchExecute.Enabled = $false
    $btnBatchExecute.Text = "Processing..."
    
    $fullLog = ""
    $successCount = 0
    $failCount = 0
    
    for ($i = 0; $i -lt $validAddresses.Count; $i++) {
        $item = $validAddresses[$i]
        $addr = $item.Address
        
        Write-Log "`n================================================" "Yellow"
        Write-Log "Processing ($($i+1)/$($validAddresses.Count)): $addr" "Yellow"
        
        $item.Panel.ButtonExecute.Enabled = $false
        $item.Panel.ButtonExecute.Text = "Wait..."
        
        # Create signature
        Write-Log "Creating signature..." "Yellow"
        $signature = Create-Signature -OriginalAddress $addr -DestinationAddress $destAddr -SkeyPath $item.SkeyPath -Message $item.Message
        
        if (-not $signature) {
            Write-Log "Signature error for $addr" "SoftRed"
            $failCount++
            $item.Panel.ButtonExecute.Text = "Failed"
            $item.Panel.ButtonExecute.BackColor = [System.Drawing.Color]::LightCoral
            $item.Panel.ButtonExecute.Enabled = $true
            continue
        }
        
        Write-Log "Signature OK, sending..." "Green"
        
        # Execute donation
        $response = Execute-Donation -OriginalAddress $addr -DestinationAddress $destAddr -Signature $signature
        
        if ($response) {
            $logContent = Process-Response -Response $response -OriginalAddr $addr -DestAddr $destAddr
            $fullLog += $logContent
            
            if ($response.status -eq "success") {
                $successCount++
                $item.Panel.ButtonExecute.Text = "Done"
                $item.Panel.ButtonExecute.BackColor = [System.Drawing.Color]::LightGreen
            } else {
                $failCount++
                $item.Panel.ButtonExecute.Text = "Error"
                $item.Panel.ButtonExecute.BackColor = [System.Drawing.Color]::Yellow
            }
        } else {
            $failCount++
            $item.Panel.ButtonExecute.Text = "Failed"
            $item.Panel.ButtonExecute.BackColor = [System.Drawing.Color]::LightCoral
        }
        
        $item.Panel.ButtonExecute.Enabled = $true
        Start-Sleep -Milliseconds 500
    }
    
    Write-Log "`n================================================" "Green"
    Write-Log "BATCH EXECUTION COMPLETED" "Green"
    Write-Log "Success: $successCount | Failed: $failCount" "Green"
    
    # Save full log
    Save-FullLog -Content $fullLog
    
    $script:isExecuting = $false
    $btnBatchExecute.Text = "Execute All"
    $btnBatchExecute.Enabled = $true
    
    # Ask to continue
    Show-ContinueDialog
}

function Show-ContinueDialog {
    $result = [System.Windows.Forms.MessageBox]::Show(
        "Completed! Do you want to:`n`n- RESET and continue?`n- Or EXIT program?",
        "Completed",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question,
        [System.Windows.Forms.MessageBoxDefaultButton]::Button1
    )
    
    if ($result -eq [System.Windows.Forms.DialogResult]::Yes) {
        Reset-AllAddresses
        Write-Log "Ready for new session!" "Yellow"
    } else {
        $form.Close()
    }
}
