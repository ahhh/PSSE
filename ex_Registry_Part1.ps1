# Example by Nikhil Mittal : http://www.labofapenetrationtester.com/
#Get the TypedURLs
Get-ItemProperty "hkcu:\software\microsoft\internet explorer\typedurls"

#Installed Softwares
(Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*).DisplayName
Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object -ExpandProperty DisplayName
