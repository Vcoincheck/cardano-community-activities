# ============================================
# CARDANO COMMUNITY SUITE - SETUP SCRIPT
# ============================================
# Installs all three WinUI 3 applications:
# 1. Cardano Launcher (main entry point)
# 2. End-User Tools (keypair generation, signing)
# 3. Community Admin Dashboard (verification, registry)

param(
    [ValidateSet('Debug', 'Release')]
    [string]$Configuration = 'Release',
    
    [switch]$SkipRestore,
    [switch]$SkipTest,
    [switch]$OpenAfterBuild,
    [switch]$Help
)

# ============================================
# CONFIGURATION
# ============================================

$ErrorActionPreference = "Stop"
$WarningPreference = "Continue"

# Get script directory
if (-not [string]::IsNullOrEmpty($PSScriptRoot)) {
    $ScriptPath = $PSScriptRoot
} else {
    $ScriptPath = Get-Location
}

$SuitePath = $ScriptPath
$LauncherPath = Join-Path $SuitePath "cardano-launcher-winui"
$EndUserPath = Join-Path $SuitePath "end-user-app-winui"
$AdminPath = Join-Path $SuitePath "community-admin-winui"

# Project names for output
$Projects = @(
    @{ Name = "Cardano Launcher"; Path = $LauncherPath; Exe = "CardanoLauncher" },
    @{ Name = "End-User Tools"; Path = $EndUserPath; Exe = "CardanoEndUserTool" },
    @{ Name = "Community Admin"; Path = $AdminPath; Exe = "CardanoCommunityAdmin" }
)

# ============================================
# FUNCTIONS
# ============================================

function Write-Header {
    param([string]$Message)
    Write-Host ""
    Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║  $Message" -PadRight 54 -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step {
    param([string]$Message, [int]$Step, [int]$Total)
    Write-Host "[$Step/$Total] ▶ $Message" -ForegroundColor Yellow
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Cyan
}

