# Load the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms

# Event IDs for BugCheck and Reboot
$bugCheckId = "1001" #  BugCheck Event ID
$rebootId = "1074"   #  Reboot Event ID
$Unexpected = "6008"   #  Unexpected reboot Event ID


# Create an OpenFileDialog to select the system*.evtx files
$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
$openFileDialog.InitialDirectory = "C:\script"
$openFileDialog.Filter = "Event Files (*.evtx)|*.evtx"
$openFileDialog.Multiselect = $true

# Show the OpenFileDialog
if ($openFileDialog.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    # Get the selected files
    $evtxFiles = $openFileDialog.FileNames

    # Initialize an array to hold the matching events
    $matchingEvents = @()

    # Loop through each file and check for the events
    foreach ($file in $evtxFiles) {
        $events = Get-WinEvent -Path $file -FilterXPath "*[System[(EventID=$bugCheckId) or (EventID=$rebootId) or (EventID=$Unexpected) ]]"
        $matchingEvents += $events
    }

    # Check if there are two or more matching events
    if ($matchingEvents.Count -ge 2) {
        # Output the events
        Write-Output "Found the following BugCheck and/or Reboot events:"
        $matchingEvents | Select-Object -Property TimeCreated, Id, Message | Format-Table -AutoSize

        # Get the last 30 error events before the first BugCheck or Reboot event
        $firstMatchTime = $matchingEvents[0].TimeCreated
        $errorEventsBefore = Get-WinEvent -FilterHashtable @{LogName='System'; Level=2; StartTime=(Get-Date).AddYears(-1); EndTime=$firstMatchTime} -MaxEvents 30
        # Output the error events
        Write-Output "Listing the last 30 error events before the first BugCheck or Reboot event:"
        $errorEventsBefore | Select-Object -Property TimeCreated, Id, Message | Format-Table -AutoSize
    } else {
        Write-Output "Less than two BugCheck or Reboot events found."
    }
} else {
    Write-Output "No files were selected."
}
