# ============================================
# COMMUNITY-ADMIN: Excel/CSV Export Functions
# ============================================
# Export community and event data to Excel/CSV format

# Check and install ImportExcel module if needed
function Ensure-ImportExcelModule {
    if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
        Write-Host "Installing ImportExcel module..." -ForegroundColor Yellow
        Install-Module -Name ImportExcel -Force -Scope CurrentUser -SkipPublisherCheck
    }
    Import-Module ImportExcel -Force
}

function Export-CommunitiesExcel {
    param(
        [string]$OutputPath = ".\community-admin\exports",
        [string]$Format = "xlsx",  # xlsx or csv
        [array]$Communities = @()
    )
    
    Write-Host "`n========== Exporting Communities to $($Format.ToUpper()) ==========" -ForegroundColor Cyan
    
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath | Out-Null
    }
    
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    
    # Check if ImportExcel is available for xlsx export
    $hasImportExcel = Get-Module -ListAvailable -Name ImportExcel
    
    if ($Format -eq "xlsx" -and $hasImportExcel) {
        # Use ImportExcel for better formatting
        Ensure-ImportExcelModule
        
        $exportFile = Join-Path $OutputPath "Communities_Master_$timestamp.xlsx"
        
        # Create master sheet with all communities summary
        $masterData = @()
        $Communities | ForEach-Object {
            $masterData += @{
                "Community ID" = $_.communityId
                "Name" = $_.name
                "Description" = $_.description
                "Created Date" = $_.createdDate
                "Active Members" = $_.activeMembers
                "Total Events" = $_.totalEvents
                "Status" = $_.status
            }
        }
        
        # Export to Excel with formatting
        $masterData | Export-Excel -Path $exportFile -WorksheetName "Communities" -AutoSize -FreezeTopRow -TableStyle "Light1"
        
        Write-Host "✓ Master community file exported: $exportFile" -ForegroundColor Green
    } else {
        # Use CSV as fallback
        $exportFile = Join-Path $OutputPath "Communities_Master_$timestamp.csv"
        
        $masterData = @()
        $Communities | ForEach-Object {
            $masterData += @{
                "Community ID" = $_.communityId
                "Name" = $_.name
                "Description" = $_.description
                "Created Date" = $_.createdDate
                "Active Members" = $_.activeMembers
                "Total Events" = $_.totalEvents
                "Status" = $_.status
            }
        }
        
        $masterData | Export-Csv -Path $exportFile -NoTypeInformation -Encoding UTF8
        
        Write-Host "✓ Master community file exported (CSV): $exportFile" -ForegroundColor Green
    }
    
    return $exportFile
}

function Export-CommunityDetailExcel {
    param(
        [string]$CommunityId,
        [string]$CommunityName,
        [string]$OutputPath = ".\community-admin\exports",
        [string]$Format = "xlsx",  # xlsx or csv
        [array]$Events = @(),
        [array]$Members = @()
    )
    
    Write-Host "`n========== Exporting $CommunityName Details to $($Format.ToUpper()) ==========" -ForegroundColor Cyan
    
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath | Out-Null
    }
    
    $timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    
    # Check if ImportExcel is available
    $hasImportExcel = Get-Module -ListAvailable -Name ImportExcel
    
    $safeCommunityName = ($CommunityName -replace '[^a-zA-Z0-9_-]', '_').Substring(0, [Math]::Min(30, ($CommunityName -replace '[^a-zA-Z0-9_-]', '_').Length))
    
    if ($Format -eq "xlsx" -and $hasImportExcel) {
        Ensure-ImportExcelModule
        
        $exportFile = Join-Path $OutputPath "$safeCommunityName`_Detail_$timestamp.xlsx"
        
        # Prepare Events sheet data
        $eventsData = @()
        $Events | ForEach-Object {
            $eventsData += @{
                "Event ID" = $_.eventId
                "Event Name" = $_.eventName
                "Date" = $_.eventDate
                "Location" = $_.location
                "Status" = $_.status
                "Attendees" = $_.attendees
                "Description" = $_.description
            }
        }
        
        # Prepare Members sheet data
        $membersData = @()
        $Members | ForEach-Object {
            $membersData += @{
                "Member ID" = $_.memberId
                "Name" = $_.name
                "Email" = $_.email
                "Joined Date" = $_.joinedDate
                "Status" = $_.status
                "Role" = $_.role
            }
        }
        
        # Export to Excel with multiple sheets
        $eventsData | Export-Excel -Path $exportFile -WorksheetName "Events" -AutoSize -FreezeTopRow -TableStyle "Light2"
        $membersData | Export-Excel -Path $exportFile -WorksheetName "Members" -AutoSize -FreezeTopRow -TableStyle "Light3" -Append
        
        Write-Host "✓ Community detail file exported: $exportFile" -ForegroundColor Green
    } else {
        # Export as CSV files
        $eventsFile = Join-Path $OutputPath "$safeCommunityName`_Events_$timestamp.csv"
        $membersFile = Join-Path $OutputPath "$safeCommunityName`_Members_$timestamp.csv"
        
        $eventsData = @()
        $Events | ForEach-Object {
            $eventsData += @{
                "Event ID" = $_.eventId
                "Event Name" = $_.eventName
                "Date" = $_.eventDate
                "Location" = $_.location
                "Status" = $_.status
                "Attendees" = $_.attendees
                "Description" = $_.description
            }
        }
        
        $membersData = @()
        $Members | ForEach-Object {
            $membersData += @{
                "Member ID" = $_.memberId
                "Name" = $_.name
                "Email" = $_.email
                "Joined Date" = $_.joinedDate
                "Status" = $_.status
                "Role" = $_.role
            }
        }
        
        $eventsData | Export-Csv -Path $eventsFile -NoTypeInformation -Encoding UTF8
        $membersData | Export-Csv -Path $membersFile -NoTypeInformation -Encoding UTF8
        
        Write-Host "✓ Community detail files exported (CSV): $eventsFile, $membersFile" -ForegroundColor Green
        return @($eventsFile, $membersFile)
    }
    
    return $exportFile
}
