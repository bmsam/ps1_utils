<#
Script Name: get_weather.ps1
Description: This very simple script pulls current weather conditions from your personal weather station and displays in a formatted manner.
Author: Brian Samson
License: This script has no specified license type, and anyone can use it without restriction.

Usage:
1. Replace the placeholder values with your PWS ID and optional API key.
2. Run the script to fetch and display current weather observations.

Copyright (c) 2024 Brian Samson
#>

# Define compass directions
$compassDirections = @("N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW")

function Convert-WindDirToCompassDir ($windDir) {
    $index = [int](($windDir / 22.5) % 16)
    return $compassDirections[$index]
}

# Replace with your PWS ID
$pwsId = "location_id"

# API key (optional, but recommended for rate limiting)
$apiKey = "wunderground.com_api_key"

# Base URL for PWS data
$baseUrl = "https://api.weather.com/v2/pws/observations/current?stationId=$pwsId&format=json&units=e"

if ($apiKey) {
    $baseUrl += "&apiKey=$apiKey"
}

$response = Invoke-RestMethod -Uri $baseUrl

Clear-Host

# Display the weather information
Write-Host "Current Weather Observation:" -ForegroundColor Cyan
Write-Host "--------------------------" -ForegroundColor DarkGray

foreach ($observation in $response.observations) {
    $windir = Convert-WindDirToCompassDir $observation.winddir

    Write-Host "Temperature:" -ForegroundColor Yellow
    Write-Host "  - Current: $($observation.imperial.temp)°F" -ForegroundColor White
    Write-Host "  - Dew Point: $($observation.imperial.dewpt)°F" -ForegroundColor White

    if ($observation.imperial.windChill -lt $observation.imperial.temp) {
        Write-Host "  - Wind Chill: $($observation.imperial.windChill)°F" -ForegroundColor White
    }

    if ($observation.imperial.heatIndex -gt $observation.imperial.temp) {
        Write-Host "  - Heat Index: $($observation.imperial.heatIndex)°F" -ForegroundColor White
    }

    Write-Host "`nWind:" -ForegroundColor Yellow
    Write-Host "  - Speed: $windir @ $($observation.imperial.windSpeed) mph" -ForegroundColor White

    if ($observation.imperial.windGust -gt 0) {
        Write-Host "  - Gust: $($observation.imperial.windGust) mph`n" -ForegroundColor White
    } else {
        Write-Host "`n"  # Add a newline for visual clarity if gust is 0
    }

}
