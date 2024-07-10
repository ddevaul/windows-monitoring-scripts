# Restart-Or-Start-Process.ps1

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

function Restart-Or-Start-ProcessByName {
    param(
        [string]$Name
    )
    
    $executablePath = Get-ExecutablePath -Name $Name
    
    if (-not $executablePath) {
        Write-Host "Error: Unable to find the executable for $Name. Make sure the process name is correct and the application is installed."
        return
    }
    
    try {
        $process = Get-Process -Name $Name -ErrorAction Stop
        
        # Process is running, let's restart it
        Write-Host "Stopping process: $Name"
        $process | Stop-Process -Force
        
        # Wait for the process to fully stop
        Start-Sleep -Seconds 2
    }
    catch [Microsoft.PowerShell.Commands.ProcessCommandException] {
        # Process is not running, we'll start it
        Write-Host "Process $Name is not running. Attempting to start it."
    }
    catch {
        Write-Host "An error occurred: $($_.Exception.Message)"
        return
    }
    
    Write-Host "Starting process: $Name"
    Start-Process $executablePath
    
    Write-Host "Process $Name has been started successfully."
}

# Call the function with the provided process name
Restart-Or-Start-ProcessByName -Name $ProcessName
