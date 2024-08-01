# Get the BIOS manufacturer
$biosManufacturer = (Get-WmiObject win32_bios).Manufacturer

# Check if the manufacturer is Dell
if ($biosManufacturer -ne "Dell Inc.") {
    Write-Output " Verification failed not Dell System. Exiting script." 
    exit
}

Write-Output "Verifying Dell System...." 

Start-Sleep -s 5
clear-host

Write-Host "******************************Ping Cluster Node to DC ******************************" 
# Get all cluster nodes
$clusterNodes = Get-ClusterNode

# Loop through each cluster node
foreach ($node in $clusterNodes) {
    Write-Output "Processing node: $($node.Name)"
    
    # Enter PSSession to the node
    $session = New-PSSession -ComputerName $node.Name

    # Get BIOS Serial Number
    $bios = Invoke-Command -Session $session -ScriptBlock { Get-WmiObject -Class Win32_BIOS | Select-Object SerialNumber }
    Write-Output "Node: $($node.Name) - Service Tag: $($bios.SerialNumber)"

    # Get Computer System information
    $computerSystem = Invoke-Command -Session $session -ScriptBlock { Get-CimInstance -ClassName Win32_ComputerSystem }
    Write-Output "Node: $($node.Name) - Computer Name: $($computerSystem.Name)"
    Write-Output "Node: $($node.Name) - Domain: $($computerSystem.Domain)"
    Write-Output "Node: $($node.Name) - Model: $($computerSystem.Model)"

    # Ping the domain from the node
    $pingResult = Invoke-Command -Session $session -ScriptBlock {
        param ($domain)
        Test-Connection -ComputerName $domain -Count 1 -Quiet
    } -ArgumentList $computerSystem.Domain

    if ($pingResult) {
        Write-Output "Node: $($node.Name) - Domain $($computerSystem.Domain) is reachable"
    } else {
        Write-Output "Node: $($node.Name) - Domain $($computerSystem.Domain) is not reachable"
    }

    # Close the PSSession
    Remove-PSSession -Session $session
}




Write-Host "******************************Ping Cluster Nodes******************************" 

foreach ($sourceNode in $clusterNodes) {
    foreach ($targetNode in $clusterNodes) {
        if ($sourceNode.Name -ne $targetNode.Name) {
            Enter-PSSession -ComputerName $sourceNode.Name
            try {
                $pingResult = Test-Connection -ComputerName $targetNode.Name -Count 1
                if ($pingResult.StatusCode -eq 0) {
                    Write-Host "Ping to $($targetNode.Name) from $($sourceNode.Name) succeeded." -ForegroundColor Green
                } else {
                    Write-Host "Ping to $($targetNode.Name) from $($sourceNode.Name) failed." -ForegroundColor Red
                }
            } catch {
                Write-Host "Ping to $($targetNode.Name) from $($sourceNode.Name) failed with error: $_" -ForegroundColor Red
            }
            Exit-PSSession
        }
    }
}


Write-Host "******************************Cluster Nodes Open Ports******************************" 
$ports = @(135, 445, 139, 3343)
foreach ($node in $clusternodes) {
    foreach ($port in $ports) {
        $tcpclient = New-Object System.Net.Sockets.TcpClient
        try {
            $tcpclient.Connect($node, $port)
            if ($tcpclient.Connected) {
                Write-Host "Port $port on $($node.Name) is open." -ForegroundColor Green
            }
            $tcpclient.Close()
        } catch {
            Write-Host "Port $port on $($node.Name) is closed or not reachable." -ForegroundColor Red
        }
    }
}

# Specify the UNC path to the CLUSDB file
$clusdbPath = "\\$($clusterNodes[0].Name)\C$\Windows\cluster\CLUSDB"
Write-Host "******************************Cluster Nodes Clusdb Status******************************" 
foreach ($node in $clusterNodes) {
    # Construct the UNC path for each node
    $nodeClusdbPath = "\\$($node.Name)\C$\Windows\cluster\CLUSDB"
 
    # Get the cluster file size (allocation unit size) in bytes
    $clusterSizeBytes = (Get-Item $nodeClusdbPath).Length
 
    # Convert bytes to kilobytes
    $clusterSizeKB = $clusterSizeBytes / 1024
 
    # Check if the cluster size is less than 256 KB
    if ($clusterSizeKB -lt 256) {
        Write-Host "Node $($node.Name): The CLUSDB file is corrupted (cluster size < 256 KB)."  -ForegroundColor Red
    } else {
        Write-Host "Node $($node.Name): The CLUSDB file is not corrupted (cluster size >= 256 KB)." -ForegroundColor Green
    }
}



# Loop through each node
Write-Host "******************************Checking Cluster services******************************" 
foreach ($node in $clusterNodes) {
  # Get the Cluster Service status on the current node
  $clusterService = Get-Service -ComputerName $node.Name -Name clussvc

  # Check the service status
  if ($clusterService.Status -eq "Running") {
    Write-Host "Cluster Service is running on node: $($node.Name)" -ForegroundColor Green
  } else {
    Write-Warning "Cluster Service is NOT running on node: $($node.Name)" -ForegroundColor Red
  }
}



# Get all cluster nodes

