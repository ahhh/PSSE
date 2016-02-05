function Run-Simple-WebServer
{ 
<#
.SYNOPSIS
Yet Another PowerShell Web Server. This basic webserver allows for the quick and easy modification of a shared folder using a web api

.DESCRIPTION
A cmdlet to launch a simple PowerShell Web Server (Yet Another PowerShell Web Server). Gives the ability to quickly share files in a directory, as well as upload new files and delete existing ones. 

.PARAMETER WebRoot
The webroot of the server, the local directory to be shared for listing, reading, writing, and deleting files. Defaults to the current working directory, may be dangerous so use w/ caution. -d or -l or -f for short

.PARAMETER url
The url to run the webserver on. -u for short

.EXAMPLE
PS C:\> Import-Module Run-Simple-WebServer
PS C:\> Run-Simple-WebServer

.LINK
https://github.com/ahhh/PSSE/blob/master/Run-Simple-WebServer.ps1
http://obscuresecurity.blogspot.mx/2014/05/dirty-powershell-webserver.html
https://gist.github.com/wagnerandrade/5424431

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3061

#>           
    [CmdletBinding()] Param( 

       [Parameter(Mandatory = $false)]
       [Alias("d", "l", "f")]
       [String]
       $WebRoot = ".",
       
       [Parameter(Mandatory = $false)]
       [Alias("u")]
       [String]
       $url = 'http://localhost:8080/'

    )

    # Our responses to the various API endpoints
    $routes = @{
      # Simple hello
      "/hola" = { return '<html><body>Hello world!</body></html>' } 

      # Lists all of the files in the web root
      "/list" = { return dir $WebRoot }

      # Downloads the file out of the web root specified in the query string
      "/download" = { return (Get-Content (Join-Path $WebRoot ($context.Request.QueryString[0]))) }

      # Deletes the file out of the web root specificed in the query string
      "/delete" = { (rm (Join-Path $WebRoot ($context.Request.QueryString[0])))
                     return "Succesfully deleted" }

      # Creates a file based on the contents of an uploaded file via a get request (in the future should be based off of POST contents of an actual file upload); Works like /upload?name=lol&value=trololol
      "/upload" = { (Set-Content -Path (Join-Path $WebRoot ($context.Request.QueryString[0])) -Value ($context.Request.QueryString[1]))
                     return "Succesfully uploaded" }
                     
      # Shuts down the webserver remotly
      "/kill" = { exit }
    }
     

    # This code is largly barrowed from Wagnerandrade's SimpleWebServer 
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add($url)
    $listener.Start()
    
    Write-Host "Listening at $url..."
     
    try{
      while ($listener.IsListening)
      {
        $context = $listener.GetContext()
        $requestUrl = $context.Request.Url
        $response = $context.Response
       
        Write-Host ''
        Write-Host "> $requestUrl"
       
        $localPath = $requestUrl.LocalPath
        $route = $routes.Get_Item($requestUrl.LocalPath)
       
        if ($route -eq $null) # If a route dosn't exist, we 404
        {
          $response.StatusCode = 404
        }
        else # Else, follow the route and it's returned content
        {
          $content = & $route
          $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
          $response.ContentLength64 = $buffer.Length
          $response.OutputStream.Write($buffer, 0, $buffer.Length)
        }
        
        $response.Close()
        $responseStatus = $response.StatusCode
        Write-Host "< $responseStatus"
      }
    }catch{ }
  }
