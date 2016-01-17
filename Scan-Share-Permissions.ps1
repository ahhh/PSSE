## Powershell For Penetration Testers Exam Task 2 - Enumerate all open shares on a network, noteing read and write access
function Scan-Share-Permissions
{

<#

.SYNOPSIS
PowerShell cmdlet to scan for open network shares with read and write access

.DESCRIPTION
this script is able to connect to varous network shares, and determine if there is anonymous read and write access. To use the Query Domain featue need Get-ADComputer cmdlet. By default, with no command line flags, it will run against localhost

.PARAMETER IPList
A file which contains IPs and hostnames on new lines to scan

.PARAMETER TargetHost
Use this switch to scan a single host for readable and writable shares

.PARAMETER QueryDomain
Use this switch to query the domain for all hosts, then check all hosts for open shares and thier permissions. This switch will override a TargetHost

.EXAMPLE
PS > Scan-Share-Permissions

.Example
PS > Scan-Share-Permissions -TargetHost 192.168.1.4

.Example
PS > Scan-Share-Permissions -IPList IPs.txt

.EXAMPLE 
PS > Scan-Share-Permissions -QueryDomain

.LINK
https://github.com/ahhh/PSSE/blob/master/scan-share-permissions.ps1
http://lockboxx.blogspot.com/2016/01/scan-share-permissions-powershell-for.html
https://4sysops.com/archives/find-shares-with-powershell-where-everyone-has-full-control-permissions/
https://gallery.technet.microsoft.com/scriptcenter/List-Share-Permissions-83f8c419
http://www.techexams.net/forums/off-topic/51839-script-check-open-shares-folders-network.html
https://technet.microsoft.com/en-us/library/ee617192.aspx

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3061

#>

	[CmdletBinding()] Param(
		
		# Defaults to local
		[Parameter(Mandatory = $false)]
		[String]
		$TargetHost = '.',
		
		# Defaults to false, not all machines have Get-ADComputer
		[Parameter(Mandatory = $false)]
		[String]
		$QueryDomain = $false,
		
		# A List of IPs to scan against, you can use other powershell cmdlets to easily generate IP lists
		
		[Parameter(Mandatory = $false)]
		[String]
		$IPList = $null
		
	)
	
	function Explore-Shares-Security($TargetHost)	
	{
		try
		{
			# Gets the shares list
			$shares = gwmi -Class win32_share -ComputerName $TargetHost | select -ExpandProperty Name  
		}
		catch
		{
			Write-Host "Unable to connect to any shares on $TargetHost"  -ForegroundColor Red  
			$shares = $null
		}
	
		foreach ($share in $shares) 
		{  
			# Highlight shares discovered in green
			$ACL = $null  
			Write-Host $share -ForegroundColor Green  
			Write-Host $('-' * $share.Length) -ForegroundColor Green  
			
			# Get the Security Settings of the share
			$objShareSec = Get-WMIObject -Class Win32_LogicalShareSecuritySetting -Filter "name='$Share'"  -ComputerName $TargetHost 
		
			try 
			{  
				# Parse the Security Settings
				$SD = $objShareSec.GetSecurityDescriptor().Descriptor    
				foreach($ace in $SD.DACL)
				{				
					$UserName = $ace.Trustee.Name      
					If ($ace.Trustee.Domain -ne $Null) {$UserName = "$($ace.Trustee.Domain)\$UserName"}    
					If ($ace.Trustee.Name -eq $Null) {$UserName = $ace.Trustee.SIDString } 
					# Special check to see if share has extreamly insecure security permissions
					if ($ace.Trustee.Name -eq "EveryOne" -and $ace.AccessMask -eq "2032127" -and $ace.AceType -eq 0) {$UserName = "**EVERYONE** with Insecure Perms"}
					# Build our final array of permissions
					[Array]$ACL += New-Object Security.AccessControl.FileSystemAccessRule($UserName, $ace.AccessMask, $ace.AceType)  
				}            
			}  
			catch  
			{ 
				Write-Host "Unable to obtain permissions for $share" 
			}  
			# Print our final ACL array for this share
			$ACL  
			Write-Host $('=' * 50)  
			Write-Host $('') 
		} # Loop foreach share 
	}				

	# Run Time down here!
	if ($QueryDomain -eq $True) 
	{
		$Servers = ( Get-ADComputer -Filter { DNSHostName -Like '*' }  | Select -Expand Name )
		foreach ($Server in $Servers)
		{
			Write-Host "Scanning $Server" -ForegroundColor Green
			Explore-Shares-Security($Server)
		}
	}
	elseif ($IPList)
	{
		$IPs = Get-Content $IPList
		foreach ($Server in $IPs)
		{
			Write-Host "Scanning $Server" -ForegroundColor Green  
			Explore-Shares-Security($Server)
		}
	}
	else
	{
		Write-Host "Scanning $TargetHost" -ForegroundColor Green
		Explore-Shares-Security($TargetHost)
	}
}
