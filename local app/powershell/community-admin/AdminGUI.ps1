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
    $modules = @("GenerateChallenge.ps1", "VerifySignature.ps1", "VerifyOnchain.ps1", "UserRegistry.ps1", "ExportReports.ps1", "CommunityManagement.ps1", "ExcelExport.ps1")
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
    $form.Size = New-Object System.Drawing.Size(800, 700)
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
    
    $btnCreateCommunity = New-Object System.Windows.Forms.Button
    $btnCreateCommunity.Text = "Create Community"
    $btnCreateCommunity.Size = New-Object System.Drawing.Size(200, 40)
    $btnCreateCommunity.Location = New-Object System.Drawing.Point(20, 380)
    $btnCreateCommunity.BackColor = [System.Drawing.Color]::FromArgb(150, 100, 200)
    $btnCreateCommunity.ForeColor = [System.Drawing.Color]::White
    
    $btnCreateEvent = New-Object System.Windows.Forms.Button
    $btnCreateEvent.Text = "Create Event"
    $btnCreateEvent.Size = New-Object System.Drawing.Size(200, 40)
    $btnCreateEvent.Location = New-Object System.Drawing.Point(20, 440)
    $btnCreateEvent.BackColor = [System.Drawing.Color]::FromArgb(100, 180, 200)
    $btnCreateEvent.ForeColor = [System.Drawing.Color]::White
    
    $btnExportExcel = New-Object System.Windows.Forms.Button
    $btnExportExcel.Text = "Export to Excel"
    $btnExportExcel.Size = New-Object System.Drawing.Size(200, 40)
    $btnExportExcel.Location = New-Object System.Drawing.Point(20, 500)
    $btnExportExcel.BackColor = [System.Drawing.Color]::FromArgb(200, 150, 100)
    $btnExportExcel.ForeColor = [System.Drawing.Color]::White
    
    # Right panel - Output
    $textOutput = New-Object System.Windows.Forms.RichTextBox
    $textOutput.Location = New-Object System.Drawing.Point(250, 80)
    $textOutput.Size = New-Object System.Drawing.Size(520, 600)
    $textOutput.BackColor = [System.Drawing.Color]::FromArgb(20, 20, 20)
    $textOutput.ForeColor = [System.Drawing.Color]::LimeGreen
    $textOutput.Font = New-Object System.Drawing.Font("Courier New", 10)
    
    # Event handlers
    $btnGenChallenge.Add_Click({
        $challenge = Generate-SigningChallenge -CommunityId "cardano-devs-ph" -Action "verify_membership"
        $output = $challenge | ConvertTo-Json
        $textOutput.Text = $output
    })
    
    $btnCreateCommunity.Add_Click({
        $communityData = New-CommunityDialog
        if ($null -ne $communityData) {
            $success = Add-Community -CommunityData $communityData
            if ($success) {
                $textOutput.Text = "Community created successfully!`n`n$(ConvertTo-Json $communityData)"
            }
        }
    })
    
    $btnCreateEvent.Add_Click({
        $eventData = New-EventDialog
        if ($null -ne $eventData) {
            $success = Add-Event -CommunityId "default-community" -EventData $eventData
            if ($success) {
                $textOutput.Text = "Event created successfully!`n`n$(ConvertTo-Json $eventData)"
            }
        }
    })
    
    $btnExportExcel.Add_Click({
        try {
            $communities = Get-AllCommunities
            $events = Get-AllEvents
            
            if ($communities.Count -eq 0) {
                $textOutput.Text = "No communities to export. Create a community first."
                return
            }
            
            # Export master communities file
            $exportFile = Export-CommunitiesExcel -Format "xlsx" -Communities $communities
            
            # Export each community's details
            foreach ($community in $communities) {
                $communityEvents = Get-CommunityEvents -CommunityId $community.communityId
                if ($communityEvents.Count -gt 0) {
                    Export-CommunityDetailExcel -CommunityId $community.communityId -CommunityName $community.name -Format "xlsx" -Events $communityEvents
                }
            }
            
            $textOutput.Text = "✓ Export completed successfully!`n`nFiles saved to: .\community-admin\exports\`n`nCommunities: $($communities.Count)`nEvents: $($events.Count)"
        }
        catch {
            $textOutput.Text = "✗ Export error: $_`n`nNote: ImportExcel module may need to be installed.`nRun in PowerShell: Install-Module -Name ImportExcel -Force"
        }
    })
    
    # Add controls to form
    $form.Controls.Add($labelHeader)
    $form.Controls.Add($btnGenChallenge)
    $form.Controls.Add($btnVerify)
    $form.Controls.Add($btnOnChain)
    $form.Controls.Add($btnRegistry)
    $form.Controls.Add($btnExport)
    $form.Controls.Add($btnCreateCommunity)
    $form.Controls.Add($btnCreateEvent)
    $form.Controls.Add($btnExportExcel)
    $form.Controls.Add($textOutput)
    
    $form.ShowDialog()
}

# Run GUI if script is executed directly
if ($MyInvocation.InvocationName -ne '.') {
    Show-AdminGUI
}
