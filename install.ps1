# import the function library
. .\session-functions.ps1

# Define the path to the PS profile script
$profilePath = $PROFILE

# Define the script directory to be added to PATH (the directory of the profile script)
$scriptDirectory = Split-Path -Parent $profilePath

# List of scripts to be downloaded from the GitHub repository
$scripts = @(
    "session-functions.ps1",
    "session-start.ps1",
    "session-scrap.ps1",
    "session-end.ps1"
)

# Create the WindowsPowerShell directory if it doesn't exist
if (!(Test-Path -Path $scriptDirectory)) {
    New-Item -Path $scriptDirectory -ItemType Directory -Force
    Write-Host "Created directory: $scriptDirectory"
} else {
    Write-Host "Directory already exists: $scriptDirectory"
}

# Download each script from the GitHub repository
foreach ($script in $scripts) {
    Invoke-DownloadScriptFromGitHub -scriptName $script -targetDirectory $scriptDirectory
}

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

# Check if the custom path is already in the profile script
# if ($profileContent -notmatch [regex]::Escape("`";$scriptDirectory`"")) {
#     # Append the PATH statement to the profile script
#     $pathCommand = "`$env:PATH += `";$scriptDirectory`""
#     Add-Content -Path $profilePath -Value "# Add WindowsPowerShell directory to PATH"
#     Add-Content -Path $profilePath -Value $pathCommand
#     Write-Host "Appended custom PATH statement to profile script."
# } else {
#     Write-Host "Custom PATH statement already exists in profile script."
# }

# Add aliases for the session scripts
$aliases = @(
    "session-functions",
    "session-start",
    "session-scrap",
    "session-end"
)

foreach ($alias in $aliases) {
    if ($profileContent -notmatch [regex]::Escape("Set-Alias $alias")) {
        Add-Content -Path $profilePath -Value "Set-Alias $alias `"$scriptDirectory\$alias.ps1`""
        Write-Host "Added alias for $alias"
    } else {
        Write-Host "Alias for $alias already exists in profile script."
    }
}

# Check if the session scripts enabled message is present in the profile script
if ($profileContent -notmatch "YES3 session scripts enabled") {
    Add-Content -Path $profilePath -Value "`nWrite-Host `"YES3 session scripts enabled.`""
} 

Write-Host "Update complete. You can now use the session scripts."
