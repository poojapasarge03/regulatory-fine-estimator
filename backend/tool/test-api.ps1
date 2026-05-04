# Day 6 API Testing Script

$baseUrl = "http://localhost:8080/api"
$headers = @{ "Content-Type" = "application/json" }

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Day 6 API Testing" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test 1: GET all violations (should be empty or have some data)
Write-Host "`n[Test 1] GET /violations (list all)" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/violations" -Method Get -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: POST - Create a new violation
Write-Host "`n[Test 2] POST /violations (create new)" -ForegroundColor Yellow
$createPayload = @{
    title = "Test Violation"
    description = "Testing Day 6 features"
    status = "OPEN"
    severity = "HIGH"
    createdBy = "admin"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/violations" -Method Post -Headers $headers -Body $createPayload -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

# Test 3: GET with pagination
Write-Host "`n[Test 3] GET /violations?page=0&size=5 (with pagination)" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/violations?page=0&size=5" -Method Get -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: GET by Status
Write-Host "`n[Test 4] GET /violations/status/OPEN (filter by status)" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/violations/status/OPEN" -Method Get -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 5: Search by keyword
Write-Host "`n[Test 5] GET /violations/search?keyword=Test (search)" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/violations/search?keyword=Test" -Method Get -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 6: GET by ID (assuming ID 1 exists)
Write-Host "`n[Test 6] GET /violations/1 (get by ID)" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/violations/1" -Method Get -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

# Test 7: PUT - Update a violation
Write-Host "`n[Test 7] PUT /violations/1 (update)" -ForegroundColor Yellow
$updatePayload = @{
    title = "Updated Violation"
    description = "Updated description"
    status = "CLOSED"
    severity = "MEDIUM"
    createdBy = "admin"
} | ConvertTo-Json

try {
    $response = Invoke-WebRequest -Uri "$baseUrl/violations/1" -Method Put -Headers $headers -Body $updatePayload -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

# Test 8: DELETE
Write-Host "`n[Test 8] DELETE /violations/1 (delete)" -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "$baseUrl/violations/1" -Method Delete -UseBasicParsing
    Write-Host "Status: $($response.StatusCode)" -ForegroundColor Green
    Write-Host "Response: $($response.Content)" -ForegroundColor White
} catch {
    Write-Host "Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Status Code: $($_.Exception.Response.StatusCode)" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "Testing Complete" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
