function Get-Temperature {

<#

.DESCRIPTION
Get-Temperature returns the CPU temp in Celsius, Fahrenheit, and Kelvin

.EXAMPLE
PS C:\> Import-Module Get-Temperature
PS C:\>  Get-Temperature

.LINK
https://github.com/ahhh/PSSE/blob/master/Get-Temperature.ps1
https://gist.github.com/jeffa00/9577816
http://ammonsonline.com/is-it-hot-in-here-or-is-it-just-my-cpu/
http://www.leeholmes.com/guide

.NOTES
Quick utility script for getting CPU temp, takes no arguments. Full credit to Jeff Ammons, I just turned it into a fast cmdlet

#>

    $t = Get-WmiObject MSAcpi_ThermalZoneTemperature -Namespace "root/wmi"

    $currentTempKelvin = $t.CurrentTemperature / 10
    $currentTempCelsius = $currentTempKelvin - 273.15

    $currentTempFahrenheit = (9/5) * $currentTempCelsius + 32

    return $currentTempCelsius.ToString() + " C : " + $currentTempFahrenheit.ToString() + " F : " + $currentTempKelvin + "K"  
}
