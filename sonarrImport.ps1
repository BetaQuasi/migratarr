# sonarrImport.ps1

# Import the module
Import-Module "$PSScriptRoot\SonarrRadarrImportExport.psm1"

# Function to import data to Sonarr
function Import-Sonarr {
    $config = Get-Config

    if (-not $config.ContainsKey('destinationSonarrInstance') -or -not $config.ContainsKey('destinationSonarrApiKey')) {
        Write-LogMessage "Destination Sonarr instance details are not configured. Please configure your Sonarr instance first." "ERROR"
        return
    }

    $destinationSonarrInstance = $config.destinationSonarrInstance
    $destinationSonarrApiKey = $config.destinationSonarrApiKey | ConvertTo-SecureString

    $confirmInstance = Read-Host "You specified your destination Sonarr instance as $destinationSonarrInstance - is this correct? (y/n)"
    if ($confirmInstance -ne 'y') {
        Write-LogMessage "Sonarr instance confirmation failed." "WARN"
        Write-Host "Please configure your Sonarr instance again."
        return
    }

    $plainTextApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($destinationSonarrApiKey))
    $confirmApiKey = Read-Host "You specified your Sonarr API key as $plainTextApiKey - is this correct? (y/n)"
    if ($confirmApiKey -ne 'y') {
        Write-LogMessage "Sonarr API key confirmation failed." "WARN"
        Write-Host "Please configure your Sonarr instance again."
        return
    }

    # Check if series.json exists
    if (-not (Test-Path "series.json")) {
        Write-LogMessage "series.json file not found. Please ensure the file exists in the current directory." "ERROR"
        return
    }

    # Read the series.json file
    $seriesData = Get-Content -Path "series.json" -Raw | ConvertFrom-Json

    # Import data to Sonarr
    $url = "$destinationSonarrInstance/api/v3/series?apikey=$plainTextApiKey"
    Write-LogMessage "Importing data to Sonarr API..." "INFO"
    try {
        foreach ($series in $seriesData) {
            $response = Invoke-RestMethod -Uri $url -Method Post -Body ($series | ConvertTo-Json -Depth 10) -ContentType "application/json"
            Write-LogMessage "Imported series: $($series.title)" "INFO"
        }
        Write-LogMessage "Import completed successfully." "INFO"
    } catch {
        Write-LogMessage "Error importing data to Sonarr API: $_" "ERROR"
    }
}

# Call the import function
Import-Sonarr