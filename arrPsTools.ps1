# arrPsTools.ps1

# Import the module
Import-Module "$PSScriptRoot\SonarrRadarrImportExport.psm1"

# Function to display the menu
function Show-Menu {
    Clear-Host
    Write-Host "1. Configure Sonarr instance details"
    Write-Host "2. Configure Radarr instance details"
    Write-Host "3. Export from existing Sonarr instance"
    Write-Host "4. Export from existing Radarr instance"
    Write-Host "5. Import to new Sonarr instance"
    Write-Host "6. Import to new Radarr instance"
    Write-Host "7. Delete configuration and start over"
    Write-Host "8. Exit script"
}

# Function to run the main menu loop
function Invoke-MainMenu {
    while ($true) {
        Show-Menu
        $choice = Read-Host "Please select an option"
        switch ($choice) {
            1 {
                Write-LogMessage "Configuring Sonarr instance details..." "INFO"
                Set-SonarrConfig
            }
            2 {
                Write-LogMessage "Configuring Radarr instance details..." "INFO"
                Set-RadarrConfig
            }
            3 {
                Write-LogMessage "Starting Sonarr export..." "INFO"
                try {
                    & "$PSScriptRoot\sonarrExport.ps1"
                    Write-LogMessage "Sonarr export completed." "INFO"
                } catch {
                    Write-LogMessage "Error during Sonarr export: $_" "ERROR"
                }
            }
            4 {
                Write-LogMessage "Starting Radarr export..." "INFO"
                try {
                    & "$PSScriptRoot\radarrExport.ps1"
                    Write-LogMessage "Radarr export completed." "INFO"
                } catch {
                    Write-LogMessage "Error during Radarr export: $_" "ERROR"
                }
            }
            5 {
                Write-LogMessage "Starting Sonarr import..." "INFO"
                try {
                    & "$PSScriptRoot\sonarrImport.ps1"
                    Write-LogMessage "Sonarr import completed." "INFO"
                } catch {
                    Write-LogMessage "Error during Sonarr import: $_" "ERROR"
                }
            }
            6 {
                Write-LogMessage "Starting Radarr import..." "INFO"
                try {
                    & "$PSScriptRoot\radarrImport.ps1"
                    Write-LogMessage "Radarr import completed." "INFO"
                } catch {
                    Write-LogMessage "Error during Radarr import: $_" "ERROR"
                }
            }
            7 {
                Write-LogMessage "Deleting configuration..." "INFO"
                Remove-Config
            }
            8 {
                Write-LogMessage "Exiting script." "INFO"
                exit
            }
            default {
                Write-LogMessage "Invalid option selected." "WARN"
                Write-Host "Invalid option. Please try again."
            }
        }
    }
}

# Call the main menu function
Invoke-MainMenu