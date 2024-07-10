# Monitor-And-Restart-Process.ps1

param(
    [Parameter(Mandatory=$true)]
    [string]$ProcessName
)

function Get-ExecutablePath {
    param(
        [string]$Name
    )
    
    switch ($Name.ToLower()) {
        "msedge" {
            $edgePath = "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
            if (Test-Path $edgePath) {
                return $edgePath
            }
            $edgePath = "$env:ProgramFiles\Microsoft\Edge\Application\msedge.exe"
            if (Test-Path $edgePath) {
                return $edgePath
            }
        }
        # Add more cases here for other applications if needed
        default {
            try {
                return (Get-Command $Name -ErrorAction Stop).Source
            }
            catch {
                return $null
            }
        }
    }
    return $null
}

function Test-ProcessStatus {
    param (
        [string]$Name
    )
    
    $process = Get-Process -Name $Name -ErrorAction SilentlyContinue
    
    if (-not $process) {
        return "Not Running"
    }
    
    if ($process.Responding) {
        return "Running"
    } else {
        return "Not Responding"
    }
}

function Start-Or-RestartProcess {
    param(
        [string]$Name
    )
    
    $executablePath = Get-ExecutablePath -Name $Name
    
    if (-not $executablePath) {
        Write-Host "Error: Unable to find the executable for $Name. Make sure the process name is correct and the application is installed."
        return
    }
    
    $runningProcesses = Get-Process -Name $Name -ErrorAction SilentlyContinue
    
    if ($runningProcesses) {
        Write-Host "Stopping process: $Name"
        $runningProcesses | Stop-Process -Force
        Start-Sleep -Seconds 2
    }
    
    Write-Host "Starting process: $Name"
    Start-Process $executablePath
    
    Write-Host "Process $Name has been started successfully."
}

# Main execution
$status = Test-ProcessStatus -Name $ProcessName
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Write-Host "[$timestamp] $ProcessName status: $status"

if ($status -eq "Not Running" -or $status -eq "Not Responding") {
    Write-Host "Process is not running or not responding. Attempting to start/restart."
    Start-Or-RestartProcess -Name $ProcessName
} else {
    Write-Host "Process is running correctly. No action needed."
}

# Optionally, log the result to a file
# Add-Content -Path "C:\Path\To\LogFile.log" -Value "[$timestamp] $ProcessName status: $status"
