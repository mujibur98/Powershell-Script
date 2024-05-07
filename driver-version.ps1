# Define a list of vendors
$vendors = @("mellanox", "broadcom", "intel", "qlogic", "Intel(R) Gigabit", "Dell")

# Loop through each vendor
foreach ($vendor in $vendors) {
  # Query for devices with the current vendor
  $vendorInfo = Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.DeviceName -like "*$vendor*" } | Select-Object DeviceName, DriverVersion, Manufacturer

  # Check if any information was found
  if ($vendorInfo.Count -gt 0) {
    # Display information for the vendor
    Write-Host "**$vendor Devices:**"
    $vendorInfo | Format-Table -AutoSize
  }
}





