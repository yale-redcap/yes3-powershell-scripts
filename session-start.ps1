# session-start.ps1 is a PowerShell script that is used to start a new session branch in a Git repository.

Show-Version

# Get the session branch environment variable name
$envVarName = Get-SessionBranchEnvVarName

# Check if the session branch environment variable is already set
$existingSessionBranch = [System.Environment]::GetEnvironmentVariable($envVarName, [System.EnvironmentVariableTarget]::User)

if (-not [string]::IsNullOrWhiteSpace($existingSessionBranch)) {
    Write-Host "A session is already in progress with branch: $existingSessionBranch. Exiting."
    exit 1
}

# Fetch the latest changes from the remote repository
git fetch origin

# Attempt to pull the latest changes from the main branch
try {
    git checkout main
    git pull origin main
} catch {
    Write-Host "Failed to pull the latest changes from the main branch. There may be unstashed changes or the local branch might be ahead of the remote branch."

    # Prompt the user for approval to perform a hard reset
    $confirmation = Read-Host "Do you want to perform a hard reset on the main branch? This will discard all local changes. Type 'yes' to confirm"

    if ($confirmation -eq "yes") {
        git reset --hard origin/main
        Write-Host "Hard reset performed on the main branch."
    } else {
        Write-Host "Operation cancelled by the user. Exiting."
        exit 1
    }
}

# Retrieve the Windows username
$username = $env:USERNAME

$leafElement = Split-Path -Leaf (Get-Location)

# Get the base 36 encoded current timestamp
$base36Timestamp = Get-Base36Timestamp

# Generate the session branch name
$sessionBranch = "$username-$leafElement-$base36Timestamp"

# Set the session branch name as an environment variable
[System.Environment]::SetEnvironmentVariable($envVarName, $sessionBranch, [System.EnvironmentVariableTarget]::User)

# Try to create and switch to the new session branch
try {
    git checkout -b $sessionBranch
    Write-Host "Switched to new branch: $sessionBranch. Get to work."
} catch {
    Write-Host "Branch '$sessionBranch' already exists. Exiting."
    exit 1
}
