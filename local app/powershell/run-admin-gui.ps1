# ============================================
# Run Admin GUI
# ============================================
# Wrapper script to run AdminGUI with correct context

# Get the directory where this script is located
$scriptDir = Split-Path -Parent -Path $MyInvocation.MyCommand.Definition

# Change to that directory
Push-Location $scriptDir

# Source the AdminGUI script
. .\community-admin\AdminGUI.ps1

# Show the GUI
Show-AdminGUI

# Return to original directory
Pop-Location
