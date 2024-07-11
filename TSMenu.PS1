function DisplayMenu {
Clear-Host
Write-Host @"

                    
+========================================================+
|                  Inspector Gadget!      Version 1.33   | 
+========================================================+
|                                                        |
|    1) System Log For Reboot                            |
|    2) Application Log For Errors                       |
|    3) Check Server Up Time & Events Start-Ending Dates |
|    4) Exit                                             |
|                                                        |
|                                                        |       
+========================================================+
                 Script written by MUJIBUR
"@


$MENU = Read-Host "OPTION"
Switch ($MENU)
{
1 {
#OPTION1 - Check System Log For Reboot  
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mujibur2024/Powershell-Script/main/system-logs-1.3.2.ps1')
Break
DisplayMenu
}
2 {
#OPTION2 - Check Application Log Errors  
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mujibur2024/Powershell-Script/main/applicationlog-1.2.ps1')
Break
DisplayMenu
}
3 {
#OPTION3 - Check Server up time - Events Start-Ending Dates
Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/mujibur2024/Powershell-Script/main/uptime2.ps1')
Break
DisplayMenu
}

4 {
#OPTION4 - Exit
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


