# radarrImport.ps1

# Import the module
Import-Module "$PSScriptRoot\SonarrRadarrImportExport.psm1"

# Function to import data to Radarr
function Import-Radarr {
    $config = Get-Config

    if (-not $config.ContainsKey('destinationRadarrInstance') -or -not $config.ContainsKey('destinationRadarrApiKey')) {
        Write-LogMessage "Destination Radarr instance details are not configured. Please configure your Radarr instance first." "ERROR"
        return
    }

    $destinationRadarrInstance = $config.destinationRadarrInstance
    $destinationRadarrApiKey = $config.destinationRadarrApiKey | ConvertTo-SecureString

    $confirmInstance = Read-Host "You specified your destination Radarr instance as $destinationRadarrInstance - is this correct? (y/n)"
    if ($confirmInstance -ne 'y') {
        Write-LogMessage "Radarr instance confirmation failed." "WARN"
        Write-Host "Please configure your Radarr instance again."
        return
    }

    $plainTextApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($destinationRadarrApiKey))
    $confirmApiKey = Read-Host "You specified your Radarr API key as $plainTextApiKey - is this correct? (y/n)"
    if ($confirmApiKey -ne 'y') {
        Write-LogMessage "Radarr API key confirmation failed." "WARN"
        Write-Host "Please configure your Radarr instance again."
        return
    }

    # Check if movies.json exists
    if (-not (Test-Path "movies.json")) {
        Write-LogMessage "movies.json file not found. Please ensure the file exists in the current directory." "ERROR"
        return
    }

    # Read the movies.json file
    $moviesData = Get-Content -Path "movies.json" -Raw | ConvertFrom-Json

    # Import data to Radarr
    $url = "$destinationRadarrInstance/api/v3/movie?excludeLocalCovers=false&apikey=$plainTextApiKey"
    Write-LogMessage "Importing data to Radarr API..." "INFO"
    try {
        foreach ($movie in $moviesData) {
            $response = Invoke-RestMethod -Uri $url -Method Post -Body ($movie | ConvertTo-Json -Depth 10) -ContentType "application/json"
            Write-LogMessage "Imported movie: $($movie.title)" "INFO"
        }
        Write-LogMessage "Import completed successfully." "INFO"
    } catch {
        Write-LogMessage "Error importing data to Radarr API: $_" "ERROR"
    }
}

# Call the import function
Import-Radarr