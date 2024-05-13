# Check if C:\dell directory exists; create if not
if (-not (Test-Path -Path "C:\dell")) {
    New-Item -ItemType Directory -Path "C:\dell"
}

# Run Get-WindowsUpdateLog
Get-WindowsUpdateLog

# Define source and destination paths for WindowsUpdate.log
$sourcePath = "$env:USERPROFILE\Desktop\WindowsUpdate.log"
$destinationPath = "C:\dell\WindowsUpdate.log"

# Copy the log file to C:\dell (overwrite if it exists)
Copy-Item -Path $sourcePath -Destination $destinationPath -Force

# Define source and destination paths for cbs.log
$cbsLogSourcePath = "C:\Windows\Logs\CBS\cbs.log"
$cbsLogDestinationPath = "C:\dell\cbs.log"

# Copy cbs.log to C:\dell (overwrite if it exists)
Copy-Item -Path $cbsLogSourcePath -Destination $cbsLogDestinationPath -Force

Write-host "================================="
Write-host   "Checking Cbs logs for errors"
Write-host "================================="


# Define CBS log path
$cbsLogPath = "$env:systemroot\Logs\CBS\CBS.log"

# Function to filter error lines
function GetErrorLines($logPath) {
  # Filter lines containing "ERROR" 
  Get-Content -Path $logPath | Where-Object { 
    ($_ -match "ERROR" -or $_ -match "WARNING" -or $_ -match "Failure") 
  }
}

# Read CBS log and filter errors
$errorLines = GetErrorLines -logPath $cbsLogPath

# Check if any errors were found
if ($errorLines.Count -gt 0) {
  Write-Host "Errors found in CBS.log:"
  Write-Host ($errorLines -join "`n  ")
} else {
  Write-Host "No errors found in CBS.log."
}
