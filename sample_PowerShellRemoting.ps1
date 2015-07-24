# PowerShell script for enabling (and disabling) PowerShell Remoting

# check it
get-service winrm

# Enable it
Enable-PSRemoting –force
# quick config
winrm quickconfig
# add trusted host
winrm s winrm/config/client '@{TrustedHosts="RemoteComputer"}'

# Disable it
#Disable-PSRemoting -force
#Stop-Service winrm
#Set-Service -Name winrm -StartupType Disabled
#Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System -Name LocalAccountTokenFilterPolicy -Value 0 -Type DWord
