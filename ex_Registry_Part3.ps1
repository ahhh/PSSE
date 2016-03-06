# Example by Nikhil Mittal : http://www.labofapenetrationtester.com/
# Make the fucntion call to Check-Macrosecurity from the script Registry-Part2.ps1

Invoke-Command -FilePath .\Registry_Part2.ps1 -ComputerName domainpc -Credential bharat\domainuser
