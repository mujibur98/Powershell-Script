function DisplayMenu {
Clear-Host
Write-Host @"

                    
+========================================================+
|                  Inspector Gadget!                     | 
+========================================================+
|                                                        |
|    1) Check system log for reboot                      |
|    2) Exit                                             |
|                                                        |
|                                                        |
|                                                        |       
+========================================================+
                 Script written by MUJIBUR
"@


$MENU = Read-Host "OPTION"
Switch ($MENU)
{
1 {
#OPTION1 - Check system log for reboot  
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mujibur2024/Powershell-Script/main/System-logs-1.1.ps1')
Break
DisplayMenu
}
2 {
#OPTION2 - Exit
exit
DisplayMenu
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

