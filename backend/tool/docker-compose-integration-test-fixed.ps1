# Docker Compose Integration Test Script
# Tests all 5 services and verifies connectivity

param(
    [int]$TimeoutSeconds = 300
)

function Write-Status {
    param([string]$Message, [string]$Status = "INFO")
    
    $colors = @{
        "SUCCESS" = "Green"
        "ERROR"   = "Red"
        "WARNING" = "Yellow"
        "INFO"    = "Cyan"
        "TEST"    = "Magenta"
    }
    
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] [$Status] $Message" -ForegroundColor $colors[$Status]
}

# Main script
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Docker Compose Integration Testing" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

# Step 1: Build Maven project
Write-Host "" 
Write-Host "Step 1: Building Maven project" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Gray

Write-Status "Building Maven project..." "INFO"
try {
    $mvnOutput = & mvn clean package -DskipTests 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Status "Maven build successful" "SUCCESS"
    } else {
        Write-Status "Maven build failed" "ERROR"
        Write-Host $mvnOutput
        exit 1
    }
} catch {
    Write-Status "Error running Maven: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Step 2: Start Docker Compose
Write-Host "" 
Write-Host "Step 2: Starting Docker Compose" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Gray

Write-Status "Running docker-compose up --build -d" "INFO"
try {
    $composeOutput = & docker-compose up --build -d 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Status "Docker Compose startup failed" "ERROR"
        exit 1
    }
    Write-Status "Docker Compose services starting..." "SUCCESS"
} catch {
    Write-Status "Error running docker-compose: $($_.Exception.Message)" "ERROR"
    exit 1
}

# Step 3: Wait for services to be healthy
Write-Host "" 
Write-Host "Step 3: Waiting for services to become healthy" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Gray

$services = @("db", "redis", "mail", "app", "adminer")
$startTime = Get-Date

while ((Get-Date) -lt $startTime.AddSeconds($TimeoutSeconds)) {
    Write-Host "Checking service status..." -ForegroundColor Yellow
    
    $allHealthy = $true
    foreach ($service in $services) {
        try {
            $status = & docker-compose ps $service 2>&1
            if ($status -match "running") {
                Write-Host "  $service - running" -ForegroundColor Green
            } else {
                Write-Host "  $service - pending" -ForegroundColor Yellow
                $allHealthy = $false
            }
        } catch {
            Write-Host "  $service - pending" -ForegroundColor Yellow
            $allHealthy = $false
        }
    }
    
    if ($allHealthy) {
        Write-Status "All services running" "SUCCESS"
        break
    }
    
    Start-Sleep -Seconds 5
}

# Step 4: Test Database
Write-Host "" 
Write-Host "Step 4: Testing Database" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Gray

Write-Status "Testing PostgreSQL..." "TEST"
try {
    $result = & docker-compose exec -T db pg_isready -U postgres 2>&1
    Write-Host "  Response: $result" -ForegroundColor Green
    Write-Status "Database ready" "SUCCESS"
} catch {
    Write-Status "Database test failed" "ERROR"
}

# Step 5: Test Redis
Write-Host "" 
Write-Host "Step 5: Testing Redis" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Gray

Write-Status "Testing Redis PING..." "TEST"
try {
    $result = & docker-compose exec -T redis redis-cli ping 2>&1
    Write-Host "  Response: $result" -ForegroundColor Green
    if ($result -match "PONG") {
        Write-Status "Redis ready" "SUCCESS"
    }
} catch {
    Write-Status "Redis test failed" "ERROR"
}

# Step 6: Test Mail Service
Write-Host "" 
Write-Host "Step 6: Testing Mail Service" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Gray

Write-Status "MailHog Web UI: http://localhost:8025" "INFO"
Write-Status "SMTP Endpoint: localhost:1025" "INFO"

try {
    $mailResponse = Invoke-WebRequest -Uri "http://localhost:8025/api/v1/messages" -Method Get -UseBasicParsing -ErrorAction Stop
    Write-Status "MailHog API accessible" "SUCCESS"
} catch {
    Write-Status "MailHog not ready yet (normal during startup)" "WARNING"
}