function Write-Warning-Custom {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Show-Help {
    Write-Host @"
╔════════════════════════════════════════════════════════════════════════════╗
║  CARDANO COMMUNITY SUITE - SETUP SCRIPT                                   ║
║  Installs all three WinUI 3 applications                                  ║
╚════════════════════════════════════════════════════════════════════════════╝

USAGE:
    .\setup.ps1 [OPTIONS]

OPTIONS:
    -Configuration <string>     Build configuration: Debug or Release (default: Release)
    -SkipRestore               Skip dotnet restore (use if dependencies cached)
    -SkipTest                  Skip validation tests after build
    -OpenAfterBuild            Launch Cardano Launcher after successful build
    -Help                      Show this help message

EXAMPLES:
    # Standard setup (Release build, no launch)
    .\setup.ps1

    # Debug build for development
    .\setup.ps1 -Configuration Debug

    # Full setup and launch the app
    .\setup.ps1 -OpenAfterBuild

    # Quick rebuild (skip restore)
    .\setup.ps1 -SkipRestore

REQUIREMENTS:
    • Windows 10 Build 22621 or Windows 11
    • .NET 8.0 SDK or later
    • 2 GB free disk space
    • Administrator access (optional, for installation)

WHAT IT INSTALLS:
    1️⃣  Cardano Launcher (main entry point)
    2️⃣  End-User Tools (keypair generation, signing, wallet export)
    3️⃣  Community Admin Dashboard (challenges, verification, registry)

OUTPUT LOCATION:
    After successful build, executables are located in:
    • Launcher:     cardano-launcher-winui\bin\$Configuration\net8.0-windows...\
    • End-User:     end-user-app-winui\bin\$Configuration\net8.0-windows...\
    • Admin:        community-admin-winui\bin\$Configuration\net8.0-windows...\

TROUBLESHOOTING:
    If build fails:
    1. Verify .NET 8.0 SDK: dotnet --version
    2. Check disk space: Get-Volume
    3. Try: dotnet clean
    4. Try: .\setup.ps1 -Configuration Debug

For more information, see README.md or docs/
"@
}

function Check-Requirements {
    Write-Header "🔍 Checking Requirements"
    
    $step = 1
    $total = 4
    
    # Check .NET SDK
    Write-Step "Checking .NET SDK installation" $step $total
    $dotnetVersion = dotnet --version 2>$null
    if (-not $dotnetVersion) {
        Write-Error-Custom ".NET SDK not found. Please install .NET 8.0 SDK or later."
        exit 1
    }
    
    $majorVersion = [int]($dotnetVersion.Split('.')[0])
    if ($majorVersion -lt 8) {
        Write-Error-Custom ".NET 8.0 or later required. Found: $dotnetVersion"
        exit 1
    }
    Write-Success ".NET SDK $dotnetVersion"
    
    # Check Windows version
    $step++
    Write-Step "Checking Windows version" $step $total
    $osInfo = [System.Environment]::OSVersion
    $buildNumber = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion").CurrentBuildNumber
    
    if ($buildNumber -lt 22621) {
        Write-Error-Custom "Windows 10 Build 22621 or Windows 11 required. Found build: $buildNumber"
        exit 1
    }
    Write-Success "Windows Build $buildNumber"
    
    # Check project directories
    $step++
    Write-Step "Checking project directories" $step $total
    $allFound = $true
    foreach ($project in $Projects) {
        if (Test-Path $project.Path) {
            Write-Host "  ✓ $(Split-Path $project.Path -Leaf)" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $(Split-Path $project.Path -Leaf) - NOT FOUND" -ForegroundColor Red
            $allFound = $false
        }
    }
    
    if (-not $allFound) {
        Write-Error-Custom "Some project directories not found. Run from cardano-community-suite directory."
        exit 1
    }
    
    # Check disk space
    $step++
    Write-Step "Checking disk space" $step $total
    $drive = (Get-Item $SuitePath).PSDrive.Name
    $volume = Get-Volume -DriveLetter $drive
    $freeGB = [math]::Round($volume.SizeRemaining / 1GB, 2)
    
    if ($freeGB -lt 2) {
        Write-Warning-Custom "Low disk space: ${freeGB}GB free. Build may fail. Minimum: 2GB"
    } else {
        Write-Success "$freeGB GB free disk space"
    }
}

function Build-Project {
    param(
        [string]$ProjectName,
        [string]$ProjectPath,
        [int]$Step,
        [int]$Total
    )
    
    Write-Step "Building $ProjectName" $Step $Total
    Write-Info "Location: $ProjectPath"
    Write-Info "Configuration: $Configuration"
    
    # Change to project directory
    Push-Location $ProjectPath
    try {
        # Restore if not skipped
        if (-not $SkipRestore) {
            Write-Host "  → Restoring NuGet packages..." -ForegroundColor Gray
            $restoreOutput = dotnet restore 2>&1
            if ($LASTEXITCODE -ne 0) {
                Write-Error-Custom "$ProjectName restore failed"
                Write-Host $restoreOutput
                exit 1
            }
        }
        
        # Build project
        Write-Host "  → Building project..." -ForegroundColor Gray
        $buildOutput = dotnet build -c $Configuration 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Error-Custom "$ProjectName build failed"
            Write-Host $buildOutput
            exit 1
        }
        
        Write-Success "$ProjectName built successfully"
        
    } finally {
        Pop-Location
    }
}

function Validate-Build {
    param(
        [string]$ProjectName,
        [string]$ProjectPath,
        [string]$ExeName,
        [int]$Step,
        [int]$Total
    )
    
    Write-Step "Validating $ProjectName" $Step $Total
    
    # Find the built executable
    $binPath = Join-Path $ProjectPath "bin" $Configuration
    $exePath = Get-ChildItem -Path $binPath -Recurse -Filter "$ExeName.exe" 2>$null | Select-Object -First 1
    
    if ($exePath) {
        $sizeKB = [math]::Round($exePath.Length / 1KB, 2)
        Write-Success "$ProjectName executable found: $($exePath.FullName) ($sizeKB KB)"
        return $exePath.FullName
    } else {
        Write-Error-Custom "$ProjectName executable not found in $binPath"
        return $null
    }
}

