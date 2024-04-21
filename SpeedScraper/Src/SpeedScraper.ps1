# Display ASCII Art Banner
Write-Host @"
________                 ________________                                        
__  ___/_______________________  /_  ___/__________________ _____________________
_____ \___  __ \  _ \  _ \  __  /_____ \_  ___/_  ___/  __ `/__  __ \  _ \_  ____/
____/ /__  /_/ /  __/  __/ /_/ / ____/ // /__ _  /   / /_/ /__  /_/ /  __/  /    
/____/ _  .___/\___/\___/\__,_/  /____/ \___/ /_/    \__,_/ _  .___/\___//_/    
       /_/                                                  /_/                  
Program Made by: AsteRisk
"@ -ForegroundColor Cyan

# Prompt to continue
$null = Read-Host "Press Enter to continue..."

# Discover the base directory dynamically relative to the script's location
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
$baseDir = Resolve-Path "$scriptPath\.."
$logsDir = "$baseDir\Logs"
$downloadDirBase = "$baseDir\Downloaded Sites"

# Ensure log and download directories exist
if (-Not (Test-Path $logsDir)) {
    New-Item -ItemType Directory -Path $logsDir
}
if (-Not (Test-Path $downloadDirBase)) {
    New-Item -ItemType Directory -Path $downloadDirBase
}

# Check if Chocolatey is installed
if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
    # Download and install Chocolatey if not installed
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
}

# Refresh environment to include Chocolatey's path
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + $env:ALLUSERSPROFILE + "\chocolatey\bin"

# Check if wget is installed
if (-Not (Get-Command wget -ErrorAction SilentlyContinue)) {
    # Install wget using Chocolatey if not installed
    choco install wget -y
}

# Ask for the website URL
$website = Read-Host "Please enter the website URL to download"
# Ask user for download type: full site or single page
$downloadType = Read-Host "Type 'full' to download the entire site or 'single' to download just this page"

# Determine the directory for the download based on the website URL
$domainName = [System.Uri]$website
$downloadDir = Join-Path $downloadDirBase ($domainName.Host -replace "\.", "_")

# Ensure individual download directory exists
if (-Not (Test-Path $downloadDir)) {
    New-Item -ItemType Directory -Path $downloadDir
}

# Construct and execute the command based on user choice
try {
    $wgetOptions = "--convert-links --adjust-extension --page-requisites --directory-prefix=$downloadDir"
    if ($downloadType -eq 'full') {
        $wgetCommand = "wget --mirror --backup-converted --level=7 --tries=6 --wait=5 --recursive --restrict-file-names=windows --domains=$website --no-parent $wgetOptions $website"
    } elseif ($downloadType -eq 'single') {
        $wgetCommand = "wget $wgetOptions $website"
    } else {
        Write-Host "Invalid option entered. No download performed."
        exit
    }

    Invoke-Expression $wgetCommand
}
catch {
    $errorMessage = $_.Exception.Message
    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
    $logFilename = "$logsDir\error_${timestamp}.txt"
    "$timestamp - Failed to download ${website}: $errorMessage" | Out-File $logFilename
}

# Output completion status
if ($downloadType -eq 'full' -or $downloadType -eq 'single') {
    Write-Host "Download complete. Check $downloadDir for files."
}
