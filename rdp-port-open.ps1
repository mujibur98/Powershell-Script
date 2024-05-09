# Read the RDP port number from the registry
$RDPKeyPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp"
$RDPPortNumber = (Get-ItemProperty -Path $RDPKeyPath -Name "PortNumber").PortNumber

# Display the RDP port number
Write-Host "==========================================="
Write-Host "The RDP port number is: $RDPPortNumber"
Write-Host "==========================================="

# Check the open port status using netstat
$netstatOutput = netstat -ano | Select-String ":$RDPPortNumber"

# Display the netstat output
if ($netstatOutput) {
	
    Write-Host "==========================================="
    Write-Host "The port $RDPPortNumber is in the following state:"
    Write-Host "==========================================="
    Write-Host $netstatOutput
} else {
    Write-Host "==========================================================="
    Write-Host "The port $RDPPortNumber is not listed as open or listening."
    Write-Host "==========================================================="
}
