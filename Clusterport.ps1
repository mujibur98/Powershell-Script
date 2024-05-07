$clusternode = Get-ClusterNode
$ports = @(135, 445, 139, 3343)
 
foreach ($node in $clusternode) {
    foreach ($port in $ports) {
        $tcpclient = New-Object System.Net.Sockets.TcpClient
        try {
            $tcpclient.Connect($node, $port)
            if ($tcpclient.Connected) {
                Write-Host "Port $port on $($node.Name) is open."
            }
            $tcpclient.Close()
        } catch {
            Write-Host "Port $port on $($node.Name) is closed or not reachable."
        }
    }
}