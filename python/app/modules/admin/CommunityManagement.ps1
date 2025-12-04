# ============================================
# COMMUNITY-ADMIN: Community & Event Management
# ============================================
# Create and manage communities and events

# Global community store (in production, this would be a database)
$script:CommunitiesData = @()
$script:EventsData = @()

function New-CommunityDialog {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $dialogForm = New-Object System.Windows.Forms.Form
    $dialogForm.Text = "Create New Community"
    $dialogForm.Size = New-Object System.Drawing.Size(500, 400)
    $dialogForm.StartPosition = "CenterScreen"
    $dialogForm.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $dialogForm.TopMost = $true
    
    # Title
    $labelTitle = New-Object System.Windows.Forms.Label
    $labelTitle.Text = "Create New Community"
    $labelTitle.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
    $labelTitle.ForeColor = [System.Drawing.Color]::Cyan
    $labelTitle.Location = New-Object System.Drawing.Point(20, 20)
    $labelTitle.AutoSize = $true
    $dialogForm.Controls.Add($labelTitle)
    
    # Community ID
    $labelCommunityId = New-Object System.Windows.Forms.Label
    $labelCommunityId.Text = "Community ID:"
    $labelCommunityId.ForeColor = [System.Drawing.Color]::White
    $labelCommunityId.Location = New-Object System.Drawing.Point(20, 60)
    $labelCommunityId.Size = New-Object System.Drawing.Size(100, 20)
    $dialogForm.Controls.Add($labelCommunityId)
    
    $textCommunityId = New-Object System.Windows.Forms.TextBox
    $textCommunityId.Location = New-Object System.Drawing.Point(130, 60)
    $textCommunityId.Size = New-Object System.Drawing.Size(340, 25)
    $textCommunityId.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $textCommunityId.ForeColor = [System.Drawing.Color]::White
    $dialogForm.Controls.Add($textCommunityId)
    
    # Community Name
    $labelName = New-Object System.Windows.Forms.Label
    $labelName.Text = "Community Name:"
    $labelName.ForeColor = [System.Drawing.Color]::White
    $labelName.Location = New-Object System.Drawing.Point(20, 100)
    $labelName.Size = New-Object System.Drawing.Size(100, 20)
    $dialogForm.Controls.Add($labelName)
    
    $textName = New-Object System.Windows.Forms.TextBox
    $textName.Location = New-Object System.Drawing.Point(130, 100)
    $textName.Size = New-Object System.Drawing.Size(340, 25)
    $textName.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $textName.ForeColor = [System.Drawing.Color]::White
    $dialogForm.Controls.Add($textName)
    
    # Description
    $labelDescription = New-Object System.Windows.Forms.Label
    $labelDescription.Text = "Description:"
    $labelDescription.ForeColor = [System.Drawing.Color]::White
    $labelDescription.Location = New-Object System.Drawing.Point(20, 140)
    $labelDescription.Size = New-Object System.Drawing.Size(100, 20)
    $dialogForm.Controls.Add($labelDescription)
    
    $textDescription = New-Object System.Windows.Forms.TextBox
    $textDescription.Location = New-Object System.Drawing.Point(130, 140)
    $textDescription.Size = New-Object System.Drawing.Size(340, 80)
    $textDescription.Multiline = $true
    $textDescription.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $textDescription.ForeColor = [System.Drawing.Color]::White
    $dialogForm.Controls.Add($textDescription)
    
    # Buttons
    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Text = "OK"
    $btnOk.Size = New-Object System.Drawing.Size(100, 35)
    $btnOk.Location = New-Object System.Drawing.Point(200, 330)
    $btnOk.BackColor = [System.Drawing.Color]::FromArgb(100, 150, 50)
    $btnOk.ForeColor = [System.Drawing.Color]::White
    $btnOk.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $dialogForm.Controls.Add($btnOk)
    
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Size = New-Object System.Drawing.Size(100, 35)
    $btnCancel.Location = New-Object System.Drawing.Point(310, 330)
    $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(150, 50, 50)
    $btnCancel.ForeColor = [System.Drawing.Color]::White
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $dialogForm.Controls.Add($btnCancel)
    
    $result = $dialogForm.ShowDialog()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return @{
            communityId = $textCommunityId.Text
            name = $textName.Text
            description = $textDescription.Text
            createdDate = Get-Date -Format 'yyyy-MM-dd'
            activeMembers = 0
            totalEvents = 0
            status = "Active"
        }
    }
    
    return $null
}

