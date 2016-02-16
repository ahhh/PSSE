function Scan-with-Yara
{

<#
.SYNOPSIS
Powershell Cmdlet that allows for the ability to pass the file name of the binary into the YARA rules to as a paramater called Filename. Also allows for the ability to specify arbitrary directories and scan directories recursivly
.DESCRIPTION
Powershell Cmdlet that allows for the ability to pass the file name of the binary into the YARA rules to as a paramater called Filename. Also allows for the ability to specify arbitrary directories and scan directories recursivly
.PARAMETER Directory
The directory to scan the binaries within with the select YARA rules. Can also use -dir or -d for short. 'C:\Windows\' by default.
.PARAMETER YaraRule
The yara rule to run the binaries against. Passes the name if the file into the rule as a variable called Filename. Can also use -yara, -y, or -rule for short.
.PARAMETER Recurse
a switch to recursivly analyze binaries in the directory folder, -R for short
.EXAMPLE
PS C:\> Import-Module Scan-with-Yara
PS C:\> Scan-with-Yara -d 'C:\Users\user\' -y '.\rules\custom_rule.yara' -R
PS C:\> Scan-with-Yara -R 
.LINK
https://github.com/ahhh/PSSE/blob/master/Scan-with-Yara.ps1
https://www.bsk-consulting.de/2014/08/28/scan-system-files-manipulations-yara-inverse-matching-22/
.NOTES
Requires the yara32.exe in the folder you are exectuing. also has a default for '.\rules\inverse-matching.yar' as described in Florian's orginal link.
I set the script up in a directory called YARA, with the yara32.exe, with a subdirectory called '.\rules\' which I then import rules into
Inspired by Florian Roth
Adopted by ahhh

#>

	[CmdletBinding()] Param(
	
		[Parameter(Mandatory = $false, ValueFromPipeline=$true)]
		[Alias("dir", "d")]
		[String]
		$Directory = 'C:\Windows\',
		
		[Parameter(Mandatory = $false)]
		[Alias("yara", "y", "rule")]
		[String]
		$YaraRule = '.\rules\inverse-matching.yar',
		
		[Parameter(Mandatory = $false)]
		[Alias("R")]
		[Switch]
		$Recurse = $False
	
	)
	
	if($Recurse)
	{
		Get-ChildItem -Recurse -filter *.exe $Directory 2> $null | ForEach-Object { 
			Write-Host -foregroundcolor "green" "Scanning"$_.FullName $_.Name; 
			./yara32.exe -d filename=$_.Name $YaraRule $_.FullName 2> $null 
		}
	}else{
		Get-ChildItem -filter *.exe $Directory 2> $null | ForEach-Object { 
			Write-Host -foregroundcolor "green" "Scanning"$_.FullName $_.Name; 
			./yara32.exe -d filename=$_.Name $YaraRule $_.FullName 2> $null 
		}
	}

}
