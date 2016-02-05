function Send-File-PSRemoting
{ 
<#
.SYNOPSIS
A cmdlet to let one quickly transfer a file between machines on the local network via PowerShell Remoting

.DESCRIPTION
A cmdlet to let one quickly transfer a file between machines on the local network via PowerShell Remoting

.PARAMETER LocalFile
The localfile you wish to transfer to the remote machine using PowerShell Remoting. -l or -f for short

.PARAMETER Computer
The remote computer you wish to send the file to via PowerShell Remoting. -c for short

.PARAMETER Destination
The filepath you wish to transfer the file to on the remote machine. -d or -p for short

.PARAMETER User
The user to auth to the remote machine as via PowerShell Remoting. -u for short

.EXAMPLE
PS C:\> Import-Module Send-File-PSRemoting.ps1
PS C:\> Send-File-PSRemoting 

.EXAMPLE
Another method is like follows:
Copy-Item -Path \\serverb\c$\Users\user\test.txt -Destination \\servera\c$\Users\user\test.txt;
In this case serverb can be either remote (to copy from remote to local) or local (to copy from local to remote)

.LINK
https://github.com/ahhh/PSSE/blob/master/Send-File-PSRemoting.ps1
http://serverfault.com/questions/674673/transfer-files-via-powershell-remoting-like-scp-in-linux

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3061

#>           
	[CmdletBinding()] Param( 

		[Parameter(Mandatory = $true, ValueFromPipeline=$true)]
		[Alias("l", "f", "local", "file")]
		[String]
		$LocalFile,
		
		[Parameter(Mandatory = $true)]
		[Alias("d", "p", "dest")]
		[String]
		$Destination,
		
		[Parameter(Mandatory = $true)]
		[Alias("c")]
		[String]
		$Computer,
		
		[Parameter(Mandatory = $true)]
		[Alias("u", "creds", "Credentials")]
		[String]
		$User

	)


	$Session = New-PSSession -ComputerName $Computer -Credential $User 
	# Option for TLS vs Kerb: -UseSsl

	$FileContents = Get-Content -Path $LocalFile

	Invoke-Command -Session $Session -ScriptBlock {
  param($FilePath,$data)
    
    	Set-Content -Path $FilePath -Value $data

	} -ArgumentList $Destination,$FileContents

 }
