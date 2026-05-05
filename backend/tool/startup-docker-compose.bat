@echo off
REM Day 9: Docker Compose Startup Batch File
REM Run this file to start Docker and all services

setlocal enabledelayedexpansion

cls
color 0A
echo.
echo ════════════════════════════════════════════════════════════════
echo  Day 9: Docker Compose Multi-Service Startup
echo ════════════════════════════════════════════════════════════════
echo.

REM Check if running as admin
net session >nul 2>&1
if %errorLevel% neq 0 (
    color 0C
    echo ❌ ERROR: This script must be run as Administrator!
    echo.
    echo Right-click this file and select "Run as administrator"
    echo.
    pause
    exit /b 1
)

color 0A
echo ✅ Running as Administrator
echo.

REM Step 1: Navigate to project directory
echo Step 1: Navigating to project directory...
cd /d "C:\Users\DELL\OneDrive\Desktop\regulatory-fine-estimator\backend\tool"
if %errorLevel% neq 0 (
    color 0C
    echo ❌ Failed to navigate to project directory!
    pause
    exit /b 1
)
echo ✅ Current Directory: %CD%
echo.

REM Step 2: Check Docker service
echo Step 2: Checking Docker Service...
sc query "com.docker.service" >nul 2>&1
if %errorLevel% equ 0 (
    sc query "com.docker.service" | find "RUNNING" >nul 2>&1
    if %errorLevel% neq 0 (
        echo Docker Service is STOPPED. Attempting to start...
        net start "com.docker.service" >nul 2>&1
        if %errorLevel% equ 0 (
            echo ✅ Docker Service Started
            timeout /t 5 /nobreak
        ) else (
            echo ⚠️  Could not start Docker Service via net start
            echo Attempting to start Docker Desktop...
        )
    ) else (
        echo ✅ Docker Service is Running
    )
) else (
    echo ⚠️  Docker Service not found (might use WSL 2)
)
echo.

REM Step 3: Wait for Docker Desktop to be ready
echo Step 3: Ensuring Docker is ready...
set retries=0
:docker_check
if %retries% geq 5 (
    color 0C
    echo ❌ Docker is not responding. Please start Docker Desktop manually.
    echo.
    echo Expected location: C:\Program Files\Docker\Docker\Docker Desktop.exe
    echo.
    pause
    exit /b 1
)

docker ps >nul 2>&1
if %errorLevel% neq 0 (
    set /a retries=!retries!+1
    if !retries! equ 1 (
        echo Launching Docker Desktop...
        start "" "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    )
    echo Attempt !retries!/5: Waiting for Docker...
    timeout /t 3 /nobreak
    goto docker_check
)
color 0A
echo ✅ Docker is Ready!
echo.

REM Step 4: Check if JAR is built
echo Step 4: Checking JAR file...
if exist "target\tool-0.0.1-SNAPSHOT.jar" (
    echo ✅ JAR file found
) else (
    color 0E
    echo ⚠️  JAR not found. Building with Maven...
    call mvn clean package -DskipTests
    if %errorLevel% neq 0 (
        color 0C
        echo ❌ Maven build failed!
        pause
        exit /b 1
    )
    color 0A
)
echo.

REM Step 5: Verify files exist
echo Step 5: Verifying configuration files...
if not exist "docker-compose.yml" (
    color 0C
    echo ❌ docker-compose.yml not found!
    pause
    exit /b 1
)
echo ✅ docker-compose.yml found
echo.

REM Step 6: Display environment config
echo Step 6: Environment Configuration:
if exist ".env" (
    echo ✅ .env file found. Configuration:
    for /f "delims=" %%A in (.env) do (
        echo   %%A
    )
) else (
    echo ⚠️  .env file not found
)
echo.

REM Step 7: Start Docker Compose
color 0E
echo ════════════════════════════════════════════════════════════════
echo  Starting Docker Compose Environment
echo ════════════════════════════════════════════════════════════════
echo.
echo Services to start:
echo   1. 🗄️  PostgreSQL Database (regdb:5432)
echo   2. 🔴 Redis Cache (redis:6379)
echo   3. 📧 MailHog SMTP (mail:1025 ^| UI:8025)
echo   4. 🚀 Spring Boot App (app:8080)
echo   5. 🛠️  Adminer Admin UI (adminer:9090)
echo.
echo Waiting for services to be healthy...
echo This may take 30-60 seconds...
echo.
echo Press CTRL+C to stop all services
echo.

color 0A
docker compose up --build

REM Capture exit code
if %errorLevel% equ 0 (
    color 0A
    echo.
    echo ════════════════════════════════════════════════════════════════
    echo ✅ Docker Compose completed successfully!
    echo ════════════════════════════════════════════════════════════════
) else (
    color 0C
    echo.
    echo ════════════════════════════════════════════════════════════════
    echo ⚠️  Docker Compose exited with code: %errorLevel%
    echo ════════════════════════════════════════════════════════════════
)

echo.
pause
exit /b %errorLevel%