Write-Host "******************************Host Hardware Driver Version******************************" 
# Define a list of vendors
$vendors = @("mellanox", "broadcom", "Intel(R) C620 series chipset SPI", "qlogic", "Matrox", "Marvell Semiconductor Inc", "Dell Corporation", "Intel(R) Gigabit","Intel(R) Ethernet")

# Create an empty array to store the results
$comparisonTable = @()

# Loop through each cluster node
foreach ($node in $clusterNodes) {
    Write-Host "Checking node: $($node.Name)"
    # Loop through each vendor
    foreach ($vendor in $vendors) {
        # Query for devices with the current vendor
        $vendorInfo = Invoke-Command -ComputerName $node.Name -ScriptBlock {
            param($vendor)
            Get-WmiObject Win32_PnPSignedDriver | Where-Object { $_.DeviceName -like "*$vendor*" } | Select-Object DeviceName, DriverVersion, Manufacturer
        } -ArgumentList $vendor

        # Add the results to the comparison table
        foreach ($info in $vendorInfo) {
            $comparisonTable += New-Object PSObject -Property @{
                NodeName = $node.Name
                DeviceName = $info.DeviceName
                DriverVersion = $info.DriverVersion
            }
        }
    }

    # Find the most common driver version for each device on the current node
    $groupedResults = $comparisonTable | Where-Object { $_.NodeName -eq $node.Name } | Group-Object DeviceName
    foreach ($group in $groupedResults) {
        $mostCommonVersion = ($group.Group | Group-Object DriverVersion | Sort-Object Count -Descending | Select-Object -First 1).Name
        foreach ($item in $group.Group) {
            $color = if ($item.DriverVersion -eq $mostCommonVersion) { "Green" } else { "Red" }
            Write-Host "Node: $($item.NodeName), Device: $($item.DeviceName), Driver Version: $($item.DriverVersion)" -ForegroundColor $color
        }
    }
}


# Display the comparison table (When nessary only else ignore it)


#$comparisonTable | Format-Table -Property NodeName, DeviceName, DriverVersion (enable when want to change the format)


# Define an empty hashtable to store the reference properties from the first node
$referenceProperties = @{}
$firstNode = $true

Write-Host "******************************OS Version******************************" 
# Loop through each node and get the required information
foreach ($node in $clusterNodes) {
    # Use Invoke-Command to run Get-ComputerInfo on the remote node
    $nodeInfo = Invoke-Command -ComputerName $node.Name -ScriptBlock {
        # Retrieve information
        Get-ComputerInfo -Property BiosSMBIOSBIOSVersion,OsVersion,OSDisplayVersion
    }
    
    # If it's the first node, populate the reference properties
    if ($firstNode) {
        $referenceProperties = @{
            BiosSMBIOSBIOSVersion = $nodeInfo.BiosSMBIOSBIOSVersion
            OsVersion = $nodeInfo.OsVersion
            OSDisplayVersion = $nodeInfo.OSDisplayVersion
        }
        $firstNode = $false
    }
    
    # Output the node name
    Write-Host "Node: $($node.Name)"
    
    # Compare each property and output in green if it matches the reference, else in red
    foreach ($property in $referenceProperties.Keys) {
        if ($nodeInfo.$property -eq $referenceProperties[$property]) {
            Write-Host "${property}: $($nodeInfo.$property)" -ForegroundColor Green
        } else {
            Write-Host "${property}: $($nodeInfo.$property) (Mismatch)" -ForegroundColor Red
        }
    }
}



# Function to get installed updates from a node


function Get-InstalledUpdates {
    param (
        [string]$computerName
    )

    $Session = New-PSSession -ComputerName $computerName
    $hotfixes = Invoke-Command -Session $Session -ScriptBlock { Get-HotFix }
    Remove-PSSession -Session $Session

    return $hotfixes
}

# Compare updates between nodes
$allUpdates = @{}
foreach ($node in $clusterNodes) {
    $nodeName = $node.Name
    $updates = Get-InstalledUpdates -computerName $nodeName
    $allUpdates[$nodeName] = $updates
}

# Find missing updates
$comparisonResults = @{}
foreach ($node in $clusterNodes) {
    $nodeName = $node.Name
    $nodeUpdates = $allUpdates[$nodeName]
    $missingUpdates = @()
#Write-Host "********************Microsoft KB each nodes******************************" 
    foreach ($comparisonNode in $clusterNodes) {
        if ($comparisonNode -ne $node) {
            $comparisonNodeName = $comparisonNode.Name
            $comparisonNodeUpdates = $allUpdates[$comparisonNodeName]

            # Compare the updates
            $compareResult = Compare-Object -ReferenceObject $nodeUpdates -DifferenceObject $comparisonNodeUpdates -Property HotFixID

            # Find updates that are missing on the current node
            $missing = $compareResult | Where-Object { $_.SideIndicator -eq '<=' }
            $missingUpdates += $missing
        }
    }

    $comparisonResults[$nodeName] = $missingUpdates
}

# Output results
foreach ($result in $comparisonResults.GetEnumerator()) {
    $nodeName = $result.Key
    $missingUpdates = $result.Value

    Write-Host "Node: $nodeName"
    if ($missingUpdates.Count -eq 0) {
        Write-Host "No missing updates."
    } else {
        Write-Host "Missing updates:"
        $missingUpdates | ForEach-Object { Write-Host $_.HotFixID -ForegroundColor Red }
    }
}



