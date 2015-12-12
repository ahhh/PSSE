function Invoke-KillProcess
{
    param (
        [Parameter()]
        [String]
        $TargetName,

        [Parameter()]
        [Switch]
        $Service,

        [Parameter()]
        [String]
        $ProcID
    )

    if ($Service -and !$ProcID)
    {
        Stop-Service -Name $TargetName
    }
    elseif ($ProcID)
    {
        Get-Process -PID $ProcID | Stop-Process
    }
    else
    {
        Stop-Process -Name $Targetname
    }

}