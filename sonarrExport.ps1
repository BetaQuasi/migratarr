# sonarrExport.ps1

# Import the module
Import-Module "$PSScriptRoot\SonarrRadarrImportExport.psm1"

# Function to export data from Sonarr
function Export-Sonarr {
    Write-LogMessage "Reading configuration..." "INFO"
    $config = Get-Config

    if (-not $config.ContainsKey('sourceSonarrInstance') -or -not $config.ContainsKey('sourceSonarrApiKey')) {
        Write-LogMessage "Source Sonarr instance details are not configured. Please configure them first." "ERROR"
        return
    }

    $sourceSonarrInstance = $config.sourceSonarrInstance
    $sourceSonarrApiKey = $config.sourceSonarrApiKey | ConvertTo-SecureString

    $confirmInstance = Read-Host "You specified your existing Sonarr instance as $sourceSonarrInstance - is this correct? (y/n)"
    if ($confirmInstance -ne 'y') {
        Write-LogMessage "Sonarr instance confirmation failed." "WARN"
        Write-Host "Please configure your Sonarr instance again."
        return
    }

    $plainTextApiKey = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($sourceSonarrApiKey))
    $confirmApiKey = Read-Host "You specified your Sonarr API key as $plainTextApiKey - is this correct? (y/n)"
    if ($confirmApiKey -ne 'y') {
        Write-LogMessage "Sonarr API key confirmation failed." "WARN"
        Write-Host "Please configure your Sonarr instance again."
        return
    }

    # Export data from Sonarr
    $url = "$sourceSonarrInstance/api/v3/series?apikey=$plainTextApiKey"
    Write-LogMessage "Fetching data from Sonarr API..." "INFO"
    try {
        $response = Invoke-RestMethod -Uri $url -Method Get
        if ($response) {
            $exportPath = "series.json"
            Write-LogMessage "Saving data to $exportPath..." "INFO"
            $response | ConvertTo-Json -Depth 10 | Set-Content -Path $exportPath
            Write-LogMessage "Export completed successfully. Data saved to $exportPath." "INFO"

            $csvOption = Read-Host "Do you want a copy of the export in .csv format? (y/n)"
            if ($csvOption -eq 'y') {
                $csvFilename = Read-Host "Please enter a filename for the .csv (press enter to use series.csv):"
                if ([string]::IsNullOrEmpty($csvFilename)) {
                    $csvFilename = "series.csv"
                }

                Write-LogMessage "Converting data to CSV format..." "INFO"
                $filteredResponse = $response | ForEach-Object {
                    $_ | Select-Object -Property * -ExcludeProperty alternateTitles, images, seasons, genres, tags
                }
                $filteredResponse | Export-Csv -Path $csvFilename -NoTypeInformation
                Write-LogMessage "CSV export completed successfully. Data saved to $csvFilename." "INFO"
            }
        } else {
            Write-LogMessage "Failed to retrieve data from Sonarr." "ERROR"
        }
    } catch {
        Write-LogMessage "Error fetching data from Sonarr API: $_" "ERROR"
    }
}

# Call the export function
Export-Sonarr