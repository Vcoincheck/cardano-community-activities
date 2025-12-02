# ============================================================================
# Cardano Community Suite - Complete Installation & Launch Script
# ============================================================================
# This script downloads all Cardano tools, sets up the environment,
# and launches all GUI applications in one go.
# ============================================================================

param(
    [ValidateSet("enduser", "admin", "both")]
    [string]$LaunchApp = "both",
    
    [switch]$SkipToolDownload,
    [switch]$SkipSetupEnv,
    [switch]$NoLaunch
)

# ============================================================================
# CONFIGURATION
# ============================================================================

$CARDANO_ADDRESSES_VERSION = "3.12.0"
$CARDANO_CLI_VERSION = "8.14.0"
$CARDANO_SIGNER_VERSION = "1.32.0"

$TOOLS_DIR = Join-Path $PSScriptRoot "tools"
$DOWNLOADS_DIR = Join-Path $TOOLS_DIR "downloads"
$ADDRESSES_DIR = Join-Path $TOOLS_DIR "cardano-addresses"
$CLI_DIR = Join-Path $TOOLS_DIR "cardano-cli"
$SIGNER_DIR = Join-Path $TOOLS_DIR "cardano-signer"

# Color codes for pretty output
$Colors = @{
    Reset = "`e[0m"
    Green = "`e[92m"
    Blue = "`e[94m"
    Yellow = "`e[93m"
    Red = "`e[91m"
    Cyan = "`e[96m"
}

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Write-Header {
    param([string]$Message)
    Write-Host "`n$($Colors.Cyan)╔════════════════════════════════════════════════════════════╗$($Colors.Reset)"
    Write-Host "$($Colors.Cyan)║ $($Message.PadRight(56)) ║$($Colors.Reset)"
    Write-Host "$($Colors.Cyan)╚════════════════════════════════════════════════════════════╝$($Colors.Reset)`n"
}

function Write-Success {
    param([string]$Message)
    Write-Host "$($Colors.Green)✓ $($Message)$($Colors.Reset)"
}

function Write-Info {
    param([string]$Message)
    Write-Host "$($Colors.Blue)ℹ $($Message)$($Colors.Reset)"
}

function Write-Warn {
    param([string]$Message)
    Write-Host "$($Colors.Yellow)⚠ $($Message)$($Colors.Reset)"
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "$($Colors.Red)✗ $($Message)$($Colors.Reset)"
}

function Detect-Architecture {
    $arch = if ([Environment]::Is64BitProcess) { "x64" } else { "x86" }
    return $arch
}

function Download-File {
    param(
        [string]$URL,
        [string]$OutputPath
    )
    
    try {
        Write-Info "Downloading from: $URL"
        
        if (Test-Path $OutputPath) {
            Write-Warn "File already exists: $(Split-Path $OutputPath -Leaf). Skipping download."
            return $true
        }
        
        $ProgressPreference = 'SilentlyContinue'
        Invoke-WebRequest -Uri $URL -OutFile $OutputPath -UseBasicParsing
        $ProgressPreference = 'Continue'
        
        Write-Success "Downloaded: $(Split-Path $OutputPath -Leaf)"
        return $true
    }
    catch {
        Write-Error-Custom "Failed to download: $($_.Exception.Message)"
        return $false
    }
}

function Extract-Archive-Safe {
    param(
        [string]$ArchivePath,
        [string]$DestinationPath
    )
    
    try {
        Write-Info "Extracting to: $DestinationPath"
        
        # Ensure destination exists
        if (-not (Test-Path $DestinationPath)) {
            New-Item -ItemType Directory -Path $DestinationPath -Force | Out-Null
        }
        
        # Extract based on file extension
        if ($ArchivePath -like "*.zip") {
            Expand-Archive -Path $ArchivePath -DestinationPath $DestinationPath -Force
        }
        elseif ($ArchivePath -like "*.tar.gz" -or $ArchivePath -like "*.tgz") {
            tar -xzf $ArchivePath -C $DestinationPath
        }
        else {
            Write-Error-Custom "Unknown archive format: $ArchivePath"
            return $false
        }
        
        Write-Success "Extracted: $(Split-Path $ArchivePath -Leaf)"
        return $true
    }
    catch {
        Write-Error-Custom "Failed to extract: $($_.Exception.Message)"
        return $false
    }
}

