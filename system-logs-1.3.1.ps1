cls
# Function to get the current time zone ID
function Get-CurrentTimeZone {
    return (Get-TimeZone).Id
}

# Function to change the time zone
function Set-TimeZoneById {
    param (
        [string]$timeZoneId
    )

    try {
        Set-TimeZone -Id $timeZoneId
        Write-Host "Time zone changed to $timeZoneId"
    } catch {
        Write-Host "Failed to change time zone to $timeZoneId"
    }
}

# Store the original time zone ID
$originalTimeZone = Get-CurrentTimeZone

# Variable to track if the time zone was changed
$timeZoneChanged = $false

# Main menu loop for time zone selection
cls
$validSelectionMade = $false
while (-not $validSelectionMade) {
    Write-Host "Select a time zone to change to:"
    Write-Host "1. Malaysia (Singapore Standard Time)"
    Write-Host "2. Thailand (SE Asia Standard Time)"
    Write-Host "3. Australia (Choose from sub-menu)"
    Write-Host "4. United States (Eastern Standard Time)"
    Write-Host "5. Japan (Tokyo Standard Time)"
    Write-Host "6. India (India Standard Time)"
    Write-Host "7. Continue without changing the time zone"
    Write-Host "Enter the number corresponding to your choice."

    # Get user input
    $selection = Read-Host "Please enter your choice (1-7):"

    # Map the selection to the time zone ID or continue without changing
cls
    switch ($selection) {
        "1" { Set-TimeZoneById -timeZoneId "Singapore Standard Time"; $timeZoneChanged = $true; $validSelectionMade = $true }
        "2" { Set-TimeZoneById -timeZoneId "SE Asia Standard Time"; $timeZoneChanged = $true; $validSelectionMade = $true }
        "3" { 
            $validAusSelection = $false
            while (-not $validAusSelection) {
                Write-Host "Select an Australian time zone:"
                Write-Host "a. AUS Eastern Standard Time"
                Write-Host "b. AUS Central Standard Time"
                Write-Host "c. AUS Western Standard Time"
                Write-Host "Enter the letter corresponding to your choice."

                $ausSelection = Read-Host "Please enter your choice (a-c):"
cls
                switch ($ausSelection) {
                    "a" { Set-TimeZoneById -timeZoneId "AUS Eastern Standard Time"; $timeZoneChanged = $true; $validAusSelection = $true }
                    "b" { Set-TimeZoneById -timeZoneId "AUS Central Standard Time"; $timeZoneChanged = $true; $validAusSelection = $true }
                    "c" { Set-TimeZoneById -timeZoneId "AUS Western Standard Time"; $timeZoneChanged = $true; $validAusSelection = $true }
                    default { Write-Host "Invalid selection. Please select a valid Australian time zone." }
                }
            }
            $validSelectionMade = $true
        }
        "4" { Set-TimeZoneById -timeZoneId "Eastern Standard Time"; $timeZoneChanged = $true; $validSelectionMade = $true }
        "5" { Set-TimeZoneById -timeZoneId "Tokyo Standard Time"; $timeZoneChanged = $true; $validSelectionMade = $true }
        "6" { Set-TimeZoneById -timeZoneId "India Standard Time"; $timeZoneChanged = $true; $validSelectionMade = $true }
        "7" { Write-Host "Continuing without changing the time zone."; $validSelectionMade = $true }
        default { Write-Host "Invalid selection. Please enter a number from 1 to 7." }
    }
}

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
   
# Maximize the current PowerShell console window
Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;

    public class WindowHelper {
        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();

        public const int SW_MAXIMIZE = 3;

        public static void MaximizeWindow() {
            IntPtr handle = GetForegroundWindow();
            ShowWindow(handle, SW_MAXIMIZE);
        }
    }
"@

# Call the MaximizeWindow function
[WindowHelper]::MaximizeWindow()

# Maxmize script ends



   
   cls
    For ($i = 0; $i -le 100; $i++) {
    Start-Sleep -Milliseconds 20
    Write-Progress -Activity "Counting to 100" -Status "Current Count: $i" -PercentComplete $i -CurrentOperation "Counting ..."
}
    # Check if the log name is the system log
    if ($eventLog.LogName -eq "System") {
        # Define the desired event IDs
        $desiredEventIDs = 1001, 1074, 6008, 41, 161
cls
        # Check if each event ID exists in the log
	Write-Host "**************************************************************************************************************************" -ForegroundColor Green
        Write-Host "*Event ID 1074 is an event ID that indicates the system has been shutdown by a process or a user                         *" -ForegroundColor Green
        Write-Host "*Event ID 6008 is an error that indicates that the system shut down unexpectedly                                         *" -ForegroundColor Green
	Write-Host "*Event ID 1001 is an error that the computer has rebooted from a bugcheck                                                *" -ForegroundColor Green
	Write-Host "*Event ID 41 is an error that indicates that some unexpected activity prevented Windows from shutting down correctly     *" -ForegroundColor Green
 	Write-Host "*      Some Event IDs will not have any messages due to your system not having the required components installed         *" -ForegroundColor Green
 	Write-Host "**************************************************************************************************************************" -ForegroundColor Green


        foreach ($eventID in $desiredEventIDs) {
            $foundEvent = $eventLog | Where-Object { $_.Id -eq $eventID }
            if ($foundEvent) {
                $foundEvent | Select-Object -Property TimeCreated, Id, ProviderName , Message | Format-Table -AutoSize
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
    $errorEvents = $eventLog | Where-Object { $_.LevelDisplayName -eq 'Error' -or $_.Level -eq '2' } | Select-Object -First $numberOfEvents

    # Check if any error events were found
    if ($errorEvents) {
        # Display the error events
        $errorEvents | Select-Object -Property TimeCreated, Id, ProviderName, Message | Format-Table -AutoSize
    } else {
        # No error events found
        Write-Host "No error events found in the selected log."
    }
} else {
    # Event log could not be read
    Write-Host "Couldn't access the specified event log."
}




# At the end of your script, check if the time zone was changed
if (-not $timeZoneChanged) {
    Write-Host "No changes were made to the time zone."
} else {
    # Revert to the original time zone
    Set-TimeZoneById -timeZoneId $originalTimeZone
    Write-Host "Time zone reverted to the original setting: $originalTimeZone"
}


