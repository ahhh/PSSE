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
https://blogs.msdn.microsoft.com/timid/2014/03/26/powershell-encodedcommand-and-round-trips/
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
    $encodedCommand
    
}

function Decode-Command
{

<#
.SYNOPSIS
PowerShell cmdlet for b64 encoding strings
.DESCRIPTION
this script is for decoding b64 commands that get run in PowerShell -Enc
.PARAMETER command
This is the string you want to base 64 decode
.EXAMPLE
PS C:\> Import-Module B64.ps1
PS C:\> Decode-Command -c bgBlAHQAIAB1AHMAZQByAA==
.LINK
https://github.com/ahhh/
http://lockboxx.blogspot.com/
https://blogs.msdn.microsoft.com/timid/2014/03/26/powershell-encodedcommand-and-round-trips/
.NOTES
EZ-Mode tool
#>

    [CmdletBinding()] Param(
    
        [Parameter(Mandatory = $true, ValueFromPipeline=$true)]
        [Alias("c", "command")]
        [String]
        $Commandz
    
    )

    $decodedCommand = [System.Text.Encoding]::Unicode.GetString([System.Convert]::FromBase64String($Commandz));
    $decodedCommand
    
}

function Encode-File
{

<#
.SYNOPSIS
PowerShell cmdlet for b64 encoding a file to get embeded in a script
.DESCRIPTION
this script is able to encode files to later be embeded and run in a script
.PARAMETER file
This is the location of the file you want to base64 encoded
.EXAMPLE
PS C:\> Import-Module B64.ps1
PS C:\> Encode-File -f "C:\lol.exe"
.LINK
https://github.com/ahhh/
http://lockboxx.blogspot.com/
http://www.getautomationmachine.com/en/company/news/item/embedding-files-in-powershell-scripts
.NOTES
EZ-Mode tool
#>

    [CmdletBinding()] Param(
    
        [Parameter(Mandatory = $true, ValueFromPipeline=$true)]
        [Alias("f", "file")]
        [String]
        $filez
    
    )

    # To use embeded in a script
    $Content = Get-Content -Path $filez -Encoding Byte
    $Base64 = [System.Convert]::ToBase64String($Content)
    $Base64
    
}

function Decode-File
{

<#
.SYNOPSIS
PowerShell cmdlet for dropping a file that has been base64 encoded into the script
.DESCRIPTION
this script is supposed to drop binary files from encoded bas64
.PARAMETER file
This is the location of the file you want to write with the decoded base64
.PARAMETER enc
This is the base64 encoded file content that you are decoding
.EXAMPLE
PS C:\> Import-Module B64.ps1
PS C:\> type .\file.b64.txt | Decode-File -f .\dropped.exe 
.LINK
https://github.com/ahhh/
http://lockboxx.blogspot.com/
http://www.getautomationmachine.com/en/company/news/item/embedding-files-in-powershell-scripts
.NOTES
EZ-Mode tool
#>

    [CmdletBinding()] Param(
  
        [Parameter(Mandatory = $true, ValueFromPipeline=$true)]
        [Alias("e", "EncodedFile", "c")]
        [String]
        $enc,

        [Parameter(Mandatory = $true)]
        [Alias("f", "file")]
        [String]
        $filez
    
    )

    $Content = [System.Convert]::FromBase64String($Enc)
    Set-Content -Path $filez -Value $Content -Encoding Byte
    Write-Host "Wrote out file $filez"
    
}
