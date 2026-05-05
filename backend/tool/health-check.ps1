# Day 9: Quick Docker Compose Health Check
# Fast verification that all services are up and running

Write-Host "🏥 Docker Compose Health Check" -ForegroundColor Cyan
Write-Host "════════════════════════════════════════════════════" -ForegroundColor Gray

# Check if Docker is running
Write-Host "`n1️⃣  Checking Docker..." -ForegroundColor Yellow
try {
    $version = & docker --version 2>&1
    Write-Host "✓ Docker is installed: $version" -ForegroundColor Green
} catch {
    Write-Host "✗ Docker not found. Please install Docker Desktop." -ForegroundColor Red
    exit 1
}

# Check running containers
Write-Host "`n2️⃣  Checking running containers..." -ForegroundColor Yellow
$containers = & docker-compose ps --format "{{.Names}}" 2>&1
if ($containers) {
    Write-Host "✓ Containers running:" -ForegroundColor Green
    $containers | ForEach-Object { Write-Host "  - $_" -ForegroundColor Green }
} else {
    Write-Host "✗ No containers running. Run: docker-compose up --build" -ForegroundColor Yellow
}

# Test Database
Write-Host "`n3️⃣  Testing PostgreSQL..." -ForegroundColor Yellow
try {
    $result = & docker-compose exec -T db pg_isready -U postgres 2>&1
    Write-Host "✓ Database: READY" -ForegroundColor Green
} catch {
    Write-Host "✗ Database connection failed" -ForegroundColor Red
}

# Test Redis
Write-Host "`n4️⃣  Testing Redis..." -ForegroundColor Yellow
try {
    $result = & docker-compose exec -T redis redis-cli ping 2>&1
    if ($result -match "PONG") {
        Write-Host "✓ Redis: PONG" -ForegroundColor Green
    }
} catch {
    Write-Host "✗ Redis connection failed" -ForegroundColor Red
}

# Test Spring Boot Health
Write-Host "`n5️⃣  Testing Spring Boot App..." -ForegroundColor Yellow
try {
    $health = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing -ErrorAction Stop
    $status = $health.Content | ConvertFrom-Json
    Write-Host "✓ App Status: $($status.status)" -ForegroundColor Green
} catch {
    Write-Host "✗ App not responding at http://localhost:8080" -ForegroundColor Red
}

# Test MailHog
Write-Host "`n6️⃣  Testing MailHog..." -ForegroundColor Yellow
try {
    $mail = Invoke-WebRequest -Uri "http://localhost:8025" -UseBasicParsing -ErrorAction Stop
    Write-Host "✓ MailHog UI: Available at http://localhost:8025" -ForegroundColor Green
} catch {
    Write-Host "✗ MailHog not responding" -ForegroundColor Yellow
}

# Test Adminer
Write-Host "`n7️⃣  Testing Adminer..." -ForegroundColor Yellow
try {
    $adminer = Invoke-WebRequest -Uri "http://localhost:9090" -UseBasicParsing -ErrorAction Stop
    Write-Host "✓ Adminer: Available at http://localhost:9090" -ForegroundColor Green
} catch {
    Write-Host "✗ Adminer not responding" -ForegroundColor Yellow
}

# Summary
Write-Host "`n════════════════════════════════════════════════════" -ForegroundColor Gray
Write-Host "✓ Health Check Complete" -ForegroundColor Green
Write-Host "`n📌 Quick Access:" -ForegroundColor Cyan
Write-Host "  API:      http://localhost:8080/api" -ForegroundColor Green
Write-Host "  Health:   http://localhost:8080/actuator/health" -ForegroundColor Green
Write-Host "  Swagger:  http://localhost:8080/swagger-ui.html" -ForegroundColor Green
Write-Host "  MailHog:  http://localhost:8025" -ForegroundColor Green
Write-Host "  Adminer:  http://localhost:9090" -ForegroundColor Green
Write-Host ""
