function Scan-Dir-Permissions
{ 
<#
.SYNOPSIS
A cmdlet to quickly audit the security permissions of arbitrary and security related directories. 

.DESCRIPTION
This script can return the owner, group, and detailed security permissions of directories, as well as the details of other folders, recursivly nested. It also has some special functions to scan directories known for dll search order highjacking, in an effort to priv esc. So far these are Sys32 and Path directories.  Also has alerting for easier detection of insecure configurations, "Everyone" + "Write". 

.PARAMETER Dir
The arbitrary directory we are going to list permissions for. -d for short

.PARAMETER PathScan
A specialized scan that gets the security permissions of the folders in the current user's $PATH. -p for short

.PARAMETER Sys32Scan
A specialized scan that gets the security permissions of the folders in the C:\Windows\System32\ directory. -s for short

.PARAMETER Recurse
Recursivly enumerate directories under the arbitrary one. -r for short

.PARAMETER Alert
Will only output directories with Write access for Everyone. -a for short

.EXAMPLE
PS C:\> Import-Module Scan-Dir-Permissions.ps1
PS C:\> Scan-Dir-Permissions -Dir "C:\Users\user\Desktop\"
PS C:\> Scan-Dir-Permissions -Sys32Scan True -Recurse True
PS C:\> Scan-Dir-Permissions -p True -r True
PS C:\> Scan-Dir-Permissions -d "C:\Users\user\example\" -a True

.LINK
http://lockboxx.blogspot.com/2016/01/scan-dir-permissions-powershell-for.html
https://github.com/ahhh/PSSE/edit/master/Scan-Dir-Permissions.ps1
https://digital-forensics.sans.org/blog/2015/03/25/detecting-dll-hijacking-on-windows/
https://akhpark.wordpress.com/2013/03/28/how-to-check-the-directory-permission-recursively/
https://phyllisinit.wordpress.com/2012/03/14/extracting-folder-and-subfolder-security-permission-properties-using-powershell/

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3061

#>           
	[CmdletBinding()] Param( 

		[Parameter(Mandatory = $false, ValueFromPipeline=$true)]
		[Alias("d", "directory")]
		[String]
		$dir = '.',
		
		[Parameter(Mandatory = $false)]
		[Alias("r")]
		[String]
		$recurse = $False,
		
		[Parameter(Mandatory = $false)]
		[Alias("p", "path")]
		[String]
		$pathScan = $False,
		
		[Parameter(Mandatory = $false)]
		[Alias("s", "sys32")]
		[String]
		$Sys32Scan = $False,

		[Parameter(Mandatory = $false)]
		[Alias("a")]
		[String]
		$alert = $False

	)

	function alertTime($results)
	{
		$results | Select-String "Users" | Select-String "Write" | Write-Host -ForegroundColor Red
	}

	if ($pathScan -eq $True)
	{
		# Fetch all the directories in the current user's path
		$Paths = (Get-Item Env:Path).value.split(';') | Where-Object {$_ -ne ""}
		if ($recurse -eq $True)
		{
			foreach($path in $Paths)
			{
				$results = get-childitem $path -recurse | where-object {($_.PsIsContainer)} | get-acl  | select-object path,owner,group,accesstostring
				if ($alert -eq $true)
				{
				    alertTime($results)
				}
				else
				{
				    $results | format-list
				}
			}
		}
		else
		{
			foreach($path in $Paths)
			{
				$results = get-childitem $path | where-object {($_.PsIsContainer)} | get-acl  | select-object path,owner,group,accesstostring
				if ($alert -eq $true)
				{
				    alertTime($results)
				}
				else
				{
				    $results | format-list
				}
			}
		}
	}
	elseif ($Sys32Scan -eq $True)
	{
		if ($recurse -eq $True) 	
		{
			$results = get-childitem "C:\Windows\system32\" -recurse | where-object {($_.PsIsContainer)} | get-acl  | select-object path,owner,group,accesstostring
			if ($alert -eq $true)
			{
			    alertTime($results)
			}
			else
			{
			    $results | format-list
			}
		}
		else
		{
			$results = get-childitem "C:\Windows\system32\" | where-object {($_.PsIsContainer)} | get-acl  | select-object path,owner,group,accesstostring
			if ($alert -eq $true)
			{
			    alertTime($results)
			}
			else
			{
			    $results | format-list
			}
		}
	}
	else # Our default case, an arbitrary direcrory scan, which also defaults to the current working directory
	{
		if ($recurse -eq $True)
		{
			$results = get-childitem $dir -recurse | where-object {($_.PsIsContainer)} | get-acl  | select-object path,owner,group,accesstostring
			if ($alert -eq $true)
			{
				alertTime($results)
			}
			else
			{
				$results | format-list
			}
		}
		else
		{
			$results = get-childitem $dir | where-object {($_.PsIsContainer)} | get-acl  | select-object path,owner,group,accesstostring
			if ($alert -eq $true)
			{
				alertTime($results)
			}
			else
			{
				$results | format-list
			} 
		}
	}
 }
