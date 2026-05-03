$uri = 'http://localhost:8080/api/violations'

# Wait for server to be available
$up = $false
for ($i = 0; $i -lt 20; $i++) {
    try {
        Invoke-RestMethod -Uri $uri -Method Get -ErrorAction Stop | Out-Null
        $up = $true
        break
    } catch {
        Start-Sleep -Seconds 1
    }
}

if (-not $up) {
    Write-Output 'SERVER_NOT_UP'
    exit 1
}

$body = @{ title = 'Test Violation'; description = 'Created by smoke test'; status = 'OPEN'; severity = 'HIGH'; createdBy = 'smoke' }

$post = Invoke-RestMethod -Uri $uri -Method Post -Body ($body | ConvertTo-Json -Depth 5) -ContentType 'application/json'
Write-Output 'POST_OK'
$post | ConvertTo-Json -Depth 5

$list = Invoke-RestMethod -Uri $uri -Method Get
Write-Output 'LIST_OK'
$list | ConvertTo-Json -Depth 5

$id = $post.id
$get = Invoke-RestMethod -Uri ($uri + '/' + $id) -Method Get
Write-Output 'GET_OK'
$get | ConvertTo-Json -Depth 5

$search = Invoke-RestMethod -Uri ($uri + '/search?keyword=Test') -Method Get
Write-Output 'SEARCH_OK'
$search | ConvertTo-Json -Depth 5
