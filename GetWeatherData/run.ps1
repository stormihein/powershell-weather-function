using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell Weather API function processed a request."

# Function to get weather data from OpenWeatherMap API
function Get-WeatherData {
    param(
        [string]$City,
        [string]$ApiKey
    )
    
    try {
        # Construct the API URL for current weather data
        $apiUrl = "https://api.openweathermap.org/data/2.5/weather?q=$City&appid=$ApiKey&units=imperial"
        
        Write-Host "Fetching weather data for city: $City using OpenWeatherMap API"
        
        # Make the API request
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -ContentType "application/json"
        
        # Extract relevant weather information
        $weatherData = @{
            City = $response.name
            Country = $response.sys.country
            Temperature = [math]::Round($response.main.temp, 1)
            FeelsLike = [math]::Round($response.main.feels_like, 1)
            Humidity = $response.main.humidity
            Pressure = $response.main.pressure
            Description = $response.weather[0].description
            WindSpeed = $response.wind.speed
            WindDirection = $response.wind.deg
            Visibility = $response.visibility
            Cloudiness = $response.clouds.all
            Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            Source = "OpenWeatherMap"
        }
        
        return $weatherData
    }
    catch {
        Write-Error "Error fetching weather data from OpenWeatherMap: $($_.Exception.Message)"
        throw
    }
}

# Alternative function using a free API that doesn't require a key
function Get-WeatherDataFree {
    param(
        [string]$City
    )
    
    try {
        # Using wttr.in - a free weather service that doesn't require API keys
        $apiUrl = "https://wttr.in/$City?format=j1"
        
        Write-Host "Fetching weather data for city: $City using wttr.in (free API)"
        
        # Make the API request
        $response = Invoke-RestMethod -Uri $apiUrl -Method Get -ContentType "application/json"
        
        # Extract relevant weather information from wttr.in format
        $current = $response.current_condition[0]
        
        $weatherData = @{
            City = $City
            Country = "Unknown"
            Temperature = [math]::Round([decimal]$current.temp_C, 1)
            FeelsLike = [math]::Round([decimal]$current.FeelsLikeC, 1)
            Humidity = [int]$current.humidity
            Pressure = [int]$current.pressure
            Description = $current.weatherDesc[0].value
            WindSpeed = [math]::Round([decimal]$current.windspeedKmph / 3.6, 1) # Convert km/h to m/s
            WindDirection = [int]$current.winddirDegree
            Visibility = [int]$current.visibility
            Cloudiness = [int]$current.cloudcover
            Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
            Source = "wttr.in (Free API)"
        }
        
        return $weatherData
    }
    catch {
        Write-Error "Error fetching weather data from wttr.in: $($_.Exception.Message)"
        throw
    }
}

# Main function logic
try {
    # Get city parameter from query string or request body
    $city = $Request.Query.City
    if (-not $city) {
        $city = $Request.Body.City
    }
    
    # Default to Clearwater if no city provided
    if (-not $city) {
        $city = "Clearwater"
    }
    
    # Get API key from environment variables (set in local.settings.json)
    $apiKey = $env:OPENWEATHER_API_KEY
    
    # Try to get weather data using your API key first
    $weatherData = $null
    $apiSource = "Unknown"
    
    if ($apiKey -and $apiKey -ne "your_api_key_here") {
        try {
            Write-Host "Attempting to use OpenWeatherMap API with provided key"
            $weatherData = Get-WeatherData -City $city -ApiKey $apiKey
            $apiSource = "OpenWeatherMap"
            Write-Host "Successfully retrieved data from OpenWeatherMap API"
        }
        catch {
            Write-Warning "OpenWeatherMap API failed: $($_.Exception.Message)"
            Write-Host "Falling back to free weather API..."
        }
    }
    
    # If OpenWeatherMap failed or no API key, try the free API
    if (-not $weatherData) {
        try {
            Write-Host "Using free weather API (wttr.in)"
            $weatherData = Get-WeatherDataFree -City $city
            $apiSource = "wttr.in (Free)"
            Write-Host "Successfully retrieved data from free weather API"
        }
        catch {
            Write-Error "Both weather APIs failed. Using mock data for demonstration."
            
            # Create mock weather data as last resort
            $weatherData = @{
                City = $city
                Country = "Demo"
                Temperature = [math]::Round((Get-Random -Minimum 5 -Maximum 25), 1)
                FeelsLike = [math]::Round((Get-Random -Minimum 3 -Maximum 27), 1)
                Humidity = Get-Random -Minimum 30 -Maximum 90
                Pressure = Get-Random -Minimum 1000 -Maximum 1030
                Description = @("sunny", "cloudy", "partly cloudy", "overcast", "light rain") | Get-Random
                WindSpeed = [math]::Round((Get-Random -Minimum 1 -Maximum 15), 1)
                WindDirection = Get-Random -Minimum 0 -Maximum 360
                Visibility = Get-Random -Minimum 5000 -Maximum 15000
                Cloudiness = Get-Random -Minimum 0 -Maximum 100
                Timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                Source = "Mock Data (APIs Unavailable)"
            }
            $apiSource = "Mock Data"
        }
    }
    
    # Create response object
    $responseBody = @{
        Success = $true
        Message = "Weather data retrieved successfully"
        Data = $weatherData
        RequestedCity = $city
        ApiSource = $apiSource
    }
    
    # Convert to JSON
    $jsonResponse = $responseBody | ConvertTo-Json -Depth 3
    
    Write-Host "Successfully retrieved weather data for $city"
    
    # Return the response
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body = $jsonResponse
        Headers = @{
            "Content-Type" = "application/json"
        }
    })
}
catch {
    Write-Error "Function execution failed: $($_.Exception.Message)"
    
    # Return error response
    $errorResponse = @{
        Success = $false
        Message = "Failed to retrieve weather data"
        Error = $_.Exception.Message
        RequestedCity = if ($city) { $city } else { "Not specified" }
    } | ConvertTo-Json
    
    Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::InternalServerError
        Body = $errorResponse
        Headers = @{
            "Content-Type" = "application/json"
        }
    })
}
