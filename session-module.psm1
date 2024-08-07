$version = "1.0.2"
$versionDate = "August 2024"

function Show-Version {
    Write-Host "YES3 session cmdlets version $version ($versionDate)" -ForegroundColor Cyan
}

function Get-DadJoke {
    $headers = @{ Accept = "application/json" }
    $response = Invoke-RestMethod -Uri "https://icanhazdadjoke.com/" -Headers $headers
    Write-Host $response.joke -ForegroundColor Magenta
    return
}

function Get-repoName{
    
    $repoName = Split-Path -Leaf (Get-Location)
    $repoName = $repoName -replace "[- ]", "_"
    $repoName = $repoName -replace "[^a-zA-Z0-9_]", ""
    return $repoName
}

# Function to get the current timestamp and convert it to base 36
function Get-Base36Timestamp {
    $characters = "0123456789abcdefghijklmnopqrstuvwxyz"
    $base = $characters.Length

    # Get the current timestamp in seconds since Unix epoch
    $currentTimestamp = [math]::Round((Get-Date -Date "1970-01-01 00:00:00Z").AddSeconds((Get-Date).ToUniversalTime().Subtract((Get-Date "1970-01-01 00:00:00Z").ToUniversalTime()).TotalSeconds).Subtract((Get-Date "1970-01-01 00:00:00Z").ToUniversalTime()).TotalSeconds)

    $number = $currentTimestamp
    $result = ""

    while ($number -gt 0) {
        $remainder = $number % $base
        $result = $characters[$remainder] + $result
        $number = [math]::Floor($number / $base)
    }

    return $result
}

# Function to get the current session branch environment variable name
function Get-SessionBranchEnvVarName {
    $envVarRepoName = Get-repoName
    return "SESSION_BRANCH_$envVarRepoName".ToUpper()
}

function Start-Session {

    Show-Version

    # Get the session branch environment variable name
    $envVarName = Get-SessionBranchEnvVarName

    # Check if the session branch environment variable is already set
    $existingSessionBranch = [System.Environment]::GetEnvironmentVariable($envVarName, [System.EnvironmentVariableTarget]::User)

    if (-not [string]::IsNullOrWhiteSpace($existingSessionBranch)) {
        Write-Host "A session is already in progress with branch: $existingSessionBranch. Exiting."  -ForegroundColor Red
        return 1
    }

    # Fetch the latest changes from the remote repository
    git fetch origin

    # Attempt to pull the latest changes from the main branch
    try {
        git checkout main
        git pull origin main
    } catch {
        Write-Host "Failed to pull the latest changes from the main branch. There may be unstashed changes or the local branch might be ahead of the remote branch."  -ForegroundColor Red

        # Prompt the user for approval to perform a hard reset
        $confirmation = Read-Host "Do you want to perform a hard reset on the main branch? This will discard all local changes. Type 'yes' to confirm"

        if ($confirmation -eq "yes") {
            git reset --hard origin/main
            Write-Host "Hard reset performed on the main branch." -ForegroundColor Greed
        } else {
            Write-Host "Operation cancelled by the user. Exiting."  -ForegroundColor Cyan
            return 1
        }
    }

    # Retrieve the Windows username
    $username = $env:USERNAME

    $repoName = Get-repoName

    # Get the base 36 encoded current timestamp
    $base36Timestamp = Get-Base36Timestamp

    # Generate the session branch name
    $sessionBranch = "$username-$repoName-$base36Timestamp".ToLower()
    # $sessionBranch = "$repoName-$base36Timestamp"

    # Set the session branch name as an environment variable
    [System.Environment]::SetEnvironmentVariable($envVarName, $sessionBranch, [System.EnvironmentVariableTarget]::User)

    # Try to create and switch to the new session branch
    try {
        git checkout -b $sessionBranch
        Write-Host "Editing session started." -ForegroundColor Cyan
    } catch {
        Write-Host "Branch '$sessionBranch' already exists. Exiting." -ForegroundColor Red
        return 1
    }
}

