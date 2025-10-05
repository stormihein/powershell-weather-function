# PowerShell Weather Function Startup Script
# This script will start the Azure Functions app with all necessary setup

Write-Host "Starting PowerShell Weather Function App..." -ForegroundColor Green
Write-Host "==============================================" -ForegroundColor Green

# Kill any existing function processes
Write-Host "Stopping any existing function processes..." -ForegroundColor Yellow
Get-Process -Name "func" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Navigate to the function directory
Write-Host "Navigating to function directory..." -ForegroundColor Cyan
Set-Location $PSScriptRoot

# Set up .NET path
Write-Host "Setting up .NET environment..." -ForegroundColor Cyan
if ($IsWindows -or $env:OS -eq "Windows_NT") {
    $env:PATH = "$env:USERPROFILE\.dotnet;$env:PATH"
} else {
    $env:PATH = "$env:HOME/.dotnet:$env:PATH"
}

# Check if .NET is available
if (-not (Get-Command dotnet -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: .NET not found in PATH. Please ensure .NET Core SDK is installed." -ForegroundColor Red
    Write-Host "   You can install it from: https://dotnet.microsoft.com/download" -ForegroundColor Red
    exit 1
}

# Check if Azure Functions Core Tools is available
if (-not (Get-Command func -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Azure Functions Core Tools not found. Please install it:" -ForegroundColor Red
    Write-Host "   npm install -g azure-functions-core-tools@4 --unsafe-perm true" -ForegroundColor Red
    exit 1
}

# Check if PowerShell is available
if (-not (Get-Command pwsh -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: PowerShell not found. Please install PowerShell Core:" -ForegroundColor Red
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        Write-Host "   winget install Microsoft.PowerShell" -ForegroundColor Red
    } else {
        Write-Host "   brew install --cask powershell" -ForegroundColor Red
    }
    exit 1
}

# Start the function app
Write-Host "Starting weather function on port 7075..." -ForegroundColor Green
Write-Host "Function will be available at: http://localhost:7075/api/GetWeatherData" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop the function" -ForegroundColor Yellow
Write-Host ""

func start --port 7075
