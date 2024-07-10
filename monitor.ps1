# App Monitoring Script

# Replace 'YourAppName' with the actual name of the process you want to monitor
$appName = "msedge"

# Function to check if the app is responding
function Test-AppStatus {
    param (
        [string]$ProcessName
    )
    
    $process = Get-Process -Name $ProcessName -ErrorAction SilentlyContinue
    
    if (-not $process) {
        return "Not Running"
    }
    
    if ($process.Responding) {
        return "Running"
    } else {
        return "Not Responding"
    }
}

# Get the current status
$status = Test-AppStatus -ProcessName $appName

# Get current timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Output the result
"[$timestamp] $appName status: $status"

# Optionally, log the result to a file
# Add-Content -Path "C:\Path\To\LogFile.log" -Value "[$timestamp] $appName status: $status"

# If you want to take action when the app is not responding or not running, you can add conditions here
if ($status -eq "Not Responding") {
    # For example, restart the application
    # Stop-Process -Name $appName -Force
    # Start-Process "path\to\your\app.exe"
    "App is not responding. Consider restarting it."
} elseif ($status -eq "Not Running") {
    # For example, start the application
    # Start-Process "path\to\your\app.exe"
    "App is not running. Consider starting it."
}
