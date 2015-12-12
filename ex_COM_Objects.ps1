$ie = New-Object -ComObject InternetExplorer.Application
$ie.Visible = $False #Default is false
$ie.Navigate("http://google.com")

<#
$shell = New-Object -ComObject shell.application
$shell | Get-Member
#>