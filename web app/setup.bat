@echo off
REM ============================================
REM CARDANO COMMUNITY SUITE - WEB SETUP SCRIPT
REM ============================================
REM Automated setup for development environment

echo.
echo ╔════════════════════════════════════════════════════╗
echo ║  Cardano Community Suite - Web Setup              ║
echo ╚════════════════════════════════════════════════════╝
echo.

REM Check Node.js
echo ✓ Checking Node.js...
node -v >nul 2>&1
if errorlevel 1 (
    echo ✗ Node.js not found. Please install from https://nodejs.org/
    exit /b 1
)
for /f "tokens=*" %%i in ('node -v') do echo   Version: %%i

REM Check npm
echo.
echo ✓ Checking npm...
for /f "tokens=*" %%i in ('npm -v') do echo   Version: %%i

REM Setup backend
echo.
echo ✓ Setting up backend...
cd backend
call npm install
echo   Backend dependencies installed

REM Setup frontend
echo.
echo ✓ Setting up frontend...
cd ..\frontend
call npm install
echo   Frontend dependencies installed

REM Done
echo.
echo ✓ Setup complete!
echo.
echo ════════════════════════════════════════════════════
echo Start development servers:
echo.
echo Terminal 1 - Backend:
echo   cd backend ^&^& npm run dev
echo.
echo Terminal 2 - Frontend:
echo   cd frontend ^&^& npm run dev
echo.
echo Then open: http://localhost:5173
echo ════════════════════════════════════════════════════
echo.
pause
