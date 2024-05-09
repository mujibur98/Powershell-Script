# Define the path to the directory containing the dump files
$dumpFilesPath = "C:\windows"
# Define the total memory size in MB 
$totalMemorySize = Get-WmiObject -Class Win32_ComputerSystem | Select-Object -ExpandProperty TotalPhysicalMemory
$totalMemorySizeMB = [math]::Round($totalMemorySize / 1MB)

# Get all dump files in the directory
$dumpFiles = Get-ChildItem -Path $dumpFilesPath -Filter "*.dmp"

# Check each dump file and determine its type based on size
foreach ($file in $dumpFiles) {
    $size = $file.Length / 1MB # Size in MB
    $type = $null

    if ($size -lt 10) {
        $type = "Mini Dump"
    } elseif ($size -ge 10 -and $size -lt $totalMemorySizeMB) {
        $type = "Kernel Dump"
    } elseif ($size -eq $totalMemorySizeMB) {
        $type = "Full Dump"
    } else {
        $type = "Unknown"
    }

    # Get the creation date of the file
    $date = $file.CreationTime

    Write-Host "File: $($file.Name) is a $type file and was created on $date."
}