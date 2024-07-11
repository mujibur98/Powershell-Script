clear-host
cls
# Load the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Create an OpenFileDialog to select the event log file
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.Title = "Select Event Log File"
$openFileDialog.Filter = "Event Log Files (*.evtx)|*.evtx"
$openFileDialog.Multiselect = $false

# Show the dialog and get the selected file
if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    $eventLogPath = $openFileDialog.FileName
} else {
    Write-Warning "No file selected."
    exit
}
Write-Host "Downloading System log..."
# Read the event log file
$events = Get-WinEvent -Path $eventLogPath | Where-Object { $_.Id -eq 6013 }

# Get the latest event ID 6013
$latestEvent = $events | Sort-Object TimeCreated -Descending | Select-Object -First 1

# Check if an event was found
if (!$latestEvent) {
    Write-Warning "No event ID 6013 found in the System log."
    exit
}

# Extract uptime in seconds from the latest event message
if ($latestEvent.Message -match '\d+') {
    $uptimeSeconds = [int]$matches[0]
} else {
    Write-Warning "Could not extract uptime from the event message."
    exit
}

# Convert uptime to days, hours, and minutes
$days = [Math]::Floor($uptimeSeconds / (60 * 60 * 24))
$hours = [Math]::Floor(($uptimeSeconds % (60 * 60 * 24)) / (60 * 60))
$minutes = [Math]::Floor(($uptimeSeconds % (60 * 60)) / 60)

# Display the results
Write-Host "*****************************************************"
Write-Host "Server up Time :", "Days: $days", "Hours: $hours" , "Minutes: $minutes"
Write-Host "*****************************************************"

# Show the dialog and get the selected file
    # Read the event log file
    $events = Get-WinEvent -Path $eventLogPath

    # Get the first event date
    $firstEvent = $events | Select-Object -First 1
    $firstEventDate = $firstEvent.TimeCreated

    # Get the last event date
    $lastEvent = $events | Select-Object -Last 1
    $lastEventDate = $lastEvent.TimeCreated

    # Display the event dates
    Write-Host "Starting Event Date: $($lastEventDate.ToString('yyyy-MM-dd'))"
    Write-Host "Ending Event Date:   $($firstEventDate.ToString('yyyy-MM-dd'))"
    Write-Host "*****************************************************"
    

