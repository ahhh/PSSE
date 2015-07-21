# Powershell program for playing with port scanning
# Set your IP to scan and port range
$IP = "127.0.0.1"
$TCP_PORT_RANGE = 21,22,23,53,80,139,443,445,1433,3306,3389,5900
$UDP_PORT_RANGE = 53,111,123,161,500,514,5060

# TCP Port Scanning using the .Net Socket class
foreach ($i in $TCP_PORT_RANGE) {
  try {
    $socket = new-object System.Net.Sockets.TCPClient($IP, $i);
  } catch {
    #Write-Warning "$($Error[0])"
  }
  if ($socket -eq $NULL) {
    echo "$($IP):$($i) - TCP PORT Closed";
  } else {
    echo "$($IP):$($i) - TCP PORT Open";
    $socket = $NULL;
  }
}

# UDP Port Scanning using the .Net Socket class
foreach ($i in $UDP_PORT_RANGE) {
  $socket = New-Object System.Net.Sockets.UdpClient
  $socket.client.ReceiveTimeout = 1000
  $socket.Connect($IP, $i)
  # Some initial data to send over UDP
  $data = New-Object System.Text.ASCIIEncoding
  $bytes = $data.GetBytes("HelloS")
  [void] $socket.Send($bytes,$bytes.length)
  # Create a listener for response
  $udp_endpoint = New-Object System.Net.IPEndPoint([system.net.ipaddress]::Any,0)
  try {
    # Attempt to receive a response
    $receivedbytes = $socket.Receive([ref] $udp_endpoint)
    [string] $returndata = $data.GetString($receivedbytes)
    echo "$($IP):$($i) - UDP PORT Open";
  }
  catch {
    # Timeout or connection refused
    #Write-Warning "$($Error[0])"
    echo "$($IP):$($i) - UDP PORT Closed";
  }
  finally {
      # Cleanup
      $socket.Close()
  }
}
