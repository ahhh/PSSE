# Powershell profile to give persistent command history and logging. Borrowed from:
# http://hackerhurricane.blogspot.com/2014/11/i-powershell-logging-what-everyone.html
# https://lopsa.org/content/persistent-history-powershell

$LogCommandHealthEvent = $true
$LogCommandLifecycleEvent = $true

# Save last 200 history items on exit
$MaximumHistoryCount = 200
$historyPath = Join-Path (split-path $profile) history.clixml
Register-EngineEvent -SourceIdentifier powershell.exiting -SupportEvent -Action {
    Get-History -Count $MaximumHistoryCount | Export-Clixml (Join-Path (split-path $profile) history.clixml) }

# Load previous history
if ((Test-Path $historyPath)) {
    Import-Clixml $historyPath | ? {$count++;$true} | Add-History
    Write-Host -Fore Green "`nLoaded $count history item(s).`n"
}

	# Aliases and functions to make it useful

New-Alias -Name i -Value Invoke-History -Description "Invoke history alias"
Rename-Item Alias:\h original_h -Force
function h { Get-History -c  $MaximumHistoryCount }
function hg($arg) { Get-History -c $MaximumHistoryCount | out-string -stream | select-string $arg }
