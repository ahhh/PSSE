# Example by Nikhil Mittal : http://www.labofapenetrationtester.com/
# Using loop
foreach ($proc in $procs) {$proc.path}

#Without Loop
(Get-Process).path