function Test-Tool {
    param(
        [string]$ToolName,
        [string]$Command,
        [string]$ToolPath
    )
    
    try {
        $env:PATH = "$ToolPath;$env:PATH"
        $output = & cmd /c "$Command 2>&1"
        
        if ($LASTEXITCODE -eq 0 -or $output -match "version|Version|VERSION") {
            Write-Success "$ToolName installed and working"
            return $true
        }
        else {
            Write-Warn "$ToolName: $output"
            return $false
        }
    }
    catch {
        Write-Warn "$ToolName not found or not working yet"
        return $false
    }
}

function Create-Env-Setup {
    Write-Header "Creating Environment Setup Script"
    
    $envScript = @"
@echo off
REM Cardano Community Suite - Environment Setup
REM Run this batch file to add tools to your PATH

setlocal enabledelayedexpansion

set "SCRIPT_DIR=%~dp0"
set "TOOLS_DIR=%SCRIPT_DIR%tools"

REM Add tools to PATH
set "PATH=%TOOLS_DIR%\cardano-addresses;%TOOLS_DIR%\cardano-cli;%TOOLS_DIR%\cardano-signer;%PATH%"

REM Display confirmation
echo.
echo $($Colors.Cyan)════════════════════════════════════════════════════════════$($Colors.Reset)
echo $($Colors.Green)Cardano Community Suite Tools - Environment Configured$($Colors.Reset)
echo $($Colors.Cyan)════════════════════════════════════════════════════════════$($Colors.Reset)
echo.
echo Tools directory: %TOOLS_DIR%
echo.
echo Testing installations:
echo.

REM Test each tool
cardano-cli --version >nul 2>&1 && (
    echo $($Colors.Green)✓ cardano-cli is ready$($Colors.Reset)
) || (
    echo $($Colors.Red)✗ cardano-cli not found$($Colors.Reset)
)

cardano-address --version >nul 2>&1 && (
    echo $($Colors.Green)✓ cardano-address is ready$($Colors.Reset)
) || (
    echo $($Colors.Red)✗ cardano-address not found$($Colors.Reset)
)

cardano-signer.exe --version >nul 2>&1 && (
    echo $($Colors.Green)✓ cardano-signer is ready$($Colors.Reset)
) || (
    echo $($Colors.Red)✗ cardano-signer not found$($Colors.Reset)
)

echo.
echo $($Colors.Cyan)════════════════════════════════════════════════════════════$($Colors.Reset)
echo Ready to use: cardano-cli, cardano-address, cardano-signer
echo $($Colors.Cyan)════════════════════════════════════════════════════════════$($Colors.Reset)
echo.

endlocal
"@
    
    $envBatPath = Join-Path $PSScriptRoot "setup-env.bat"
    $envScript | Out-File -FilePath $envBatPath -Encoding ASCII -Force
    Write-Success "Created: setup-env.bat"
}

# ============================================================================
# MAIN INSTALLATION FLOW
# ============================================================================

