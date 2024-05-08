# Get all cluster nodes
$clusterNodes = Get-ClusterNode
 
# Specify the UNC path to the CLUSDB file
$clusdbPath = "\\$($clusterNodes[0].Name)\C$\Windows\cluster\CLUSDB"
 
foreach ($node in $clusterNodes) {
    # Construct the UNC path for each node
    $nodeClusdbPath = "\\$($node.Name)\C$\Windows\cluster\CLUSDB"
 
    # Get the cluster file size (allocation unit size) in bytes
    $clusterSizeBytes = (Get-Item $nodeClusdbPath).Length
 
    # Convert bytes to kilobytes
    $clusterSizeKB = $clusterSizeBytes / 1024
 
    # Check if the cluster size is less than 256 KB
    if ($clusterSizeKB -lt 256) {
        Write-Host "Node $($node.Name): The CLUSDB file is corrupted (cluster size < 256 KB)."
    } else {
        Write-Host "Node $($node.Name): The CLUSDB file is not corrupted (cluster size >= 256 KB)."
    }
}