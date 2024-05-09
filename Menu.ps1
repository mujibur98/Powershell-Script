function DisplayMenu {
Clear-Host
Write-Host @"

SSSSSSSSSSSSSSSSSS   SSSSSSSSSSSSSSSSSS   SSSSSSSSSSSSSSSSS
SSSSSSSS             SSSSSSSS                     S
SSSSSSSSSSSSSSSSSS   SSSSSSSSSSSSSSSSSS           S
        SSSSSSSSSS           SSSSSSSSSS           S
SSSSSSSSSSSSSSSSSS   SSSSSSSSSSSSSSSSSS           S

+========================================================+
|  Troubleshooting Script - USER MENU                    | 
+========================================================+
|                                                        |
|    1) RDP - Disconnect                                 |
|    2) Driver Version                                   |
|    3) Cluster Port                                     |
|    4) Cluster DB Corruption Check                      |
|    5) RDP - Check port open                            |
|    6) Exit                                             |
|                                                        |       
+========================================================+
          Script written by MUJIBUR
"@


$MENU = Read-Host "OPTION"
Switch ($MENU)
{
1 {
#OPTION1 - RDP
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mujibur2024/Powershell-Script/main/RDP.PS1')
Start-Sleep -Seconds 60
DisplayMenu
}
2 {
#OPTION2 - Driver Version
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mujibur2024/Powershell-Script/main/driver-version.ps1')
Start-Sleep -Seconds 5
DisplayMenu
}
3 {
#OPTION3 - Cluster Port
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mujibur2024/Powershell-Script/main/Clusterport.ps1')
Start-Sleep -Seconds 5
DisplayMenu
}
4 {
#OPTION4 - Cluster DB Corruption Check 
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mujibur2024/Powershell-Script/main/check-cluster-db.ps1')
Start-Sleep -Seconds 5
DisplayMenu
}
5 {
#OPTION5 - RDP - Check port open    
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mujibur2024/Powershell-Script/main/check-cluster-db.ps1')
Start-Sleep -Seconds 5
DisplayMenu
}
6 {
#OPTION6 - EXIT
Write-Host "Bye"
Break
}
default {
#DEFAULT OPTION
Write-Host "Option not available"
Start-Sleep -Seconds 2
DisplayMenu
}
}
}
DisplayMenu


