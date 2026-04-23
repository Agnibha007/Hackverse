@echo off
REM Neon Drive - Setup Script for Windows
REM This script helps with initial setup and database configuration

echo 🚀 Neon Drive - Initialization Script
echo =====================================
echo.

REM Check Node.js
echo 📋 Checking Node.js...
node --version >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('node --version') do set NODE_VERSION=%%i
    echo ✓ Node.js %NODE_VERSION% found
) else (
    echo ✗ Node.js not found. Please install Node.js 18+
    pause
    exit /b 1
)

REM Backend setup
echo.
echo 📦 Setting up Backend...
cd backend
if exist ".env" (
    echo ⚠ .env already exists
) else (
    copy .env.example .env
    echo ✓ Created .env file
)

call npm install
echo ✓ Backend dependencies installed

REM Frontend setup
echo.
echo 📦 Setting up Frontend...
cd ..\frontend
if exist ".env.local" (
    echo ⚠ .env.local already exists
) else (
    copy .env.example .env.local
    echo ✓ Created .env.local file
)

call npm install
echo ✓ Frontend dependencies installed

echo.
echo =====================================
echo ✓ Setup Complete!
echo.
echo Next steps:
echo 1. Update database URL in backend\.env
echo 2. Run migrations: cd backend ^&^& npm run migrate
echo 3. Start backend: npm run dev
echo 4. Start frontend (in new terminal): cd frontend ^&^& npm run dev
echo.
echo Frontend: http://localhost:5173
echo Backend: http://localhost:5000
echo.
pause
