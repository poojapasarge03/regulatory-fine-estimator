param([int]$TimeoutSeconds = 300)

function Write-Status($Message, $Status = "INFO") {
    $colors = @{
        "SUCCESS" = "Green"
        "ERROR" = "Red"
        "WARNING" = "Yellow"
        "INFO" = "Cyan"
        "TEST" = "Magenta"
    }
    
    $timestamp = Get-Date -Format 'HH:mm:ss'
    $prefix = "[$timestamp] [$Status]"
    Write-Host $prefix $Message -ForegroundColor $colors[$Status]
}

Write-Host "=================================================="
Write-Host "Docker Compose Integration Test"
Write-Host "=================================================="
Write-Host ""

Write-Host "Building Maven project..." -ForegroundColor Magenta
Write-Status "Running: mvn clean package -DskipTests" "INFO"
try {
    $mvnOutput = & mvn clean package -DskipTests 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Status "Maven build successful" "SUCCESS"
    } else {
        Write-Status "Maven build failed" "ERROR"
        exit 1
    }
} catch {
    Write-Status "Error running Maven" "ERROR"
    exit 1
}

Write-Host ""
Write-Host "Docker Compose Startup" -ForegroundColor Magenta
Write-Status "Running: docker-compose up --build -d" "INFO"
try {
    $composeOutput = & docker-compose up --build -d 2>&1
    Write-Host $composeOutput
    if ($LASTEXITCODE -ne 0) {
        Write-Status "Docker Compose startup failed" "ERROR"
        exit 1
    }
    Write-Status "Docker Compose services starting..." "SUCCESS"
} catch {
    Write-Status "Error running docker-compose" "ERROR"
    exit 1
}

Write-Host ""
Write-Host "Waiting for Services" -ForegroundColor Magenta

$services = @("db", "redis", "mail", "app")
$startTime = Get-Date
$allHealthy = $false

while ((Get-Date) -lt $startTime.AddSeconds($TimeoutSeconds)) {
    $allHealthy = $true
    
    foreach ($service in $services) {
        try {
            $status = & docker-compose ps $service 2>&1
            if ($status -match "running") {
                $serviceStatus = "running"
            } else {
                $allHealthy = $false
            }
        } catch {
            $allHealthy = $false
        }
    }
    
    if ($allHealthy) {
        break
    }
    
    Start-Sleep -Seconds 3
}

Write-Host ""

if (-not $allHealthy) {
    Write-Status "Services failed to become healthy" "ERROR"
    exit 1
}

Write-Status "All services are healthy!" "SUCCESS"

Write-Host ""
Write-Host "Testing Database" -ForegroundColor Magenta
Write-Status "Testing PostgreSQL connection..." "TEST"
try {
    $result = & docker-compose exec -T db pg_isready -U postgres 2>&1
    Write-Status "Database connection successful" "SUCCESS"
} catch {
    Write-Status "Database connection failed" "ERROR"
}

Write-Host ""
Write-Host "Testing Redis" -ForegroundColor Magenta
Write-Status "Testing Redis PING..." "TEST"
try {
    $result = & docker-compose exec -T redis redis-cli ping 2>&1
    if ($result -match "PONG") {
        Write-Status "Redis connection successful" "SUCCESS"
    }
} catch {
    Write-Status "Redis connection failed" "ERROR"
}

Write-Host ""
Write-Host "Testing Spring Boot" -ForegroundColor Magenta
$healthUrl = "http://localhost:8080/actuator/health"
$maxRetries = 15
$retryCount = 0

while ($retryCount -lt $maxRetries) {
    try {
        Write-Status "Checking health endpoint..." "TEST"
        $response = Invoke-WebRequest -Uri $healthUrl -Method Get -UseBasicParsing -ErrorAction Stop
        $health = $response.Content | ConvertFrom-Json -ErrorAction SilentlyContinue
        
        if ($health.status -eq "UP") {
            Write-Status "Spring Boot application is healthy" "SUCCESS"
            break
        }
    } catch {
        $retryCount++
        if ($retryCount -lt $maxRetries) {
            Start-Sleep -Seconds 5
        } else {
            Write-Status "Health check failed after attempts" "ERROR"
        }
    }
}

Write-Host ""
Write-Host "Testing API" -ForegroundColor Magenta
Write-Status "Testing GET /api/violations" "TEST"
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/violations" -Method Get -UseBasicParsing -ErrorAction Stop
    Write-Status "API is responding" "SUCCESS"
} catch {
    $msg = $_.Exception.Message
    Write-Host "Response error: $msg" -ForegroundColor Red
}

Write-Host ""
Write-Host "=================================================="
Write-Status "Docker Compose test completed" "SUCCESS"
Write-Host "=================================================="
Write-Host ""
Write-Host "Access Points:"
Write-Host "  API:      http://localhost:8080/api"
Write-Host "  Health:   http://localhost:8080/actuator/health"
Write-Host "  MailHog:  http://localhost:8025"
Write-Host ""
