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
