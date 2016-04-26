## Powershell function to quickly strip content out of file 
function Strip-All
{
<#
.SYNOPSIS
PowerShell cmdlet to remove new lines and comments from a script and output a new version of the script
.DESCRIPTION
script to quickly strip newlines and comments out of a file
Currently dosn't handle header descriptions like this part!
.PARAMETER in
this is the file you are stripping
.PARAMETER out
this is the file you are writing out that has been stripped
.EXAMPLE
PS C:\> Import-Module Stripper.ps1
PS C:\> Strip-All -i inputfile.ps1 -o outputfile.ps1
.LINK
https://github.com/ahhh/
http://lockboxx.blogspot.com/
http://stackoverflow.com/questions/9223460/remove-empty-lines-from-text-file-with-powershell.NOTES
EZ-Mode tool
#>

    [CmdletBinding()] Param(
    
        [Parameter(Mandatory = $true, ValueFromPipeline=$true)]
        [Alias("i", "infile")]
        [String]
        $in,

        [Parameter(Mandatory = $true)]
        [Alias("o", "outfile")]
        [String]
        $out
    
    )

    [IO.File]::ReadAllText($in) -replace '\#(.+)\r\n', "`r`n" | %{$_ -replace '\#\r\n',"`r`n" } | %{$_ -replace '\s+\r\n+',"`r`n" } | Out-File $out

}
