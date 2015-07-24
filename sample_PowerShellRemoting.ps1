## PowerShell script for enabling (and disabling) PowerShell Remoting

#$COMPUTER = "This machine's fqdn, who whill be executing the PowerShell remoting commands"
#$USERNAME = "Username on $COMPUTER executing the remote commands"
#$REMOTECOMPUTER = "The machine's fqdn, who issuing the remote commands "

## check WinRM state
get-service winrm

## Enable WinRM
Enable-PSRemoting –force
## quick config
winrm quickconfig
## add specific trusted host
#winrm s winrm/config/client '@{TrustedHosts="REMOTECOMPUTER"}'
## or whitelist all as trusted hosts
#Set-Item wsman:\localhost\client\trustedhosts *
## restart WinRM
restart-service WinRM

## Disable WinRM
#Disable-PSRemoting -force
#Stop-Service winrm
#Set-Service -Name winrm -StartupType Disabled
#Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 0 -Type DWord

## Access this machine from a remote machine with:
#Test-WsMan $COMPUTER
#Enter-PSSession -ComputerName "COMPUTER" -credential "USERNAME"
## Run a remote command
#Invoke-Command -ComputerName $COMPUTER -ScriptBlock { COMMAND } -credential $USERNAME
