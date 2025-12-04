# ============================================
# COMMUNITY-ADMIN: Excel/CSV Export Functions
# ============================================
# Export community and event data to Excel/CSV format

# Check and install ImportExcel module if needed

import os
import pandas as pd
from datetime import datetime

function export_communities_excel {
    param(
        [array]$communities,
        [string]$output_path = "./exports",
        [string]$fmt = "xlsx"
    )
    
    os.makedirs($output_path, exist_ok=True)
    $timestamp = (Get-Date).ToString('yyyyMMdd_HHmmss')
    $df = [System.Data.DataTable]::new()
    
    # Convert communities array to DataTable
    $communities | ForEach-Object {
        $row = $df.NewRow()
        $row["Community ID"] = $_.communityId
        $row["Name"] = $_.name
        $row["Description"] = $_.description
        $row["Created Date"] = $_.createdDate
        $row["Active Members"] = $_.activeMembers
        $row["Total Events"] = $_.totalEvents
        $row["Status"] = $_.status
        $df.Rows.Add($row)
    }
    
    if ($fmt -eq "xlsx") {
        $file_path = Join-Path $output_path "Communities_Master_$timestamp.xlsx"
        $df | Export-Excel -Path $file_path -WorksheetName "Communities" -AutoSize -FreezeTopRow -TableStyle "Light1"
    } else {
        $file_path = Join-Path $output_path "Communities_Master_$timestamp.csv"
        $df | Export-Csv -Path $file_path -NoTypeInformation -Encoding UTF8
    }
    Write-Host "✓ Master community file exported: $file_path" -ForegroundColor Green
    return $file_path
}
