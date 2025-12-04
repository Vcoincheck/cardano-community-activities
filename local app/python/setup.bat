@echo off
REM Setup script for Python application on Windows

echo ======================================
echo Cardano Community Activities - Setup
echo ======================================

REM Check Python version
python --version
if %ERRORLEVEL% NEQ 0 (
    echo Error: Python is not installed or not in PATH
    pause
    exit /b 1
)

REM Create virtual environment
echo.
echo Creating virtual environment...
python -m venv venv

REM Activate virtual environment
echo Activating virtual environment...
call venv\Scripts\activate.bat

REM Install dependencies
echo.
echo Installing dependencies...
python -m pip install --upgrade pip
pip install -r requirements.txt

echo.
echo ======================================
echo.
echo Setup completed successfully!
echo.
echo To run the application:
echo   venv\Scripts\activate.bat
echo   python main.py
echo.
echo ======================================
pause