function New-EventDialog {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    $dialogForm = New-Object System.Windows.Forms.Form
    $dialogForm.Text = "Create New Event"
    $dialogForm.Size = New-Object System.Drawing.Size(500, 500)
    $dialogForm.StartPosition = "CenterScreen"
    $dialogForm.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $dialogForm.TopMost = $true
    
    # Title
    $labelTitle = New-Object System.Windows.Forms.Label
    $labelTitle.Text = "Create New Event"
    $labelTitle.Font = New-Object System.Drawing.Font("Arial", 14, [System.Drawing.FontStyle]::Bold)
    $labelTitle.ForeColor = [System.Drawing.Color]::Cyan
    $labelTitle.Location = New-Object System.Drawing.Point(20, 20)
    $labelTitle.AutoSize = $true
    $dialogForm.Controls.Add($labelTitle)
    
    # Event ID
    $labelEventId = New-Object System.Windows.Forms.Label
    $labelEventId.Text = "Event ID:"
    $labelEventId.ForeColor = [System.Drawing.Color]::White
    $labelEventId.Location = New-Object System.Drawing.Point(20, 60)
    $labelEventId.Size = New-Object System.Drawing.Size(100, 20)
    $dialogForm.Controls.Add($labelEventId)
    
    $textEventId = New-Object System.Windows.Forms.TextBox
    $textEventId.Location = New-Object System.Drawing.Point(130, 60)
    $textEventId.Size = New-Object System.Drawing.Size(340, 25)
    $textEventId.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $textEventId.ForeColor = [System.Drawing.Color]::White
    $dialogForm.Controls.Add($textEventId)
    
    # Event Name
    $labelEventName = New-Object System.Windows.Forms.Label
    $labelEventName.Text = "Event Name:"
    $labelEventName.ForeColor = [System.Drawing.Color]::White
    $labelEventName.Location = New-Object System.Drawing.Point(20, 100)
    $labelEventName.Size = New-Object System.Drawing.Size(100, 20)
    $dialogForm.Controls.Add($labelEventName)
    
    $textEventName = New-Object System.Windows.Forms.TextBox
    $textEventName.Location = New-Object System.Drawing.Point(130, 100)
    $textEventName.Size = New-Object System.Drawing.Size(340, 25)
    $textEventName.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $textEventName.ForeColor = [System.Drawing.Color]::White
    $dialogForm.Controls.Add($textEventName)
    
    # Event Date
    $labelEventDate = New-Object System.Windows.Forms.Label
    $labelEventDate.Text = "Event Date:"
    $labelEventDate.ForeColor = [System.Drawing.Color]::White
    $labelEventDate.Location = New-Object System.Drawing.Point(20, 140)
    $labelEventDate.Size = New-Object System.Drawing.Size(100, 20)
    $dialogForm.Controls.Add($labelEventDate)
    
    $textEventDate = New-Object System.Windows.Forms.TextBox
    $textEventDate.Location = New-Object System.Drawing.Point(130, 140)
    $textEventDate.Size = New-Object System.Drawing.Size(340, 25)
    $textEventDate.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $textEventDate.ForeColor = [System.Drawing.Color]::White
    $textEventDate.Text = (Get-Date -Format 'yyyy-MM-dd')
    $dialogForm.Controls.Add($textEventDate)
    
    # Location
    $labelLocation = New-Object System.Windows.Forms.Label
    $labelLocation.Text = "Location:"
    $labelLocation.ForeColor = [System.Drawing.Color]::White
    $labelLocation.Location = New-Object System.Drawing.Point(20, 180)
    $labelLocation.Size = New-Object System.Drawing.Size(100, 20)
    $dialogForm.Controls.Add($labelLocation)
    
    $textLocation = New-Object System.Windows.Forms.TextBox
    $textLocation.Location = New-Object System.Drawing.Point(130, 180)
    $textLocation.Size = New-Object System.Drawing.Size(340, 25)
    $textLocation.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $textLocation.ForeColor = [System.Drawing.Color]::White
    $dialogForm.Controls.Add($textLocation)
    
    # Status
    $labelStatus = New-Object System.Windows.Forms.Label
    $labelStatus.Text = "Status:"
    $labelStatus.ForeColor = [System.Drawing.Color]::White
    $labelStatus.Location = New-Object System.Drawing.Point(20, 220)
    $labelStatus.Size = New-Object System.Drawing.Size(100, 20)
    $dialogForm.Controls.Add($labelStatus)
    
    $comboStatus = New-Object System.Windows.Forms.ComboBox
    $comboStatus.Location = New-Object System.Drawing.Point(130, 220)
    $comboStatus.Size = New-Object System.Drawing.Size(340, 25)
    $comboStatus.Items.AddRange(@("Planned", "In Progress", "Completed", "Cancelled"))
    $comboStatus.SelectedIndex = 0
    $comboStatus.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $comboStatus.ForeColor = [System.Drawing.Color]::White
    $dialogForm.Controls.Add($comboStatus)
    
    # Description
    $labelDescription = New-Object System.Windows.Forms.Label
    $labelDescription.Text = "Description:"
    $labelDescription.ForeColor = [System.Drawing.Color]::White
    $labelDescription.Location = New-Object System.Drawing.Point(20, 260)
    $labelDescription.Size = New-Object System.Drawing.Size(100, 20)
    $dialogForm.Controls.Add($labelDescription)
    
    $textDescription = New-Object System.Windows.Forms.TextBox
    $textDescription.Location = New-Object System.Drawing.Point(130, 260)
    $textDescription.Size = New-Object System.Drawing.Size(340, 60)
    $textDescription.Multiline = $true
    $textDescription.BackColor = [System.Drawing.Color]::FromArgb(50, 50, 50)
    $textDescription.ForeColor = [System.Drawing.Color]::White
    $dialogForm.Controls.Add($textDescription)
    
    # Buttons
    $btnOk = New-Object System.Windows.Forms.Button
    $btnOk.Text = "OK"
    $btnOk.Size = New-Object System.Drawing.Size(100, 35)
    $btnOk.Location = New-Object System.Drawing.Point(200, 430)
    $btnOk.BackColor = [System.Drawing.Color]::FromArgb(100, 150, 50)
    $btnOk.ForeColor = [System.Drawing.Color]::White
    $btnOk.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $dialogForm.Controls.Add($btnOk)
    
    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Text = "Cancel"
    $btnCancel.Size = New-Object System.Drawing.Size(100, 35)
    $btnCancel.Location = New-Object System.Drawing.Point(310, 430)
    $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(150, 50, 50)
    $btnCancel.ForeColor = [System.Drawing.Color]::White
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $dialogForm.Controls.Add($btnCancel)
    
    $result = $dialogForm.ShowDialog()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return @{
            eventId = $textEventId.Text
            eventName = $textEventName.Text
            eventDate = $textEventDate.Text
            location = $textLocation.Text
            status = $comboStatus.SelectedItem
            attendees = 0
            description = $textDescription.Text
        }
    }
    
    return $null
}

