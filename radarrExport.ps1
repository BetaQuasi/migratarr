# radarrExport.ps1

# Import the module
Import-Module "$PSScriptRoot\SonarrRadarrImportExport.psm1"

# Function to export data from Radarr
function Export-Radarr {
    $config = Get-Config

    if (-not $config.ContainsKey('sourceRadarrInstance') -or -not $config.ContainsKey('sourceRadarrApiKey')) {
        Write-LogMessage "Radarr instance details are not configured. Please configure your Radarr instance first." "ERROR"
        return
    }

    $sourceRadarrInstance = $config.sourceRadarrInstance
    $sourceRadarrApiKey = $config.sourceRadarrApiKey | ConvertTo-SecureString

    $confirmInstance = Read-Host "You specified your existing Radarr instance as $sourceRadarrInstance - is this correct? (y/n)"
    if ($confirmInstance -ne 'y') {
        Write-LogMessage "Radarr instance confirmation failed." "WARN"
        Write-Host "Please configure your Radarr instance again."
        return
    }

    $plainTextApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sourceRadarrApiKey))
    $confirmApiKey = Read-Host "You specified your Radarr API key as $plainTextApiKey - is this correct? (y/n)"
    if ($confirmApiKey -ne 'y') {
        Write-LogMessage "Radarr API key confirmation failed." "WARN"
        Write-Host "Please configure your Radarr instance again."
        return
    }

    # Export data from Radarr
    $url = "$sourceRadarrInstance/api/v3/movie?apikey=$plainTextApiKey"
    Write-LogMessage "Fetching data from Radarr API..." "INFO"
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
        if ($response) {
            $exportPath = "movies.json"
            Write-LogMessage "Saving data to $exportPath..." "INFO"
            $response | ConvertTo-Json -Depth 10 | Set-Content -Path $exportPath
            Write-LogMessage "Export completed successfully. Data saved to $exportPath." "INFO"

            $csvOption = Read-Host "Do you want a copy of the export in .csv format? (y/n)"
            if ($csvOption -eq 'y') {
                $csvFilename = Read-Host "Please enter a filename for the .csv (press enter to use movies.csv):"
                if ([string]::IsNullOrEmpty($csvFilename)) {
                    $csvFilename = "movies.csv"
                }

                Write-LogMessage "Converting data to CSV format..." "INFO"
                $filteredResponse = $response | ForEach-Object {
                    $_ | Select-Object -Property * -ExcludeProperty alternateTitles, images, genres, tags
                }
                $filteredResponse | Export-Csv -Path $csvFilename -NoTypeInformation
                Write-LogMessage "CSV export completed successfully. Data saved to $csvFilename." "INFO"
            }
        } else {
            Write-LogMessage "Failed to retrieve data from Radarr." "ERROR"
        }
    } catch {
        Write-LogMessage "Error fetching data from Radarr API: $_" "ERROR"
    }
}

# Call the export function
Export-Radarr