## Powershell function for quickly encoding a string
function Encode-Command
{

<#
.SYNOPSIS
PowerShell cmdlet for b64 encoding strings
.DESCRIPTION
this script is able to encode commands to run for PowerShell -Enc
.PARAMETER command
This is the string you want to base 64 encode
.EXAMPLE
PS C:\> Import-Module B64.ps1
PS C:\> Encode-Command -c "net user"
PS C:\> Powershell.exe -Enc bgBlAHQAIAB1AHMAZQByAA==
.LINK
https://github.com/ahhh/
http://lockboxx.blogspot.com/
.NOTES
EZ-Mode tool
#>

	[CmdletBinding()] Param(
	
		[Parameter(Mandatory = $true, ValueFromPipeline=$true)]
		[Alias("c", "command")]
		[String]
		$Commandz
	
	)

    # To use the -EncodedCommand parameter:
    $command = $Commandz
    $bytes = [System.Text.Encoding]::Unicode.GetBytes($command)
    $encodedCommand = [Convert]::ToBase64String($bytes)
    Write-Host $encodedCommand
    
}
