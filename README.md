# PowerShell Weather Function App

A PowerShell Azure Function App that provides weather data by calling the OpenWeatherMap API. This function can be run locally or deployed to Azure.

## Features

- **HTTP Trigger**: Accepts GET and POST requests
- **Weather Data**: Retrieves current weather information for any city
- **Error Handling**: Comprehensive error handling and logging
- **JSON Response**: Returns structured JSON data
- **Local Development**: Can be run locally using Azure Functions Core Tools
- **Cross-Platform**: Works on macOS, Windows, and Linux
- **Easy Setup**: Includes startup scripts for quick deployment

## Prerequisites

- PowerShell 7.4 or later
- Azure Functions Core Tools v4
- .NET Core SDK 6.0 or later
- OpenWeatherMap API key (free at [openweathermap.org](https://openweathermap.org/api))

## Quick Start (Cross-Platform)

### Option 1: Use the Startup Scripts (Recommended)

**For macOS/Linux:**
```bash
git clone https://github.com/stormihein/powershell-weather-function.git
cd powershell-weather-function
chmod +x start-function.sh
./start-function.sh
```

**For Windows:**
```powershell
git clone https://github.com/stormihein/powershell-weather-function.git
cd powershell-weather-function
.\start-function.ps1
```

The startup scripts will check for prerequisites and guide you through installation if needed.

### Option 2: Manual Installation

#### 1. Install PowerShell

**macOS:**
```bash
# Using Homebrew
brew install --cask powershell

# Or download from Microsoft
# https://github.com/PowerShell/PowerShell/releases
```

**Windows:**
```powershell
# Using winget
winget install Microsoft.PowerShell

# Or download from Microsoft
# https://github.com/PowerShell/PowerShell/releases
```

#### 2. Install .NET Core SDK

**macOS:**
```bash
# Using Homebrew
brew install --cask dotnet

# Or download from Microsoft
# https://dotnet.microsoft.com/download
```

**Windows:**
```powershell
# Using winget
winget install Microsoft.DotNet.SDK.6

# Or download from Microsoft
# https://dotnet.microsoft.com/download
```

#### 3. Install Azure Functions Core Tools
```bash
# Using npm (works on both macOS and Windows)
npm install -g azure-functions-core-tools@4 --unsafe-perm true
```

### 3. Get OpenWeatherMap API Key
1. Visit [OpenWeatherMap](https://openweathermap.org/api)
2. Sign up for a free account
3. Generate an API key
4. Update `local.settings.json` with your API key

## Configuration

### API Key Setup (Optional)
The function works with or without an API key thanks to built-in fallback mechanisms:

**Option 1: With OpenWeatherMap API Key (Recommended)**
Create a `local.settings.json` file with your API key:
```json
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "powershell",
    "FUNCTIONS_WORKER_RUNTIME_VERSION": "7.4",
    "AzureWebJobsStorage": "",
    "OPENWEATHER_API_KEY": "your_actual_api_key_here"
  }
}
```

**Option 2: Without API Key (Works Out of the Box)**
If you don't have an API key, the function will automatically use the free `wttr.in` API. No configuration needed!

## Running Locally

### Quick Start with Scripts (Recommended)

**macOS/Linux:**
```bash
./start-function.sh
```

**Windows:**
```powershell
.\start-function.ps1
```

### Manual Start
```bash
# Navigate to the project directory
cd powershell-weather-function

# Set up .NET path (if needed)
export PATH="$HOME/.dotnet:$PATH"  # macOS/Linux
# or
$env:PATH = "$env:USERPROFILE\.dotnet;$env:PATH"  # Windows

# Start the function app
func start --port 7075
```

The function will be available at:
- `http://localhost:7075/api/GetWeatherData`

### Testing the Function

#### Using curl
```bash
# Get weather for London
curl "http://localhost:7075/api/GetWeatherData?city=London"

# Get weather for New York
curl "http://localhost:7075/api/GetWeatherData?city=New%20York"

# Get weather for Tokyo
curl "http://localhost:7075/api/GetWeatherData?city=Tokyo"
```

#### Using PowerShell
```powershell
# Get weather for London
Invoke-RestMethod -Uri "http://localhost:7075/api/GetWeatherData?city=London" -Method Get

# Get weather for New York
Invoke-RestMethod -Uri "http://localhost:7075/api/GetWeatherData?city=New%20York" -Method Get
```

#### Using the Test Script
```powershell
# Run the included test script
.\test-function.ps1

# Or test specific cities
.\test-function.ps1 -City "Miami" -BaseUrl "http://localhost:7075"
```

#### Using a web browser
Navigate to: `http://localhost:7075/api/GetWeatherData?city=London`

## API Usage

### Request Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `city` | string | No | City name (defaults to "London") |

### Response Format

```json
{
  "Success": true,
  "Message": "Weather data retrieved successfully",
  "Data": {
    "City": "London",
    "Country": "GB",
    "Temperature": 15.2,
    "FeelsLike": 14.8,
    "Humidity": 78,
    "Pressure": 1013,
    "Description": "overcast clouds",
    "WindSpeed": 3.6,
    "WindDirection": 230,
    "Visibility": 10000,
    "Cloudiness": 90,
    "Timestamp": "2024-01-15 14:30:25"
  },
  "RequestedCity": "London"
}
```

### Error Response

```json
{
  "Success": false,
  "Message": "Failed to retrieve weather data",
  "Error": "Error message details",
  "RequestedCity": "InvalidCity"
}
```

## Code Documentation

### Function Structure

The main function (`GetWeatherData/run.ps1`) consists of:

1. **Parameter Binding**: Receives HTTP request data
2. **Weather Data Function**: `Get-WeatherData` function that:
   - Constructs the OpenWeatherMap API URL
   - Makes the HTTP request using `Invoke-RestMethod`
   - Extracts and formats weather data
   - Handles API errors
3. **Main Logic**: 
   - Extracts city parameter from query string or request body
   - Gets API key from environment variables
   - Calls the weather data function
   - Formats and returns JSON response
4. **Error Handling**: Comprehensive try-catch blocks with proper error responses

### Key Components

- **HTTP Trigger**: Configured in `function.json` to accept GET/POST requests
- **Anonymous Access**: Set to allow easy testing without authentication
- **Environment Variables**: API key stored securely in `local.settings.json`
- **JSON Serialization**: Uses PowerShell's `ConvertTo-Json` for response formatting

## Deployment to Azure

### Prerequisites
- Azure CLI installed
- Azure subscription
- Function App created in Azure

### Deploy
```bash
# Login to Azure
az login

# Deploy the function app
func azure functionapp publish <your-function-app-name>
```

## Troubleshooting

### Common Issues

1. **PowerShell not found**: Ensure PowerShell 7.4+ is installed and in PATH
2. **API key errors**: Verify your OpenWeatherMap API key is correct
3. **City not found**: Ensure city names are spelled correctly and exist
4. **Network issues**: Check internet connectivity and firewall settings

### Logs
Function execution logs are displayed in the terminal when running `func start`. Check these logs for detailed error information.

## License

This project is open source and available under the MIT License.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## Support

For issues and questions:
- Check the troubleshooting section
- Review Azure Functions documentation
- Check OpenWeatherMap API documentation