function Install-Cardano-Tools {
    Write-Header "Step 1: Downloading Cardano Tools"
    
    # Detect architecture
    $arch = Detect-Architecture
    Write-Info "Detected architecture: $arch"
    
    # Create directories
    Write-Info "Creating directories..."
    @($TOOLS_DIR, $DOWNLOADS_DIR, $ADDRESSES_DIR, $CLI_DIR, $SIGNER_DIR) | ForEach-Object {
        if (-not (Test-Path $_)) {
            New-Item -ItemType Directory -Path $_ -Force | Out-Null
        }
    }
    Write-Success "Directories created"
    
    # Download Cardano Addresses
    Write-Info "Downloading Cardano Addresses v$CARDANO_ADDRESSES_VERSION..."
    $addressesURL = "https://github.com/IntersectMBO/cardano-addresses/releases/download/$CARDANO_ADDRESSES_VERSION/cardano-addresses-$CARDANO_ADDRESSES_VERSION-windows.zip"
    $addressesZip = Join-Path $DOWNLOADS_DIR "cardano-addresses-$CARDANO_ADDRESSES_VERSION.zip"
    if (Download-File $addressesURL $addressesZip) {
        Extract-Archive-Safe $addressesZip $ADDRESSES_DIR | Out-Null
    }
    
    # Download Cardano CLI
    Write-Info "Downloading Cardano CLI v$CARDANO_CLI_VERSION..."
    $cliURL = "https://github.com/IntersectMBO/cardano-cli/releases/download/$CARDANO_CLI_VERSION/cardano-cli-$CARDANO_CLI_VERSION-windows.zip"
    $cliZip = Join-Path $DOWNLOADS_DIR "cardano-cli-$CARDANO_CLI_VERSION.zip"
    if (Download-File $cliURL $cliZip) {
        Extract-Archive-Safe $cliZip $CLI_DIR | Out-Null
    }
    
    # Download Cardano Signer
    Write-Info "Downloading Cardano Signer v$CARDANO_SIGNER_VERSION..."
    $signerURL = "https://github.com/gitmachtl/cardano-signer/releases/download/v$CARDANO_SIGNER_VERSION/cardano-signer.exe"
    $signerExe = Join-Path $SIGNER_DIR "cardano-signer.exe"
    Download-File $signerURL $signerExe | Out-Null
    
    Write-Header "Step 2: Verifying Installations"
    
    # Verify installations
    $addressExe = Get-ChildItem -Path $ADDRESSES_DIR -Name "cardano-address*" -ErrorAction SilentlyContinue | Select-Object -First 1
    $cliExe = Get-ChildItem -Path $CLI_DIR -Name "cardano-cli*" -ErrorAction SilentlyContinue | Select-Object -First 1
    $signerExists = Test-Path (Join-Path $SIGNER_DIR "cardano-signer.exe")
    
    if ($addressExe) { Write-Success "Cardano Addresses: Ready" }
    if ($cliExe) { Write-Success "Cardano CLI: Ready" }
    if ($signerExists) { Write-Success "Cardano Signer: Ready" }
}

function Setup-Environment {
    Write-Header "Step 3: Setting Up Environment"
    
    Create-Env-Setup
    
    # Update current session PATH
    $env:PATH = "$ADDRESSES_DIR;$CLI_DIR;$SIGNER_DIR;$env:PATH"
    Write-Success "Environment PATH updated for current session"
    Write-Warn "To persist PATH changes, run: setup-env.bat"
}

function Launch-GUI-Apps {
    param([string]$AppType)
    
    Write-Header "Step 4: Launching GUI Applications"
    
    $endUserGUI = Join-Path $PSScriptRoot "end-user-app" "EndUserGUI.ps1"
    $adminGUI = Join-Path $PSScriptRoot "community-admin" "AdminGUI.ps1"
    
    $launchCount = 0
    
    if (($AppType -eq "both" -or $AppType -eq "enduser") -and (Test-Path $endUserGUI)) {
        Write-Info "Launching End-User Application..."
        try {
            Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$endUserGUI`"" -WorkingDirectory (Split-Path $endUserGUI)
            Write-Success "End-User Application launched"
            $launchCount++
        }
        catch {
            Write-Error-Custom "Failed to launch End-User Application: $($_.Exception.Message)"
        }
    }
    
    if (($AppType -eq "both" -or $AppType -eq "admin") -and (Test-Path $adminGUI)) {
        Write-Info "Launching Admin Application..."
        try {
            Start-Process powershell -ArgumentList "-ExecutionPolicy Bypass -File `"$adminGUI`"" -WorkingDirectory (Split-Path $adminGUI)
            Write-Success "Admin Application launched"
            $launchCount++
        }
        catch {
            Write-Error-Custom "Failed to launch Admin Application: $($_.Exception.Message)"
        }
    }
    
    if ($launchCount -eq 0) {
        Write-Warn "No GUI applications found to launch"
        Write-Info "Looking for scripts in:"
        Write-Info "  - $endUserGUI"
        Write-Info "  - $adminGUI"
    }
}

