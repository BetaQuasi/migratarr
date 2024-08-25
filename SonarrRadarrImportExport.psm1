# SonarrRadarrImportExport.psm1

# Function to read existing configuration
function Get-Config {
    if (Test-Path "config.json") {
        $config = Get-Content -Path "config.json" | ConvertFrom-Json
        $json = $config | ConvertTo-Json
        return $json | ConvertFrom-Json -AsHashtable
    } else {
        return @{ }
    }
}

# Function to write configuration
function Set-Config {
    param (
        [Parameter(Mandatory = $true)]
        [hashtable]$config
    )
    $config | ConvertTo-Json -Depth 10 | Set-Content -Path "config.json"
}

# Function to log messages
function Write-LogMessage {
    param (
        [string]$message,
        [string]$level = "INFO"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "$timestamp [$level] $message"
    $logFile = "$PSScriptRoot\arrpstools.log"
    Add-Content -Path $logFile -Value $logMessage
    Write-Host $logMessage
}

# Function to delete configuration
function Remove-Config {
    if (Test-Path "config.json") {
        Remove-Item "config.json"
        Write-LogMessage "Configuration deleted." "INFO"
    } else {
        Write-LogMessage "No configuration file found." "WARN"
    }
}

# Function to set Sonarr instance details
function Set-SonarrConfig {
    $config = Get-Config

    $export = Read-Host "Do you want to configure an export from an existing Sonarr instance? (y/n)"
    if ($export -eq 'y') {
        $config.sourceSonarrInstance = Read-Host "Please enter the URL for your source Sonarr instance (eg. http://sonarr:8989)"
        $config.sourceSonarrApiKey = Read-Host "Please enter your API key for your Sonarr instance (Find this under Settings -> General -> Security)" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
    }

    $import = Read-Host "Do you want to configure an import to a new Sonarr instance? (y/n)"
    if ($import -eq 'y') {
        $config.destinationSonarrInstance = Read-Host "Please enter the URL for your destination Sonarr instance (eg. http://sonarrnew:8989)"
        $config.destinationSonarrApiKey = Read-Host "Please enter your API key for your destination Sonarr instance (Find this under Settings -> General -> Security)" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
    }

    Set-Config -config $config
    Write-Host "Sonarr configuration saved."
}

# Function to set Radarr instance details
function Set-RadarrConfig {
    $config = Get-Config

    $export = Read-Host "Do you want to configure an export from an existing Radarr instance? (y/n)"
    if ($export -eq 'y') {
        $config.sourceRadarrInstance = Read-Host "Please enter the URL for your source Radarr instance (eg. http://radarr:8989)"
        $config.sourceRadarrApiKey = Read-Host "Please enter your API key for your source Radarr instance (Find this under Settings -> General -> Security)" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
    }

    $import = Read-Host "Do you want to configure an import to a new Radarr instance? (y/n)"
    if ($import -eq 'y') {
        $config.destinationRadarrInstance = Read-Host "Please enter the URL for your destination Radarr instance (eg. http://radarrnew:8989)"
        $config.destinationRadarrApiKey = Read-Host "Please enter your API key for your destination Radarr instance (Find this under Settings -> General -> Security)" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString
    }

    Set-Config -config $config
    Write-Host "Radarr configuration saved."
}

# Export the functions
Export-ModuleMember -Function Get-Config, Set-Config, Write-LogMessage, Remove-Config, Set-SonarrConfig, Set-RadarrConfig