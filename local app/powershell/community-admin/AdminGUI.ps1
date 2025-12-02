# ============================================
# COMMUNITY-ADMIN: GUI Interface
# ============================================
# Windows Forms GUI for admin tools

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

function Show-AdminGUI {
    param(
        [string]$ModulePath = ""
    )
    
    # If no path provided, resolve script directory
    if ([string]::IsNullOrEmpty($ModulePath)) {
        # Try multiple ways to get the script directory - prioritize more reliable methods
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
    $modules = @("GenerateChallenge.ps1", "VerifySignature.ps1", "VerifyOnchain.ps1", "UserRegistry.ps1", "ExportReports.ps1")
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
    $form.Text = "Cardano Community Admin Dashboard"
    $form.Size = New-Object System.Drawing.Size(800, 600)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    
    # Header label
    $labelHeader = New-Object System.Windows.Forms.Label
    $labelHeader.Text = "👨‍💼 Community Admin Dashboard"
    $labelHeader.Font = New-Object System.Drawing.Font("Arial", 18, [System.Drawing.FontStyle]::Bold)
    $labelHeader.ForeColor = [System.Drawing.Color]::Yellow
    $labelHeader.AutoSize = $true
    $labelHeader.Location = New-Object System.Drawing.Point(20, 20)
    
    # Left panel - Actions
    $btnGenChallenge = New-Object System.Windows.Forms.Button
    $btnGenChallenge.Text = "Generate Challenge"
    $btnGenChallenge.Size = New-Object System.Drawing.Size(200, 40)
    $btnGenChallenge.Location = New-Object System.Drawing.Point(20, 80)
    $btnGenChallenge.BackColor = [System.Drawing.Color]::FromArgb(100, 150, 50)
    $btnGenChallenge.ForeColor = [System.Drawing.Color]::White
    
    $btnVerify = New-Object System.Windows.Forms.Button
    $btnVerify.Text = "Verify Signature"
    $btnVerify.Size = New-Object System.Drawing.Size(200, 40)
    $btnVerify.Location = New-Object System.Drawing.Point(20, 140)
    $btnVerify.BackColor = [System.Drawing.Color]::FromArgb(100, 150, 50)
    $btnVerify.ForeColor = [System.Drawing.Color]::White
    
    $btnOnChain = New-Object System.Windows.Forms.Button
    $btnOnChain.Text = "Check On-Chain Stake"
    $btnOnChain.Size = New-Object System.Drawing.Size(200, 40)
    $btnOnChain.Location = New-Object System.Drawing.Point(20, 200)
    $btnOnChain.BackColor = [System.Drawing.Color]::FromArgb(100, 150, 50)
    $btnOnChain.ForeColor = [System.Drawing.Color]::White
    
    $btnRegistry = New-Object System.Windows.Forms.Button
    $btnRegistry.Text = "View Registry"
    $btnRegistry.Size = New-Object System.Drawing.Size(200, 40)
    $btnRegistry.Location = New-Object System.Drawing.Point(20, 260)
    $btnRegistry.BackColor = [System.Drawing.Color]::FromArgb(100, 150, 50)
    $btnRegistry.ForeColor = [System.Drawing.Color]::White
    
    $btnExport = New-Object System.Windows.Forms.Button
    $btnExport.Text = "Export Report"
    $btnExport.Size = New-Object System.Drawing.Size(200, 40)
    $btnExport.Location = New-Object System.Drawing.Point(20, 320)
    $btnExport.BackColor = [System.Drawing.Color]::FromArgb(100, 150, 50)
    $btnExport.ForeColor = [System.Drawing.Color]::White
    
    # Right panel - Output
    $textOutput = New-Object System.Windows.Forms.RichTextBox
    $textOutput.Location = New-Object System.Drawing.Point(250, 80)
    $textOutput.Size = New-Object System.Drawing.Size(520, 500)
    $textOutput.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
    $textOutput.ForeColor = [System.Drawing.Color]::LimeGreen
    $textOutput.Font = New-Object System.Drawing.Font("Courier New", 10)
    
    # Event handlers
    $btnGenChallenge.Add_Click({
        $challenge = Generate-SigningChallenge -CommunityId "cardano-devs-ph" -Action "verify_membership"
        $output = $challenge | ConvertTo-Json
        $textOutput.Text = $output
    })
    
    # Add controls to form
    $form.Controls.Add($labelHeader)
    $form.Controls.Add($btnGenChallenge)
    $form.Controls.Add($btnVerify)
    $form.Controls.Add($btnOnChain)
    $form.Controls.Add($btnRegistry)
    $form.Controls.Add($btnExport)
    $form.Controls.Add($textOutput)
    
    $form.ShowDialog()
}

# Run GUI if script is executed directly
if ($MyInvocation.InvocationName -ne '.') {
    Show-AdminGUI
}
