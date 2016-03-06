# Example by Nikhil Mittal : http://www.labofapenetrationtester.com/
function Remove-MacroSecurity
{
    #Disable for MS Word
    $Word = New-Object -ComObject Word.Application
    $WordVersion = $Word.Version
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\$WordVersion\word\Security" -Name AccessVBOM -Value 1 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\$WordVersion\word\Security" -Name VBAWarnings -Value 1 -PropertyType DWORD -Force | Out-Null
}

function Set-MacroSecurity
{
    #Enable for MS Word
    $Word = New-Object -ComObject Word.Application
    $WordVersion = $Word.Version
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\$WordVersion\word\Security" -Name AccessVBOM -Value 0 -PropertyType DWORD -Force | Out-Null
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Office\$WordVersion\word\Security" -Name VBAWarnings -Value 0 -PropertyType DWORD -Force | Out-Null

}

function Check-MacroSecurity
{
    #Check for MS Word
    $Word = New-Object -ComObject Word.Application
    $WordVersion = $Word.Version
    $VBOM = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Office\$WordVersion\word\Security").AccessVBOM
    $VBA = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Office\$WordVersion\word\Security").VBAWarnings
    if (($VBOM -eq 0) -and ($VBOM -eq 0))
    {
        Write-Output "Macro Secrurity for MS Word enabled. Disabling it..."
        Remove-MacroSecurity
    }
    elseif (($VBOM -eq 1) -and ($VBOM -eq 1))
    {
        Write-Output "Macro Secrurity for MS Word disabled. Enabling it..."
        Set-MacroSecurity
    }
}
