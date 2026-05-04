# Day 6 Comprehensive API Testing Script
# Tests all APIs with JWT authentication

$baseUrl = "http://localhost:8080/api"
$authUrl = "$baseUrl/auth"
$headers = @{ "Content-Type" = "application/json" }

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Day 6 API Testing with JWT Authentication" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Step 1: Login and get JWT token
Write-Host "`n[STEP 1] LOGIN - Get JWT Token" -ForegroundColor Yellow
Write-Host "Attempting login with credentials: admin / admin123" -ForegroundColor White

$loginPayload = @{
    username = "admin"
    password = "admin123"
} | ConvertTo-Json

try {
    $loginResponse = Invoke-WebRequest -Uri "$authUrl/login" -Method Post -Headers $headers -Body $loginPayload -UseBasicParsing
    $token = $loginResponse.Content.Trim('"')
    Write-Host "[SUCCESS] Login Successful!" -ForegroundColor Green
    Write-Host "Token received (first 50 chars): $($token.Substring(0, 50))..." -ForegroundColor Green
} catch {
    Write-Host "[FAILED] Login Failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Add authorization header
$authHeaders = @{
    "Content-Type" = "application/json"
    "Authorization" = "Bearer $token"
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Running Comprehensive Tests" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test 1: GET all violations with pagination
Write-Host "`n[Test 1] GET /violations with pagination" -ForegroundColor Yellow
try {
    $url = "$baseUrl/violations"
    $response = Invoke-WebRequest -Uri $url -Method Get -Headers $authHeaders -UseBasicParsing
    Write-Host "[SUCCESS] Status: $($response.StatusCode)" -ForegroundColor Green
    $content = $response.Content | ConvertFrom-Json
    Write-Host "Response Summary:" -ForegroundColor White
    Write-Host "  Total Elements: $($content.totalElements)" -ForegroundColor White
    Write-Host "  Total Pages: $($content.totalPages)" -ForegroundColor White
    Write-Host "  Current Page Size: $($content.content.Count)" -ForegroundColor White
} catch {
    Write-Host "[FAILED] Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: POST - Create a new violation
Write-Host "`n[Test 2] POST /violations (create new violation)" -ForegroundColor Yellow
$createPayload = @{
    title = "Day 6 Test Violation"
    description = "Testing comprehensive Day 6 features"
    status = "OPEN"
    severity = "HIGH"
    createdBy = "admin"
} | ConvertTo-Json

$violationId = $null
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/violations" -Method Post -Headers $authHeaders -Body $createPayload -UseBasicParsing
    Write-Host "[SUCCESS] Status: $($response.StatusCode)" -ForegroundColor Green
    $createdViolation = $response.Content | ConvertFrom-Json
    $violationId = $createdViolation.id
    Write-Host "[SUCCESS] Violation Created with ID: $violationId" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "[FAILED] Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: GET by ID
if ($violationId) {
    Write-Host "`n[Test 3] GET /violations/$violationId (get by ID)" -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "$baseUrl/violations/$violationId" -Method Get -Headers $authHeaders -UseBasicParsing
        Write-Host "[SUCCESS] Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "Response: $($response.Content)" -ForegroundColor White
    } catch {
        Write-Host "[FAILED] Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 4: GET by Status Filter
Write-Host "`n[Test 4] GET /violations/status/OPEN (filter by status)" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/violations/status/OPEN" -Method Get -Headers $authHeaders -UseBasicParsing
    Write-Host "[SUCCESS] Status: $($response.StatusCode)" -ForegroundColor Green
    $violations = $response.Content | ConvertFrom-Json
    Write-Host "Total records with OPEN status: $($violations.Count)" -ForegroundColor White
} catch {
    Write-Host "[FAILED] Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Search by keyword
Write-Host "`n[Test 5] GET /violations/search with keyword" -ForegroundColor Yellow
try {
    $url = "$baseUrl/violations/search?keyword=Day6"
    $response = Invoke-WebRequest -Uri $url -Method Get -Headers $authHeaders -UseBasicParsing
    Write-Host "[SUCCESS] Status: $($response.StatusCode)" -ForegroundColor Green
    $violations = $response.Content | ConvertFrom-Json
    Write-Host "Records matching search: $($violations.Count)" -ForegroundColor White
} catch {
    Write-Host "[FAILED] Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: PUT - Update a violation
if ($violationId) {
    Write-Host "`n[Test 6] PUT /violations/$violationId (update violation)" -ForegroundColor Yellow
    $updatePayload = @{
        title = "Day 6 Updated Violation"
        description = "Updated via Day 6 testing - status changed"
        status = "IN_PROGRESS"
        severity = "CRITICAL"
        createdBy = "admin"
    } | ConvertTo-Json
    
    try {
        $response = Invoke-WebRequest -Uri "$baseUrl/violations/$violationId" -Method Put -Headers $authHeaders -Body $updatePayload -UseBasicParsing
        Write-Host "[SUCCESS] Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "Updated Response: $($response.Content)" -ForegroundColor White
    } catch {
        Write-Host "[FAILED] Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 7: Verify update was successful
if ($violationId) {
    Write-Host "`n[Test 7] GET /violations/$violationId (verify update)" -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "$baseUrl/violations/$violationId" -Method Get -Headers $authHeaders -UseBasicParsing
        Write-Host "[SUCCESS] Status: $($response.StatusCode)" -ForegroundColor Green
        $updated = $response.Content | ConvertFrom-Json
        Write-Host "Updated Status: $($updated.status)" -ForegroundColor White
        Write-Host "Updated Severity: $($updated.severity)" -ForegroundColor White
    } catch {
        Write-Host "[FAILED] Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 8: Error Handling - Invalid ID
Write-Host "`n[Test 8] Error Handling - GET with non-existent ID" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/violations/99999" -Method Get -Headers $authHeaders -UseBasicParsing
    Write-Host "[FAILED] Should have failed but got: $($response.StatusCode)" -ForegroundColor Red
} catch {
    Write-Host "[SUCCESS] Correctly returned error: $($_.Exception.Response.StatusCode)" -ForegroundColor Green
}

# Test 9: Error Handling - Invalid JSON
Write-Host "`n[Test 9] Error Handling - POST with empty title" -ForegroundColor Yellow
$invalidPayload = @{
    title = ""
    description = "Missing required title"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/violations" -Method Post -Headers $authHeaders -Body $invalidPayload -UseBasicParsing
    Write-Host "[FAILED] Should have failed but got: $($response.StatusCode)" -ForegroundColor Red
} catch {
    Write-Host "[SUCCESS] Correctly returned validation error: $($_.Exception.Response.StatusCode)" -ForegroundColor Green
}

# Test 10: DELETE - Remove violation
if ($violationId) {
    Write-Host "`n[Test 10] DELETE /violations/$violationId (delete violation)" -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "$baseUrl/violations/$violationId" -Method Delete -Headers $authHeaders -UseBasicParsing
        Write-Host "[SUCCESS] Status: $($response.StatusCode)" -ForegroundColor Green
        Write-Host "Violation successfully deleted" -ForegroundColor White
    } catch {
        Write-Host "[FAILED] Error: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Test 11: Verify deletion
if ($violationId) {
    Write-Host "`n[Test 11] GET /violations/$violationId (verify deletion)" -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "$baseUrl/violations/$violationId" -Method Get -Headers $authHeaders -UseBasicParsing
        Write-Host "[FAILED] Should have failed but got: $($response.StatusCode)" -ForegroundColor Red
    } catch {
        Write-Host "[SUCCESS] Correctly returned 404 Not Found" -ForegroundColor Green
        Write-Host "Verification: Record was successfully deleted" -ForegroundColor White
    }
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "API Testing Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "`nTest Summary:" -ForegroundColor Yellow
Write-Host "- Authentication JWT: Working" -ForegroundColor Green
Write-Host "- CRUD Operations: Tested" -ForegroundColor Green
Write-Host "- Filtering and Search: Tested" -ForegroundColor Green
Write-Host "- Error Handling: Tested" -ForegroundColor Green
