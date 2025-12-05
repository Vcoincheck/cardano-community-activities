@echo off
REM Setup Python Virtual Environment for Cardano Community Activities (Windows)

setlocal enabledelayedexpansion

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"
set "VENV_DIR=%SCRIPT_DIR%venv"

echo.
echo 📦 Creating Python virtual environment...
python -m venv "%VENV_DIR%"

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Error creating virtual environment
    exit /b 1
)

echo ✅ Virtual environment created at: %VENV_DIR%
echo.
echo 🔄 Activating virtual environment and installing dependencies...
echo.

REM Activate venv and install requirements
call "%VENV_DIR%\Scripts\activate.bat"

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Error activating virtual environment
    exit /b 1
)

echo Upgrading pip, setuptools, wheel...
python -m pip install --upgrade pip setuptools wheel

echo.
echo Installing requirements from requirements.txt...
pip install -r "%SCRIPT_DIR%requirements.txt"

if %ERRORLEVEL% NEQ 0 (
    echo ❌ Error installing requirements
    exit /b 1
)

echo.
echo ✅ Installation complete!
echo.
echo 📝 To activate this virtual environment, run:
echo    %VENV_DIR%\Scripts\activate.bat
echo.
echo 📝 To run the app with this venv:
echo    cd %SCRIPT_DIR%
echo    %VENV_DIR%\Scripts\activate.bat
echo    python app/main_launcher.py
echo.
echo 📝 To deactivate:
echo    deactivate
echo.

pause
