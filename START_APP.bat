@echo off
REM ============================================================================
REM CarQR Full Stack Startup Script
REM This script starts: PostgreSQL → Backend API → Flutter App
REM ============================================================================

setlocal enabledelayedexpansion

echo.
echo ╔════════════════════════════════════════════════════════════╗
echo ║        CarQR Full Stack Startup Script                    ║
echo ╚════════════════════════════════════════════════════════════╝
echo.

REM Configuration
set "BACKEND_DIR=C:\src\car_QR\backend"
set "PROJECT_DIR=C:\src\car_QR"
set "DB_USER=postgres"
set "DB_PASSWORD=Trushal@1234"
set "DB_NAME=carqr_db"
set "API_PORT=3000"
set "API_URL=http://localhost:3000"

REM ============================================================================
REM Step 1: Check PostgreSQL
REM ============================================================================
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo [1/3] Checking PostgreSQL...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

psql --version >nul 2>&1
if errorlevel 1 (
    echo ✗ PostgreSQL NOT found!
    echo   Please install PostgreSQL and add it to PATH
    pause
    exit /b 1
) else (
    for /f "tokens=*" %%i in ('psql --version') do set "PG_VERSION=%%i"
    echo ✓ PostgreSQL found: !PG_VERSION!
    echo ✓ Database '!DB_NAME!' ready
)

echo.

REM ============================================================================
REM Step 2: Start Backend API
REM ============================================================================
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo [2/3] Starting Backend API on port !API_PORT!...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

REM Check if dependencies are installed
if not exist "!BACKEND_DIR!\node_modules" (
    echo   Installing backend dependencies...
    pushd !BACKEND_DIR!
    call npm install
    popd
    echo   ✓ Dependencies installed
)

REM Start backend in new window
echo   Starting Node.js server...
start "CarQR Backend API" cmd /k "cd /d !BACKEND_DIR! && echo Starting CarQR Backend API... && node server.js"
echo   ✓ Backend started in new window

REM Wait for backend to be ready
echo   Waiting for API to be ready...
setlocal enabledelayedexpansion
set "RETRY_COUNT=0"
set "MAX_RETRIES=30"

:wait_for_api
if !RETRY_COUNT! geq !MAX_RETRIES! (
    echo   ⚠ API may not be responding, continuing anyway...
    goto api_ready
)

timeout /t 1 /nobreak >nul
set /a "RETRY_COUNT+=1"

REM Simple health check with curl if available
curl -s !API_URL!/health >nul 2>&1
if errorlevel 0 (
    echo   ✓ API is ready at !API_URL!
    goto api_ready
) else (
    goto wait_for_api
)

:api_ready
echo.

REM ============================================================================
REM Step 3: Prepare Flutter App
REM ============================================================================
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo [3/3] Preparing Flutter App...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

pushd !PROJECT_DIR!

echo   Installing Flutter dependencies...
call flutter pub get >nul 2>&1
echo   ✓ Dependencies ready

echo   API Configuration:
echo     - Base URL: http://localhost:3000/api/v1
echo     - DB: carqr_db (PostgreSQL)
echo     - User: postgres

echo.

REM ============================================================================
REM Step 4: Start Flutter App
REM ============================================================================
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo [4/3] Starting Flutter App...
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.

echo Running: flutter run -d chrome
echo.

call flutter run -d chrome

popd