function Show-Summary {
    Write-Host "`n$($Colors.Cyan)╔════════════════════════════════════════════════════════════╗$($Colors.Reset)"
    Write-Host "$($Colors.Cyan)║$($Colors.Green) CARDANO COMMUNITY SUITE - INSTALLATION COMPLETE$($Colors.Cyan)           ║$($Colors.Reset)"
    Write-Host "$($Colors.Cyan)╚════════════════════════════════════════════════════════════╝$($Colors.Reset)`n"
    
    Write-Host "$($Colors.Green)✓ Cardano Tools Downloaded:$($Colors.Reset)"
    Write-Host "  • Cardano Addresses v$CARDANO_ADDRESSES_VERSION"
    Write-Host "  • Cardano CLI v$CARDANO_CLI_VERSION"
    Write-Host "  • Cardano Signer v$CARDANO_SIGNER_VERSION"
    Write-Host ""
    
    Write-Host "$($Colors.Green)✓ Locations:$($Colors.Reset)"
    Write-Host "  • Tools: $TOOLS_DIR"
    Write-Host "  • End-User App: $(Join-Path $PSScriptRoot 'end-user-app\EndUserGUI.ps1')"
    Write-Host "  • Admin App: $(Join-Path $PSScriptRoot 'community-admin\AdminGUI.ps1')"
    Write-Host ""
    
    Write-Host "$($Colors.Green)✓ Quick Commands:$($Colors.Reset)"
    Write-Host "  • Setup environment: .\setup-env.bat"
    Write-Host "  • Run end-user GUI: .\end-user-app\EndUserGUI.ps1"
    Write-Host "  • Run admin GUI: .\community-admin\AdminGUI.ps1"
    Write-Host "  • Test tools:"
    Write-Host "    - cardano-cli --version"
    Write-Host "    - cardano-address --version"
    Write-Host "    - cardano-signer.exe --version"
    Write-Host ""
    
    Write-Host "$($Colors.Cyan)════════════════════════════════════════════════════════════$($Colors.Reset)`n"
}

# ============================================================================
# EXECUTION FLOW
# ============================================================================

Write-Header "CARDANO COMMUNITY SUITE - COMPLETE INSTALLER"

Write-Info "ExecutionPolicy: $($LaunchApp | IfPresent {$_} {'both'})"
Write-Info "SkipToolDownload: $SkipToolDownload"
Write-Info "SkipSetupEnv: $SkipSetupEnv"
Write-Info "NoLaunch: $NoLaunch"

Write-Host ""

# Install tools
if (-not $SkipToolDownload) {
    Install-Cardano-Tools
}
else {
    Write-Warn "Skipping tool download"
}

# Setup environment
if (-not $SkipSetupEnv) {
    Setup-Environment
}
else {
    Write-Warn "Skipping environment setup"
}

# Launch applications
if (-not $NoLaunch) {
    Launch-GUI-Apps $LaunchApp
}
else {
    Write-Warn "Skipping application launch"
}

# Show summary
Show-Summary

Write-Host "$($Colors.Green)All done! Your Cardano Community Suite is ready to use.$($Colors.Reset)`n"
