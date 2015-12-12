#Save page
<#
$servers = "google.com", "yahoo.com"
foreach ($server in $servers) 
{
    $Page = Invoke-WebRequest -Uri http://$server
    Out-File -InputObject $Page.Content -FilePath "$PWD\$server.html"

}
#>


#Load the Get-HttpStatus function in memory before using below
$servers = "C:\test\servers.txt"

foreach ($server in $servers)
{
    Get-HttpStatus -Target $server -Path c:\test\dictionary.txt -UseSSL
}