# Test script for the PowerShell Weather Function
# This script helps test the function locally

param(
    [string]$BaseUrl = "http://localhost:7071",
    [string]$City = "London"
)

Write-Host "Testing PowerShell Weather Function" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green

# Test 1: Basic functionality
Write-Host "`nTest 1: Basic weather request for $City" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/GetWeatherData?city=$City" -Method Get
    Write-Host "✓ Success!" -ForegroundColor Green
    Write-Host "City: $($response.Data.City)"
    Write-Host "Temperature: $($response.Data.Temperature)°C"
    Write-Host "Description: $($response.Data.Description)"
    Write-Host "Humidity: $($response.Data.Humidity)%"
}
catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 2: Different city
Write-Host "`nTest 2: Weather request for New York" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/GetWeatherData?city=New%20York" -Method Get
    Write-Host "✓ Success!" -ForegroundColor Green
    Write-Host "City: $($response.Data.City)"
    Write-Host "Temperature: $($response.Data.Temperature)°C"
    Write-Host "Description: $($response.Data.Description)"
}
catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 3: Default city (no parameter)
Write-Host "`nTest 3: Default city request (no parameter)" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/GetWeatherData" -Method Get
    Write-Host "✓ Success!" -ForegroundColor Green
    Write-Host "City: $($response.Data.City)"
    Write-Host "Temperature: $($response.Data.Temperature)°C"
    Write-Host "Description: $($response.Data.Description)"
}
catch {
    Write-Host "✗ Failed: $($_.Exception.Message)" -ForegroundColor Red
}

# Test 4: Invalid city
Write-Host "`nTest 4: Invalid city request" -ForegroundColor Yellow
try {
    $response = Invoke-RestMethod -Uri "$BaseUrl/api/GetWeatherData?city=InvalidCityName123" -Method Get
    if ($response.Success -eq $false) {
        Write-Host "✓ Error handling works correctly" -ForegroundColor Green
        Write-Host "Error: $($response.Message)"
    } else {
        Write-Host "✗ Expected error but got success" -ForegroundColor Red
    }
}
catch {
    Write-Host "✓ Error handling works correctly" -ForegroundColor Green
    Write-Host "Exception: $($_.Exception.Message)"
}

Write-Host "`nTesting completed!" -ForegroundColor Green
Write-Host "Make sure the function app is running with: func start" -ForegroundColor Cyan
