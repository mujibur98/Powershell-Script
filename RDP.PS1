cls
Write-Host "====================================================================================================================================="
Write-Host "Reason Code 0 (No additional information is available) User has just closed the RDP client window."

Write-Host "Reason Code 2 is similar to code 11; it is logged when an administrative tool was used to disconnect the session from another session."

Write-Host "Reason Code 5 (The client’s connection was replaced by another connection) User has reconnected to the previous RDP session."

Write-Host "Reason Code 11 (User activity has initiated the disconnect) User has clicked the Disconnect button in the start menu."

Write-Host "Reason Code 12 is registered when the disconnection was initiated by the user logging off their session on the machine."
Write-Host "====================================================================================================================================="


Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-TerminalServices-LocalSessionManager/Operational'
    ID = 40
} -MaxEvents 10 | Format-Table -wrap


Get-WinEvent -FilterHashtable @{
    LogName = 'Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational'
    ID = 1149 , 1179
} -MaxEvents 10 | Format-Table -wrap