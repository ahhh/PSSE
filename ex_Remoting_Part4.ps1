Get-ChildItem C:\test\*.txt, C:\test\*.xml | Select-String "password","Credential"

#Invoke-Command -ScriptBlock {Get-ChildItem C:\test\*.txt, C:\test\*.xml | Select-String "password","Credential"} -ComputerName (Get-Content <listofservers.txt>)