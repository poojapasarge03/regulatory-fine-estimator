# Docker Compose Startup Script for Day 9
# This script handles starting Docker Desktop and running the multi-service environment

# Run as Administrator!

Write-Host "════════════════════════════════════════════════════════════════"
Write-Host "Day 9: Docker Compose Multi-Service Startup Script"
Write-Host "════════════════════════════════════════════════════════════════"
Write-Host ""

# Check if running as admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "❌ ERROR: This script must be run as Administrator!" -ForegroundColor Red
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'"
    exit 1
}

Write-Host "✅ Running as Administrator" -ForegroundColor Green
Write-Host ""

# Step 1: Navigate to project directory
Write-Host "Step 1: Navigating to project directory..." -ForegroundColor Cyan
$projectPath = "C:\Users\DELL\OneDrive\Desktop\regulatory-fine-estimator\backend\tool"
Set-Location $projectPath
Write-Host "✅ Current Directory: $(Get-Location)" -ForegroundColor Green
Write-Host ""

# Step 2: Check Docker Service Status
Write-Host "Step 2: Checking Docker Service Status..." -ForegroundColor Cyan
$dockerService = Get-Service -Name "com.docker.service" -ErrorAction SilentlyContinue
if ($dockerService) {
    Write-Host "Docker Service Status: $($dockerService.Status)" -ForegroundColor Cyan
    
    if ($dockerService.Status -eq "Stopped") {
        Write-Host "Starting Docker Service..." -ForegroundColor Yellow
        try {
            Start-Service -Name "com.docker.service"
            Start-Sleep -Seconds 10
            Write-Host "✅ Docker Service Started" -ForegroundColor Green
        } catch {
            Write-Host "⚠️  Could not start Docker Service: $_" -ForegroundColor Yellow
            Write-Host "Attempting alternative method..." -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "⚠️  Docker Service not found" -ForegroundColor Yellow
}

Write-Host ""

# Step 3: Start Docker Desktop if not running
Write-Host "Step 3: Verifying Docker Desktop..." -ForegroundColor Cyan
$maxRetries = 5
$retry = 0

do {
    $dockerReady = $false
    try {
        $output = docker ps 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✅ Docker is Ready!" -ForegroundColor Green
            $dockerReady = $true
        }
    } catch {
        # Continue to retry
    }
    
    if (-not $dockerReady) {
        $retry++
        if ($retry -le $maxRetries) {
            Write-Host "Attempt $retry/$maxRetries: Docker not ready, waiting..." -ForegroundColor Yellow
            if ($retry -eq 1) {
                Write-Host "Launching Docker Desktop..." -ForegroundColor Yellow
                Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
            }
            Start-Sleep -Seconds 5
        }
    }
} while (-not $dockerReady -and $retry -lt $maxRetries)

if (-not $dockerReady) {
    Write-Host "❌ Docker Desktop could not be started. Please start it manually." -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 4: Verify JAR is built
Write-Host "Step 4: Checking if JAR is built..." -ForegroundColor Cyan
$jarFile = "target/tool-0.0.1-SNAPSHOT.jar"
if (Test-Path $jarFile) {
    $jarSize = (Get-Item $jarFile).Length / 1MB
    Write-Host "✅ JAR Found: $($jarFile) ($([Math]::Round($jarSize, 2)) MB)" -ForegroundColor Green
} else {
    Write-Host "⚠️  JAR not found. Building with Maven..." -ForegroundColor Yellow
    Write-Host ""
    mvn clean package -DskipTests
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Maven build failed!" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""

# Step 5: Verify docker-compose.yml exists
Write-Host "Step 5: Verifying docker-compose.yml..." -ForegroundColor Cyan
if (Test-Path "docker-compose.yml") {
    Write-Host "✅ docker-compose.yml found" -ForegroundColor Green
} else {
    Write-Host "❌ docker-compose.yml not found!" -ForegroundColor Red
    exit 1
}

Write-Host ""

# Step 6: Verify .env file exists
Write-Host "Step 6: Verifying .env configuration..." -ForegroundColor Cyan
if (Test-Path ".env") {
    Write-Host "✅ .env file found" -ForegroundColor Green
    Write-Host ""
    Write-Host "Environment Configuration:" -ForegroundColor Cyan
    Get-Content .env | ForEach-Object { Write-Host "  $_" }
} else {
    Write-Host "⚠️  .env file not found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "════════════════════════════════════════════════════════════════"
Write-Host "Starting Docker Compose Environment..." -ForegroundColor Green
Write-Host "════════════════════════════════════════════════════════════════"
Write-Host ""
Write-Host "Services to be started:" -ForegroundColor Cyan
Write-Host "  1. 🗄️  PostgreSQL Database (regdb:5432)"
Write-Host "  2. 🔴 Redis Cache (redis:6379)"
Write-Host "  3. 📧 MailHog SMTP (mail:1025 | UI:8025)"
Write-Host "  4. 🚀 Spring Boot App (app:8080)"
Write-Host "  5. 🛠️  Adminer Admin UI (adminer:9090)"
Write-Host ""
Write-Host "Waiting for services to be healthy..."
Write-Host "This may take 30-60 seconds..."
Write-Host ""

# Step 7: Run Docker Compose
docker compose up --build

# Capture exit code
$exitCode = $LASTEXITCODE

if ($exitCode -eq 0) {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════"
    Write-Host "✅ Docker Compose Completed Successfully!" -ForegroundColor Green
    Write-Host "════════════════════════════════════════════════════════════════"
} else {
    Write-Host ""
    Write-Host "════════════════════════════════════════════════════════════════"
    Write-Host "⚠️  Docker Compose exited with code: $exitCode" -ForegroundColor Yellow
    Write-Host "════════════════════════════════════════════════════════════════"
}

exit $exitCode
