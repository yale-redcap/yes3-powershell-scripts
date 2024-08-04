# Import the common functions
. .\session-functions.ps1

# Define the path to the profile script
$profilePath = $PROFILE

# Define the WindowsPowerShell directory to be added to PATH
$customPath = "$env:USERPROFILE\Documents\WindowsPowerShell"

# List of scripts to be downloaded from the GitHub repository
$scripts = @(
    "session-functions.ps1",
    "session-start.ps1",
    "session-scrap.ps1",
    "session-end.ps1"
)

# Create the WindowsPowerShell directory if it doesn't exist
if (!(Test-Path -Path $customPath)) {
    New-Item -Path $customPath -ItemType Directory -Force
    Write-Host "Created directory: $customPath"
} else {
    Write-Host "Directory already exists: $customPath"
}

# Download each script from the GitHub repository
foreach ($script in $scripts) {
    Download-ScriptFromGitHub -scriptName $script -targetPath $customPath
}

# Create the profile script if it doesn't exist
if (!(Test-Path -Path $profilePath)) {
    New-Item -Path $profilePath -Type File -Force
    Write-Host "Created new profile script at $profilePath"
} else {
    Write-Host "Profile script already exists at $profilePath"
}

# Read the content of the profile script
$profileContent = Get-Content -Path $profilePath -Raw

# Check if the custom path is already in the profile script
if ($profileContent -notmatch [regex]::Escape($customPath)) {
    # Append the PATH statement to the profile script
    Add-Content -Path $profilePath -Value "`n# Add WindowsPowerShell directory to PATH"
    Add-Content -Path $profilePath -Value "$env:PATH += `"$customPath`""
    Write-Host "Appended custom PATH statement to profile script."
} else {
    Write-Host "Custom PATH statement already exists in profile script."
}

# Add aliases for the session scripts
$aliases = @(
    "session-functions",
    "session-start",
    "session-scrap",
    "session-end"
)

foreach ($alias in $aliases) {
    if ($profileContent -notmatch [regex]::Escape("Set-Alias $alias")) {
        Add-Content -Path $profilePath -Value "`nSet-Alias $alias `"$customPath\$alias.ps1`""
        Write-Host "Added alias for $alias"
    } else {
        Write-Host "Alias for $alias already exists in profile script."
    }
}

Write-Host "Update complete. You can now use the session scripts."
