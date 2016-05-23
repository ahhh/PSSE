function Get-ScreenShot
# Orginial script by Guitarrapc: https://gist.github.com/guitarrapc/9870497
# Adopted by Ahhh: https://gist.github.com/ahhh/25a8cb327ea689c8c0eaab6761191ee6
{
    [CmdletBinding()]
    param(
        [parameter(Mandatory = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Path', 'Out', 'o')]
        [string]$OutPath = "$env:USERPROFILE\Documents\ScreenShot",
 
        #screenshot_[yyyyMMdd_HHmmss_ffff].png
        [parameter(Mandatory = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Name', 'n')]
        [string]$FileNamePattern = 'screenshot_{0}.png',
 
        [parameter(Mandatory = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Repeat', 'r')]
        [int]$RepeatTimes = 0,
 
        [parameter(Mandatory = 0)]
        [ValidateNotNullOrEmpty()]
        [Alias('Duration','d')]
        [int]$DurationMs = 1
     )
 
     $script = {
     	Param (
		[Parameter(Position = 0)]
		[string]$OutPath = "$env:USERPROFILE\Documents\ScreenShot",
	
		[Parameter(Position = 1)]
        	[string]$FileNamePattern = 'screenshot_{0}.png',
		
		[Parameter(Position = 2)]
        	[int]$RepeatTimes = 0,
	
		[Parameter(Position = 3)]
	        [int]$DurationMs = 1
	)
	
        $ErrorActionPreference = 'Stop'
        Add-Type -AssemblyName System.Windows.Forms
 
        if (-not (Test-Path $OutPath))
        {
            New-Item $OutPath -ItemType Directory -Force
        }
 
        0..$RepeatTimes `
        | %{
            $fileName = $FileNamePattern -f (Get-Date).ToString('yyyyMMdd_HHmmss_ffff')
            $path = Join-Path $OutPath $fileName
 
            $b = New-Object System.Drawing.Bitmap([System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Width, [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height)
            $g = [System.Drawing.Graphics]::FromImage($b)
            $g.CopyFromScreen((New-Object System.Drawing.Point(0,0)), (New-Object System.Drawing.Point(0,0)), $b.Size)
            $g.Dispose()
            $b.Save($path)
 
            if ($RepeatTimes -ne 0)
            {
                Start-Sleep -Milliseconds $DurationMs
            }
        }
    }
    	# Setup ScreenCaps's runspace
	# To have it run in the background
	$PowerShell = [PowerShell]::Create()
	[void]$PowerShell.AddScript($Script)
	[void]$PowerShell.AddArgument($OutPath)
	[void]$PowerShell.AddArgument($FileNamePattern)
	[void]$PowerShell.AddArgument($RepeatTimes)
	[void]$PowerShell.AddArgument($DurationMs)	
	
	# Start ScreenCapture
	[void]$PowerShell.BeginInvoke()
}
