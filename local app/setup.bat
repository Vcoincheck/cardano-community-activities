@echo off
REM ============================================
REM CARDANO COMMUNITY SUITE - SETUP SCRIPT
REM ============================================
REM Builds and installs all three WinUI 3 applications:
REM 1. Cardano Launcher (main entry point)
REM 2. End-User Tools (keypair generation, signing)
REM 3. Community Admin Dashboard (verification, registry)
REM Requires: Windows 10 Build 22621+, .NET 8.0 SDK

setlocal enabledelayedexpansion

REM Configuration
set "Configuration=Release"
set "SkipRestore=0"
set "OpenAfterBuild=0"

REM Parse command line arguments
if "%1"=="--help" goto show_help
if "%1"=="/?" goto show_help
if "%1"=="-Debug" set "Configuration=Debug"
if "%1"=="--skip-restore" set "SkipRestore=1"
if "%1"=="--open" set "OpenAfterBuild=1"

REM Get current directory
set "SuitePath=%~dp0"

echo.
echo ╔════════════════════════════════════════════════════════════════════════════╗
echo ║                                                                            ║
echo ║         CARDANO COMMUNITY SUITE - SETUP ^& BUILD SYSTEM                   ║
echo ║                                                                            ║
echo ║  Installing: Launcher + End-User Tools + Community Admin Dashboard        ║
echo ║                                                                            ║
echo ╚════════════════════════════════════════════════════════════════════════════╝
echo.

REM Check .NET SDK
echo [1/5] Checking .NET SDK installation...
dotnet --version >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: .NET SDK not found. Please install .NET 8.0 SDK or later.
    echo Visit: https://dotnet.microsoft.com/download
    echo.
    pause
    exit /b 1
)

for /f "tokens=1" %%i in ('dotnet --version') do set "DotNetVersion=%%i"
echo [OK] .NET SDK !DotNetVersion! found
echo.

REM Build Cardano Launcher
echo [2/5] Building Cardano Launcher...
cd /d "%SuitePath%cardano-launcher-winui"
if "%SkipRestore%"=="0" (
    dotnet restore >nul 2>&1
)
dotnet build -c %Configuration% >nul 2>&1
if errorlevel 1 (
    echo ERROR: Failed to build Cardano Launcher
    pause
    exit /b 1
)
echo [OK] Cardano Launcher built
echo.

REM Build End-User Tools
echo [3/5] Building End-User Tools...
cd /d "%SuitePath%end-user-app-winui"
if "%SkipRestore%"=="0" (
    dotnet restore >nul 2>&1
)
dotnet build -c %Configuration% >nul 2>&1
if errorlevel 1 (
    echo ERROR: Failed to build End-User Tools
    pause
    exit /b 1
)
echo [OK] End-User Tools built
echo.

REM Build Community Admin
echo [4/5] Building Community Admin Dashboard...
cd /d "%SuitePath%community-admin-winui"
if "%SkipRestore%"=="0" (
    dotnet restore >nul 2>&1
)
dotnet build -c %Configuration% >nul 2>&1
if errorlevel 1 (
    echo ERROR: Failed to build Community Admin Dashboard
    pause
    exit /b 1
)
echo [OK] Community Admin Dashboard built
echo.

REM Create shortcuts (optional)
echo [5/5] Creating shortcuts...
set "DesktopPath=%USERPROFILE%\Desktop"
set "StartMenuPath=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Cardano Community Suite"

if not exist "%StartMenuPath%" mkdir "%StartMenuPath%"

REM Find executables
for /f "delims=" %%f in ('dir /b /s "%SuitePath%cardano-launcher-winui\bin\%Configuration%\*\CardanoLauncher.exe" 2^>nul') do set "LauncherExe=%%f"
for /f "delims=" %%f in ('dir /b /s "%SuitePath%end-user-app-winui\bin\%Configuration%\*\CardanoEndUserTool.exe" 2^>nul') do set "EndUserExe=%%f"
for /f "delims=" %%f in ('dir /b /s "%SuitePath%community-admin-winui\bin\%Configuration%\*\CardanoCommunityAdmin.exe" 2^>nul') do set "AdminExe=%%f"

if not "!LauncherExe!"=="" (
    echo [OK] Cardano Launcher found
) else (
    echo [WARN] Cardano Launcher executable not found
)
echo.

echo ╔════════════════════════════════════════════════════════════════════════════╗
echo ║                      SETUP COMPLETE                                        ║
echo ╚════════════════════════════════════════════════════════════════════════════╝
echo.
echo All three applications have been successfully built!
echo.
echo Next steps:
echo   1. Double-click 'Cardano Launcher' to start
echo   2. Use the launcher to access other tools
echo   3. Check README.md for documentation
echo.

if "%OpenAfterBuild%"=="1" (
    if not "!LauncherExe!"=="" (
        start "" "!LauncherExe!"
    )
)

pause
exit /b 0

REM Success end
goto end_success

:end_success
exit /b 0

:show_help
cls
echo.
echo CARDANO COMMUNITY SUITE - SETUP SCRIPT
echo Installs all three WinUI 3 applications
echo.
echo USAGE:
echo   setup.bat [OPTIONS]
echo.
echo OPTIONS:
echo   -Debug              Build Debug configuration instead of Release
echo   --skip-restore      Skip NuGet restore (faster rebuild)
echo   --open              Launch Cardano Launcher after build
echo   --help, /?          Show this help message
echo.
echo EXAMPLES:
echo   setup.bat                    (standard setup)
echo   setup.bat -Debug             (debug build)
echo   setup.bat --open             (setup and launch)
echo   setup.bat -Debug --skip-restore
echo.
echo REQUIREMENTS:
echo   - Windows 10 Build 22621 or Windows 11
echo   - .NET 8.0 SDK or later
echo   - 2 GB free disk space
echo.
pause
exit /b 0
