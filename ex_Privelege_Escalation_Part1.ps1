# Example by Nikhil Mittal : http://www.labofapenetrationtester.com/
(Get-WmiObject win32_service).pathname | Select-String -NotMatch "C:\\windows" | Select-String " " | Select-String -notmatch "`""
