# session-end.ps1

# Import the common functions
$scriptDirectory = Split-Path -Parent $PROFILE
. "$scriptDirectory\session-functions.ps1"

# Retrieve the session branch name from the environment variable
$envVarName = Get-SessionBranchEnvVarName
$sessionBranch = [System.Environment]::GetEnvironmentVariable($envVarName, [System.EnvironmentVariableTarget]::User)

# Check if a session branch name was retrieved
if ([string]::IsNullOrWhiteSpace($sessionBranch)) {
    Write-Host "No session branch for '$envVarName' found. Make sure to run the start-session script first. Exiting."
    exit 1
}

# Ensure the session branch is checked out
git checkout $sessionBranch

# Add all changes to staging
git add --all

# Prompt for a commit message
$commitMessage = Read-Host -Prompt "Enter commit description"

# Retrieve the Windows username
$username = $env:USERNAME

# Generate the current timestamp in ISO format
$datestring = Get-Date -Format "yyyy-MM-dd HH:mm"

# Use default message if no commit message is provided
if ([string]::IsNullOrWhiteSpace($commitMessage)) {
    $commitMessage = "edits made by $username on $datestring"
}

# Commit the changes
git commit -m "$commitMessage"

# Push the session branch to the remote repository
try {
    git push origin $sessionBranch
    Write-Host "Successfully pushed branch: $sessionBranch"

    # If push is successful, remove the session branch environment variable
    [System.Environment]::SetEnvironmentVariable($envVarName, $null, [System.EnvironmentVariableTarget]::User)
} catch {
    Write-Host "Failed to push branch '$sessionBranch'. Exiting."
    exit 1
}

# Switch to the main branch
git checkout main

# Reset the main branch to match the remote main branch exactly
git reset --hard origin/main

Write-Host "Session ended. The main branch is checked out and reset to the remote state."
