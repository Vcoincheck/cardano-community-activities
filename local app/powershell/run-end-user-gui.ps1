# ============================================
# Run End-User GUI
# ============================================
# Wrapper script to run EndUserGUI with correct context

# Get the directory where this script is located
$scriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Change to that directory
Push-Location $scriptDir

# Source the EndUserGUI script
. .\end-user-app\EndUserGUI.ps1

# Show the GUI
Show-EndUserGUI

# Return to original directory
Pop-Location
