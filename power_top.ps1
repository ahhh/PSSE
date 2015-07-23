# PowerTop, PowerShell version of Linux Top
# http://superuser.com/questions/176624/linux-top-command-for-windows-powershell

$saveY = [console]::CursorTop
$saveX = [console]::CursorLeft      

while ($true) {
    Get-Process | Sort -Descending CPU | Select -First 30;
    Sleep -Seconds 2;
    [console]::setcursorposition($saveX,$saveY+3)
}
