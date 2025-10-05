#!/bin/bash

# PowerShell Weather Function Startup Script
# This script will start the Azure Functions app with all necessary setup

echo "Starting PowerShell Weather Function App..."
echo "=============================================="

# Kill any existing function processes
echo "Stopping any existing function processes..."
pkill -f "func start" 2>/dev/null || true
sleep 2

# Navigate to the function directory
echo "Navigating to function directory..."
cd "$(dirname "$0")"

# Set up .NET path
echo "Setting up .NET environment..."
export PATH="$HOME/.dotnet:$PATH"

# Check if .NET is available
if ! command -v dotnet &> /dev/null; then
    echo "ERROR: .NET not found in PATH. Please ensure .NET Core SDK is installed."
    echo "   You can install it from: https://dotnet.microsoft.com/download"
    exit 1
fi

# Check if Azure Functions Core Tools is available
if ! command -v func &> /dev/null; then
    echo "ERROR: Azure Functions Core Tools not found. Please install it:"
    echo "   npm install -g azure-functions-core-tools@4 --unsafe-perm true"
    exit 1
fi

# Check if PowerShell is available
if ! command -v pwsh &> /dev/null; then
    echo "ERROR: PowerShell not found. Please install PowerShell Core:"
    echo "   brew install --cask powershell"
    exit 1
fi

# Start the function app
echo "Starting weather function on port 7075..."
echo "Function will be available at: http://localhost:7075/api/GetWeatherData"
echo "Press Ctrl+C to stop the function"
echo ""

func start --port 7075