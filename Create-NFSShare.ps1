## Powershell function for quickly setting up an NFS Share
function Create-Share
{

<#
.SYNOPSIS
Quick script for setting up NFS Shares
.DESCRIPTION
PowerShell cmdlet for quickly creating NFS Shares, works on Windows Server, uses port 111
.PARAMETER ShareDir
This is the local folder to share on the network
.PARAMETER ShareName
This is the name of the share being hosted on the machine
.EXAMPLE
PS C:\> Import-Module Create-NFSShare.ps1
PS C:\> Create-Share -name "NFSShare" -dir "C:\MyFiles"
PS C:\> Create-Share -n "NFSShare" -d "C:\MyFiles"
.LINK
https://github.com/ahhh/
http://lockboxx.blogspot.com/
https://superwidgets.wordpress.com/2014/07/07/powershell-script-to-setup-nfs-share-on-server-2012-r2/
.NOTES
Setting up an NFS share on Windows Server
#>

	[CmdletBinding()] Param(
	
		[Parameter(Mandatory = $true)]
		[Alias("n", "name")]
		[String]
		$ShareName,

		[Parameter(Mandatory = $true)]
		[Alias("d", "dir")]
		[String]
		$ShareDir		
	
	)

	Try {
		Import-Module ServerManager
		Add-WindowsFeature FS-NFS-Service
		Import-Module NFS
		New-NfsShare -name $ShareName -Path $ShareDir 
		Write-Output "NFS Share can be accessed at $([system.environment]::MachineName + '/' + $ShareName)"

	} Catch {
		Write-Output "Error creating the NFS Share!! Abort! Abort!"
	}

}
