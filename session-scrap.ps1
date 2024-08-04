# session-scrap.ps1

# Import the common functions
. session-functions.ps1

# Retrieve the session branch name from the environment variable
$envVarName = Get-SessionBranchEnvVarName

Write-host "note: the required environment variable is '$envVarName'."

$sessionBranch = [System.Environment]::GetEnvironmentVariable($envVarName, [System.EnvironmentVariableTarget]::User)

# Check if a session branch name was retrieved
if ([string]::IsNullOrWhiteSpace($sessionBranch)) {
    Write-Host "No session branch for '$envVarName' found. Exiting."
    exit 1
}

# Prompt for confirmation
$confirmation = Read-Host "Are you sure you want to scrap the session branch '$sessionBranch'? This action cannot be undone. Type 'yes' to confirm"

if ($confirmation -ne "yes") {
    Write-Host "Operation cancelled by the user. Exiting."
    exit 1
}

# Remove the session branch environment variable
[System.Environment]::SetEnvironmentVariable($envVarName, $null, [System.EnvironmentVariableTarget]::User)

# Check out the main branch
git checkout main

# Delete the session branch
try {
    git branch -D $sessionBranch
    Write-Host "Deleted session branch: $sessionBranch"
} catch {
    Write-Host "Failed to delete session branch '$sessionBranch'. It may not exist. Exiting."
    exit 1
}

# Fetch the latest changes from the remote repository
git fetch origin

# Reset the main branch to match the remote main branch exactly
git reset --hard origin/main

Write-Host "Session scrapped. The main branch is checked out and reset to the remote state."
