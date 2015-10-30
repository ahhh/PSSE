# Sample script for pulling windows security related event logs, largly inspired by similar functions via: https://github.com/obscuresec/PowerShell

echo "Looking for PSExec Service Events."
$PSExecService = (Get-Eventlog -LogName "system" | Where-Object {$_.EventID -eq 7045} | Where-Object {$_.Message -like "*PSExec*"})
    
$PSExecService | Foreach-Object {
    $User = $_.UserName
    $Time = $_.TimeGenerated
    $Host = $_.MachineName
        
    $ObjectProps = @{'Host' = $Host;
                     'User' = $User;
                     'Time' = $Time;}
        
    $Results = New-Object -TypeName PSObject -Property $ObjectProps
    Write-Output $Results
}

echo "Looking for MSF PSExec Service Events."
$MSFService = (Get-Eventlog -LogName "system" | Where-Object {$_.EventID -eq 7045} | Where-Object {($_.Message -match "Service Name:  M")} | Where-Object {($_.Message -like "*%SYSTEMROOT%\????????.exe*")})
    
$MSFService | Foreach-Object {
    $User = $_.UserName
    $Time = $_.TimeGenerated
    $Host = $_.MachineName
        
    $ObjectProps = @{'Host' = $Host;
                     'User' = $User;
                     'Time' = $Time;}
        
    $Results = New-Object -TypeName PSObject -Property $ObjectProps
    Write-Output $Results
}


echo "Looking for WinExe Service Events."
$WinExeService = (Get-Eventlog -LogName "system" | Where-Object {$_.EventID -eq 7045} | Where-Object {$_.Message -like "*winexesvc*"})
    
$WinExeService | Foreach-Object {
    $User = $_.UserName
    $Time = $_.TimeGenerated
    $Host = $_.MachineName
        
    $ObjectProps = @{'Host' = $Host;
                     'User' = $User;
                     'Time' = $Time;}
        
    $Results = New-Object -TypeName PSObject -Property $ObjectProps
    Write-Output $Results
}

#Check for Administrator rights
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    echo "Not running as Administrator. Run the script with elevated credentials to run further checks."
    Return
}

echo "Looking for NTLM Network Logons."
$Filter = "*[EventData[Data = 'NtLmSsp ']]"
$NTLMEvents = Get-WinEvent -Logname "security" -FilterXPath $Filter | Where-Object {$_.ID -eq 4624}
if ($NTLMEvents) {$NTLMEvents | ForEach-Object {
            
        $ObjectProps = @{'Host' = $_.Properties[11].value;
                         'IPAddress' = $_.Properties[18].value;
                         'User' = $_.Properties[5].value;
                         'Domain' = $_.Properties[6].value;
                         'Time' = $_.TimeCreated;
                         'Workstation' = $_.MachineName}
            
        $Results = New-Object -TypeName PSObject -Property $ObjectProps
        Write-Output $Results                                      
    }         
}

echo "Looking for Interactive (Type2) Logons."
$Logons = (Get-winevent -max 1000 -FilterHashtable @{logname='security'; id=4624;}  | where {$_.properties[8].value -eq 2})

$Logons | Foreach-Object {
    $Time = $_.TimeCreated
    $Message = $_.Message
        
    $ObjectProps = @{'Message' = $Message;
                     'Time' = $Time;}
        
    $Results = New-Object -TypeName PSObject -Property $ObjectProps
    Write-Output $Results
}

