# ============================================
# MAIN.PS1 - Application Entry Point
# ============================================
# Imports all modules and launches the application

# Set ErrorActionPreference
$ErrorActionPreference = "Continue"

# Get script directory
$scriptDir = $PSScriptRoot
$libDir = Join-Path $scriptDir "lib"

# Load all modules
Write-Host "Loading modules..." -ForegroundColor Cyan

$modules = @(
    "Core.ps1",
    "DataLoader.ps1",
    "AddressManagement.ps1",
    "ExecutionEngine.ps1",
    "MidnightSignerIntegration.ps1",
    "GUIBuilder.ps1"
)

foreach ($module in $modules) {
    $modulePath = Join-Path $libDir $module
    if (Test-Path $modulePath) {
        Write-Host "  ✓ Loading $module" -ForegroundColor Green
        & $modulePath
    } else {
        Write-Host "  ✗ Module not found: $module" -ForegroundColor Red
        exit 1
    }
}

# Initialize global variables
$script:isExecuting = $false

# Build GUI
Write-Host "Building GUI..." -ForegroundColor Cyan
$form = Build-MainForm

# Add first address panel
Add-AddressPanel

# Start delegated_summary watchers and timer
Start-DelegatedSummaryWatchers
$summaryTimer = New-Object System.Windows.Forms.Timer
$summaryTimer.Interval = 500
$summaryTimer.Add_Tick({
    try {
        $batch = @()
        [System.Threading.Monitor]::Enter($script:queueLock)
        try {
            while ($script:summaryQueue.Count -gt 0) {
                $batch += $script:summaryQueue[0]
                $script:summaryQueue.RemoveAt(0)
            }
        } finally { [System.Threading.Monitor]::Exit($script:queueLock) }

        if ($batch.Count -gt 0) {
            Populate-PanelsFromSelected -SelectedAddresses $batch
        }
    } catch {}
})
$summaryTimer.Start()

# Show welcome message and launch
Show-WelcomeMessage
Write-Host "Launching application..." -ForegroundColor Cyan
[void]$form.ShowDialog()

# Cleanup
$summaryTimer.Stop()
$summaryTimer.Dispose()
