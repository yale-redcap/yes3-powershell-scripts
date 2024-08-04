# Import the common functions
. "$env:USERPROFILE\Documents\WindowsPowerShell\session-functions.ps1"

# Define the WindowsPowerShell directory
$customPath = "$env:USERPROFILE\Documents\WindowsPowerShell"

# Define the URL of the GitHub repository containing the ps-update script
$githubRepoUrl = "https://raw.githubusercontent.com/YourGitHubUsername/YourRepository/main"

# The name of the update script
$updateScriptName = "ps-update.ps1"

# Download the update script from the GitHub repository
Download-ScriptFromGitHub -scriptName $updateScriptName -targetPath $customPath -repoUrl $githubRepoUrl

Write-Host "ps-update.ps1 has been updated."