function Complete-Session {

    Show-Version

    # Retrieve the session branch name from the environment variable
    $envVarName = Get-SessionBranchEnvVarName
    $sessionBranch = [System.Environment]::GetEnvironmentVariable($envVarName, [System.EnvironmentVariableTarget]::User)

    # Check if a session branch name was retrieved
    if ([string]::IsNullOrWhiteSpace($sessionBranch)) {
        Write-Host "No session branch for '$envVarName' found. Make sure to run the start-session script first. Exiting." -ForegroundColor Red
        return 1
    }

    # Ensure the session branch is checked out
    git checkout $sessionBranch

    # Add all changes, including deletions, to staging
    git add --all

    # vscode reojrct support: Remove the .vscode directory from staging and tracking
    git reset .vscode/ 2>$null
    git rm --cached -r -f .vscode 2>$null

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
        return 1
    }

    # Switch to the main branch
    git checkout main

    # Reset the main branch to match the remote main branch exactly
    git reset --hard origin/main

    Write-Host "Editing session completed. The main branch is checked out and reset to the remote state." -ForegroundColor Cyan
}

function Undo-Session {

    Show-Version

    # Retrieve the session branch name from the environment variable
    $envVarName = Get-SessionBranchEnvVarName
    $sessionBranch = [System.Environment]::GetEnvironmentVariable($envVarName, [System.EnvironmentVariableTarget]::User)

    # Check if a session branch name was retrieved
    if ([string]::IsNullOrWhiteSpace($sessionBranch)) {
        Write-Host "No session branch for '$envVarName' found. Exiting." -ForegroundColor Red
        return 1
    }

    # Prompt for confirmation
    $confirmation = Read-Host "Are you sure you want to remove the session branch '$sessionBranch'? This action cannot be undone. Type 'yes' to confirm"

    if ($confirmation -ne "yes") {
        Write-Host "Operation cancelled by the user. Exiting." -ForegroundColor Cyan
        return 1
    }

    # Remove the session branch environment variable
    [System.Environment]::SetEnvironmentVariable($envVarName, $null, [System.EnvironmentVariableTarget]::User)

    # Check out the main branch
    git checkout main

    # Delete the session branch
    try {
        git branch -D $sessionBranch
        Write-Host "Deleted session branch: $sessionBranch" -ForegroundColor Cyan
    } catch {
        Write-Host "Failed to delete session branch '$sessionBranch'. It may not exist. Exiting." -ForegroundColor Red
        return 1
    }

    # Fetch the latest changes from the remote repository
    git fetch origin

    # Reset the main branch to match the remote main branch exactly
    git reset --hard origin/main

    Write-Host "Session removed. The main branch is checked out and reset to the remote state." -ForegroundColor Cyan
}

function Get-SessionCommands {

    Show-Version

    Write-Host "`nAvailable session commands:`n" -ForegroundColor Magenta
    Write-Host "  - Start-Session:    Create and checkout a new session branch" -ForegroundColor Magenta
    Write-Host "                      so you can start editing files.`n" -ForegroundColor Magenta
    Write-Host "  - Complete-Session: Stage and commit all changes," -ForegroundColor Magenta
    Write-Host "                      push the session branch to the remote repository," -ForegroundColor Magenta
    Write-Host "                      and switch back to the local main branch.`n" -ForegroundColor Magenta
    Write-Host "  - Undo-Session:     Remove the session branch and abandon changes`n" -ForegroundColor Magenta
    Write-Host "  - Get-DadJoke:      Does what you think it does`n" -ForegroundColor Magenta
    Write-Host "  - Get-SessionCommands:    Display this list of available session commands`n" -ForegroundColor Magenta
}

# Export functions
Export-ModuleMember -Function Show-Version, Get-DadJoke, Get-repoName, Get-Base36Timestamp, Get-SessionBranchEnvVarName, Start-Session, Complete-Session, Undo-Session, Get-SessionCommands
