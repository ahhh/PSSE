function CheckForKB2871997
{
    try
    {
        Write-Output "Checking for the hotfix"
        $hotfix = Get-HotFix -Id KB2871997
    }

    catch
    {
        if ($Error[0] -match "Get-HotFix : Cannot find the requested hotfix")
        {
            $script:success = $false
        }

        elseif ($hotfix.HotFixID -eq "KB2871997")
        {
            $script:success = $true
        }
    }
}

function Show-Result
{
    CheckForKB2871997
    if ($success = $true)
    {
        Write-Output "The KB2871997 is installed"
    }
    else
    {
        Write-Warning "The KB2871997 is not installed"
    }
}

Export-ModuleMember -Function *-*