# session-functions.ps1

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
    $leafElement = Split-Path -Leaf (Get-Location)
    $envVarLeafElement = $leafElement -replace "-", "_"
    return "SESSION_BRANCH_$envVarLeafElement"
}