function Add-Community {
    param(
        [hashtable]$CommunityData
    )
    
    Write-Host "`n========== Adding Community ==========" -ForegroundColor Cyan
    
    if ($null -eq $CommunityData) {
        Write-Host "✗ No community data provided" -ForegroundColor Red
        return $false
    }
    
    if ([string]::IsNullOrEmpty($CommunityData.communityId)) {
        Write-Host "✗ Community ID is required" -ForegroundColor Red
        return $false
    }
    
    if ([string]::IsNullOrEmpty($CommunityData.name)) {
        Write-Host "✗ Community Name is required" -ForegroundColor Red
        return $false
    }
    
    # Add to global list
    $script:CommunitiesData += $CommunityData
    
    Write-Host "✓ Community '$($CommunityData.name)' added successfully" -ForegroundColor Green
    Write-Host "  ID: $($CommunityData.communityId)" -ForegroundColor Green
    Write-Host "  Created: $($CommunityData.createdDate)" -ForegroundColor Green
    
    return $true
}

function Add-Event {
    param(
        [string]$CommunityId,
        [hashtable]$EventData
    )
    
    Write-Host "`n========== Adding Event to Community ==========" -ForegroundColor Cyan
    
    if ($null -eq $EventData) {
        Write-Host "✗ No event data provided" -ForegroundColor Red
        return $false
    }
    
    if ([string]::IsNullOrEmpty($EventData.eventId)) {
        Write-Host "✗ Event ID is required" -ForegroundColor Red
        return $false
    }
    
    if ([string]::IsNullOrEmpty($EventData.eventName)) {
        Write-Host "✗ Event Name is required" -ForegroundColor Red
        return $false
    }
    
    # Add community reference
    $EventData.communityId = $CommunityId
    
    # Add to global list
    $script:EventsData += $EventData
    
    # Update community event count
    $community = $script:CommunitiesData | Where-Object { $_.communityId -eq $CommunityId }
    if ($community) {
        $community.totalEvents++
    }
    
    Write-Host "✓ Event '$($EventData.eventName)' added successfully" -ForegroundColor Green
    Write-Host "  ID: $($EventData.eventId)" -ForegroundColor Green
    Write-Host "  Date: $($EventData.eventDate)" -ForegroundColor Green
    Write-Host "  Community: $CommunityId" -ForegroundColor Green
    
    return $true
}

function Get-AllCommunities {
    return $script:CommunitiesData
}

function Get-AllEvents {
    return $script:EventsData
}

function Get-CommunityEvents {
    param(
        [string]$CommunityId
    )
    
    return $script:EventsData | Where-Object { $_.communityId -eq $CommunityId }
}
