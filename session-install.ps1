# Function to download a script from GitHub

$version = "1.0.2"

# August 6 2024 PC
function Invoke-DownloadScriptFromGitHub {
    param (
        [string]$scriptName,
        [string]$targetDirectory
    )

    $repoUrl = "https://raw.githubusercontent.com/yale-redcap/yes3-powershell-scripts/main"
    $scriptUrl = "$repoUrl/$scriptName"
    $scriptPath = "$targetDirectory\$scriptName"
    try {
        Invoke-WebRequest -Uri $scriptUrl -OutFile $scriptPath -ErrorAction Stop
        Write-Host "Downloaded: $scriptName to $scriptPath"
    } catch {
        Write-Host "Failed to download $scriptName from $scriptUrl"
    }
}

# Define the path to the PS profile script
$profilePath = $PROFILE

# the location for the session module script
$scriptDirectory = "$env:USERPROFILE\Documents\PowerShellScripts"

# Create the WindowsPowerShell directory if it doesn't exist
if (!(Test-Path -Path $scriptDirectory)) {
    New-Item -Path $scriptDirectory -ItemType Directory -Force
    Write-Host "Created directory: $scriptDirectory"
} else {
    Write-Host "Directory already exists: $scriptDirectory"
}

$moduleScript = "session-module.psm1"

Invoke-DownloadScriptFromGitHub -scriptName $moduleScript -targetDirectory $scriptDirectory

# Create the profile script if it doesn't exist
if (!(Test-Path -Path $profilePath)) {
    New-Item -Path $profilePath -ItemType File -Force
    Write-Host "Created new profile script at $profilePath"
}

# Read the content of the profile script or initialize as empty if the file does not exist or is empty
$profileContent = if (Test-Path -Path $profilePath) {
    $content = Get-Content -Path $profilePath -Raw
    if ($content) { $content } else { "" }
} else {
    ""
}

$modulePath = "$scriptDirectory\$moduleScript"

if ( $profileContent -notmatch [regex]::Escape("$modulePath") ){
    Add-Content -Path $profilePath -Value "Import-Module `"$modulePath`""
    Write-Host "Added Import-Module statement for $modulePath"
} else {
    Write-Host "Import-Module statement for $modulePath already exists in profile script."
}


if ( $profileContent -notmatch [regex]::Escape("$modulePath") ){
    Add-Content -Path $profilePath -Value "Import-Module `"$modulePath`""
    Write-Host "Added Import-Module statement for $modulePath"
}


if ( $profileContent -notmatch "Show-Version" ){
    Add-Content -Path $profilePath -Value "Show-Version"
    Write-Host "Added Show-Version statement for $modulePath"
}
Write-Host "Session cmdlets version $version will be available after you close and reopen Powershell." -ForegroundColor DarkCyan
