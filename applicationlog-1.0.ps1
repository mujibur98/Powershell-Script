# Load the Windows Forms assembly
Add-Type -AssemblyName System.Windows.Forms
cls

# Prompt the user to select an event log file
$eventLogPath = [System.Windows.Forms.OpenFileDialog]::new()
$eventLogPath.Title = "Select Event Log File"
$eventLogPath.Filter = "Event Log Files (*.evtx)|*.evtx"
$eventLogPath.Multiselect = $false

if ($eventLogPath.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
    # Read the event log file
    Write-Host "Downloading application log..."
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



    # Check if the log name is the application log

	Write-Host "**************************************************************************************************************************" -ForegroundColor Green
        Write-Host "*Event ID 1000 means you cannot launch this program properly or software may close unexpectedly.                         *" -ForegroundColor Green
        Write-Host "* App error may occur due to several reasons, including corrupted system files, badly installed & etc.                   *" -ForegroundColor Green
	Write-Host "*Event ID 1002 The indicated program stopped responding. The message contains details on which program stopped responding*" -ForegroundColor Green
	Write-Host "*Event ID 41 is an error that indicates that some unexpected activity prevented Windows from shutting down correctly     *" -ForegroundColor Green
	Write-Host "**************************************************************************************************************************" -ForegroundColor Green


    if ($eventLog.LogName -eq "Application") {
        # Define the desired event IDs
        $desiredEventIDs = 1000, 1002

        foreach ($eventID in $desiredEventIDs) {
            $foundEvent = $eventLog | Where-Object { $_.Id -eq $eventID -and ($_ | Select-Object -ExpandProperty ProviderName) -match "Application Hang|Application Error" }
            if ($foundEvent) {
                $foundEvent | Format-Table -AutoSize TimeCreated, Id, ProviderName, Message
            } else {
                Write-Host "Event ID $eventID not found."
            }
        }
    } else {
        Write-Host "Selected log is not the application log." -ForegroundColor Red
        # Exit with an error
        exit 1
    }
} else {
    Write-Host "No event log file selected." -ForegroundColor Green
    # Exit with an error
    exit 1
}

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

