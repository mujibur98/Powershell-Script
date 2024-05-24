# Load the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
cls
$eventLogPath = [System.Windows.Forms.OpenFileDialog]::new()
$eventLogPath.Title = "Select Event Log File"
$eventLogPath.Filter = "Event Log Files (*.evtx)|*.evtx"
$eventLogPath.Multiselect = $false

if ($eventLogPath.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    # Read the event log file
    Write-Host "Downloading System log..."
    $eventLog = Get-WinEvent -Path $eventLogPath.FileName
   #Progress Bar  
   cls
    For ($i = 0; $i -le 100; $i++) {
    Start-Sleep -Milliseconds 20
    Write-Progress -Activity "Counting to 100" -Status "Current Count: $i" -PercentComplete $i -CurrentOperation "Counting ..."
}
    # Check if the log name is the system log
    if ($eventLog.LogName -eq "System") {
        # Define the desired event IDs
        $desiredEventIDs = 1001, 1074, 6008, 41
cls
        # Check if each event ID exists in the log
	Write-Host "**************************************************************************************************************************" -ForegroundColor Green
        Write-Host "*Event ID 1074 is an event ID that indicates the system has been shutdown by a process or a user                         *" -ForegroundColor Green
        Write-Host "*Event ID 6008 is an error that indicates that the system shut down unexpectedly                                         *" -ForegroundColor Green
	Write-Host "*Event ID 1001 is an error that the computer has rebooted from a bugcheck                                                *" -ForegroundColor Green
	Write-Host "*Event ID 41 is an error that indicates that some unexpected activity prevented Windows from shutting down correctly     *" -ForegroundColor Green
	Write-Host "**************************************************************************************************************************" -ForegroundColor Green


        foreach ($eventID in $desiredEventIDs) {
            $foundEvent = $eventLog | Where-Object { $_.Id -eq $eventID }
            if ($foundEvent) {
                $foundEvent | Select-Object -Property TimeCreated, Id, Message | Format-Table -AutoSize
            } else {
                Write-Host "Event ID $eventID not found."
            }
        }
    } else {
	Write-Host "*************************************" -ForegroundColor Red
        Write-Host "*Selected log is not the system log.*" -ForegroundColor Red
	Write-Host "*************************************" -ForegroundColor Red        
# Exit with an error
        exit 1
    }
} else {
    Write-Host "*************************************" -ForegroundColor Green
    Write-Host "*****No event log file selected.*****" -ForegroundColor Green
    Write-Host "*************************************" -ForegroundColor Green
    
    # Exit with an error
    exit 1
}

# Only proceed if $eventLog has a value (meaning successful read)

function Get-UserInput {
    param (
        [string]$Prompt,
        [int]$Default
    )

    $timeout = New-TimeSpan -Seconds 10
    $input = Read-Host -Prompt "$Prompt (default: $Default)"
    if ([string]::IsNullOrEmpty($input)) {
        return $Default
    }

    try {
        return [int]$input
    } catch {
        Write-Host "Invalid input. Using default value: $Default"
        return $Default
    }
}



# Prompt the user for the desired number of error events
$numberOfEvents = Get-UserInput -Prompt "Enter the number of error events to list" -Default 100

if ($eventLog) {
    # Get the latest error events
    $errorEvents = $eventLog | Where-Object { $_.LevelDisplayName -eq 'Error' } | Select-Object -first $numberOfEvents

    # Check if any error events were found
    if ($errorEvents) {
        # Display the error events
        $errorEvents | Select-Object -Property TimeCreated, Id, Message | Format-Table -AutoSize
    } else {
        # No error events found
        Write-Host "No error events found in the selected log."
    }
} else {
    # Event log could not be read
    Write-Host "Couldn't access the specified event log."
}