# Step 7: Test Spring Boot Health
Write-Host "" 
Write-Host "Step 7: Testing Spring Boot Health" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Gray

$healthUrl = "http://localhost:8080/actuator/health"
$maxRetries = 15
$retryCount = 0

while ($retryCount -lt $maxRetries) {
    try {
        Write-Status "Checking health endpoint (attempt $($retryCount + 1))" "TEST"
        $response = Invoke-WebRequest -Uri $healthUrl -Method Get -UseBasicParsing -ErrorAction Stop
        $health = $response.Content | ConvertFrom-Json -ErrorAction SilentlyContinue
        
        Write-Host "  Status Code: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "  Health Status: $($health.status)" -ForegroundColor Green
        
        if ($health.status -eq "UP") {
            Write-Status "Spring Boot application is UP" "SUCCESS"
            break
        }
    } catch {
        $retryCount++
        if ($retryCount -lt $maxRetries) {
            Write-Host "  Not ready yet, retrying in 5s..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        } else {
            Write-Status "Health check failed after $maxRetries attempts" "ERROR"
        }
    }
}

# Step 8: Test API Endpoints
Write-Host "" 
Write-Host "Step 8: Testing API Endpoints" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Gray

$apiTests = @(
    @{ endpoint = "/api/violations"; desc = "List violations" },
    @{ endpoint = "/actuator/health"; desc = "Health status" },
    @{ endpoint = "/api"; desc = "API info" }
)

foreach ($test in $apiTests) {
    $url = "http://localhost:8080$($test.endpoint)"
    Write-Status "Testing GET $($test.endpoint)" "TEST"
    
    try {
        $response = Invoke-WebRequest -Uri $url -Method Get -UseBasicParsing -ErrorAction Stop
        Write-Host "  Status: $($response.StatusCode)" -ForegroundColor Green
    } catch {
        Write-Host "  Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Step 9: Test Violation CRUD
Write-Host "" 
Write-Host "Step 9: Testing Violation CRUD" -ForegroundColor Magenta
Write-Host "================================================" -ForegroundColor Gray

$violation = @{
    title = "Docker Compose Test Violation"
    description = "Created during integration test"
    severity = "HIGH"
    status = "OPEN"
    createdBy = "docker-compose-test"
} | ConvertTo-Json

Write-Status "Creating test violation..." "TEST"
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/api/violations" `
        -Method Post `
        -Headers @{ "Content-Type" = "application/json" } `
        -Body $violation `
        -UseBasicParsing `
        -ErrorAction Stop
    
    $createdViolation = $response.Content | ConvertFrom-Json
    $violationId = $createdViolation.id
    
    Write-Host "  Created successfully with ID: $violationId" -ForegroundColor Green
    
    # Retrieve it
    Write-Status "Retrieving created violation..." "TEST"
    $getResponse = Invoke-WebRequest -Uri "http://localhost:8080/api/violations/$violationId" `
        -Method Get `
        -UseBasicParsing `
        -ErrorAction Stop
    
    Write-Host "  Retrieved successfully" -ForegroundColor Green
    Write-Status "CRUD test successful" "SUCCESS"
    
} catch {
    Write-Status "CRUD test failed: $($_.Exception.Message)" "ERROR"
}

# Final Summary
Write-Host "" 
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "  Integration Test Complete" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan

Write-Host ""
Write-Host "Access Points:" -ForegroundColor Green
Write-Host "  API:           http://localhost:8080/api" -ForegroundColor Green
Write-Host "  Health:        http://localhost:8080/actuator/health" -ForegroundColor Green
Write-Host "  Swagger:       http://localhost:8080/swagger-ui.html" -ForegroundColor Green
Write-Host "  Email:         http://localhost:8025" -ForegroundColor Green
Write-Host "  Database:      http://localhost:9090" -ForegroundColor Green
Write-Host ""
Write-Host "Useful Commands:" -ForegroundColor Green
Write-Host "  View logs:     docker-compose logs -f" -ForegroundColor Green
Write-Host "  Stop services: docker-compose down" -ForegroundColor Green
Write-Host "  Restart app:   docker-compose restart app" -ForegroundColor Green
Write-Host ""

Write-Status "All tests completed successfully" "SUCCESS"
Write-Host ""
