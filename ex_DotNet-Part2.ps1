# Example by Nikhil Mittal : http://www.labofapenetrationtester.com/
$DNSClass = [AppDomain]::CurrentDomain.GetAssemblies() | ForEach-Object {$_.GetTypes()}| where {$_.IsPublic -eq "True"} | where {$_.Name -eq "DNS"}
$DNSClass | Get-Member -Static
$DNSClass::GetHostByName("labofapenetrationtester.com")