function Create-Shortcuts {
    param([hashtable[]]$Executables)
    
    Write-Header "📌 Creating Shortcuts"
    
    $desktopPath = [System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Desktop)
    $startMenuPath = Join-Path ([System.Environment]::GetFolderPath([System.Environment+SpecialFolder]::Programs)) "Cardano Community Suite"
    
    try {
        # Create Start Menu folder
        if (-not (Test-Path $startMenuPath)) {
            New-Item -ItemType Directory -Path $startMenuPath -Force | Out-Null
        }
        
        foreach ($exe in $Executables) {
            if ($exe.Path) {
                $shortcutName = $exe.Name -replace " ", "_"
                
                # Desktop shortcut
                $desktopShortcut = Join-Path $desktopPath "$($exe.Name).lnk"
                $shell = New-Object -ComObject WScript.Shell
                $shortcut = $shell.CreateShortcut($desktopShortcut)
                $shortcut.TargetPath = $exe.Path
                $shortcut.WorkingDirectory = Split-Path $exe.Path -Parent
                $shortcut.Save()
                Write-Success "Desktop shortcut created: $($exe.Name)"
                
                # Start Menu shortcut
                $startMenuShortcut = Join-Path $startMenuPath "$($exe.Name).lnk"
                $shortcut = $shell.CreateShortcut($startMenuShortcut)
                $shortcut.TargetPath = $exe.Path
                $shortcut.WorkingDirectory = Split-Path $exe.Path -Parent
                $shortcut.Save()
                Write-Success "Start Menu shortcut created: $($exe.Name)"
            }
        }
    } catch {
        Write-Warning-Custom "Failed to create shortcuts: $($_.Exception.Message)"
        Write-Info "You can manually create shortcuts by right-clicking the executable"
    }
}

function Show-Summary {
    param([hashtable[]]$Executables)
    
    Write-Header "✨ Setup Complete"
    
    Write-Host "All three applications have been successfully built!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📦 Installed Applications:" -ForegroundColor Cyan
    Write-Host ""
    
    $num = 1
    foreach ($exe in $Executables) {
        if ($exe.Path) {
            Write-Host "$num. $($exe.Name)" -ForegroundColor Green
            Write-Host "   📁 $($exe.Path)" -ForegroundColor Gray
            $sizeKB = [math]::Round((Get-Item $exe.Path).Length / 1KB, 2)
            Write-Host "   💾 Size: $sizeKB KB" -ForegroundColor Gray
            Write-Host ""
            $num++
        }
    }
    
    Write-Host "🚀 Next Steps:" -ForegroundColor Cyan
    Write-Host "   1. Click 'Cardano Launcher' to start the main application"
    Write-Host "   2. Use the launcher to access End-User Tools or Admin Dashboard"
    Write-Host "   3. Check documentation in docs/ folder for detailed guides"
    Write-Host ""
    Write-Host "📖 Documentation:" -ForegroundColor Cyan
    Write-Host "   • README.md - Project overview"
    Write-Host "   • docs/API_SPEC.md - API documentation"
    Write-Host "   • docs/SECURITY_MODEL.md - Security architecture"
    Write-Host "   • docs/USER_FLOW_*.md - User workflows"
    Write-Host ""
}

# ============================================
# MAIN EXECUTION
# ============================================

# Show help if requested
if ($Help) {
    Show-Help
    exit 0
}

Write-Host @"
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║         🔗 CARDANO COMMUNITY SUITE - SETUP & BUILD SYSTEM 🔗              ║
║                                                                            ║
║  Installing: Launcher + End-User Tools + Community Admin Dashboard        ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Magenta

# Check all requirements
Check-Requirements

# Build all projects
Write-Header "🔨 Building Applications"
$step = 1
$totalSteps = $Projects.Count * 2

foreach ($project in $Projects) {
    Build-Project -ProjectName $project.Name -ProjectPath $project.Path -Step $step -Total $totalSteps
    $step++
}

# Validate builds
if (-not $SkipTest) {
    Write-Header "✔️  Validating Builds"
    $executables = @()
    $step = 1
    
    foreach ($project in $Projects) {
        $exePath = Validate-Build -ProjectName $project.Name -ProjectPath $project.Path -ExeName $project.Exe -Step $step -Total $totalSteps
        if ($exePath) {
            $executables += @{ Name = $project.Name; Path = $exePath }
        }
        $step++
    }
    
    # Create shortcuts
    if ($executables.Count -gt 0) {
        try {
            Create-Shortcuts -Executables $executables
        } catch {
            Write-Warning-Custom "Shortcut creation skipped"
        }
    }
} else {
    Write-Info "Build validation skipped (-SkipTest)"
}

# Show summary
Show-Summary -Executables $executables

# Launch if requested
if ($OpenAfterBuild -and $executables[0]) {
    Write-Info "Launching Cardano Launcher..."
    Start-Process -FilePath $executables[0].Path
}

Write-Host "Setup script completed successfully! ✨" -ForegroundColor Magenta
Write-Host ""
