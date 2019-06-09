<#
.SYNOPSIS
  Check if remote computers are patched against EternalBlue.

.DESCRIPTION
  EternalBlue is used as a propagation mechanism.
  Patching the system does not mean that it is protected against the encryption routine.
  However, it means that the system is protected against the "wormness" of recent WannaCry's variant.

.PARAMETER InputFile
  Path of the file containing hostnames to be checked for EternalBlue patch

.INPUTS
  [Optional] InputFile

.OUTPUTS
  Log file created

.NOTES
  Version:        0.1
  Author:         Cassius Puodzius
  Creation Date:  14/05/2017
  Purpose/Change: Initial script development
  
.EXAMPLE
  <Example goes here. Repeat this attribute for more than one example>
#>

Param (
  [Parameter(Mandatory=$True)][string]$InputFile,
  [Parameter(Mandatory=$False)][switch]$GetCredential)
  
#---------------------------------------------------------[Initializations]--------------------------------------------------------

#Set Error Action to Silently Continue
$ErrorActionPreference = "SilentlyContinue"

# Get credential (if required so)
If($GetCredential) {
  $Credential = Get-Credential
}

# Get current Timestamp
$Timestamp = get-date -Format yMMddhhmmss

#Dot Source required Function Libraries
. .\Logging_Functions.ps1

#----------------------------------------------------------[Declarations]----------------------------------------------------------

# Microsoft Security Bulletin MS17-010
# ref: https://technet.microsoft.com/library/security/MS17-010
$KBList = (
  "KB4012212",
  "KB4012213",
  "KB4012214",
  "KB4012215",
  "KB4012216",
  "KB4012217",
  "KB4012598",
  "KB4012606",
  "KB4013198",
  "KB4013429"
)

# Windows 10 and Windows Server 2016 updates are cumulative.
# The monthly security release includes all security fixes for vulnerabilities that affect Windows 10, in addition to non-security updates.

# Cumulative KBs for Windows 10 and Windows Server 2016:
#
# From KB4012606
# ref: http://www.catalog.update.microsoft.com/ScopedViewInline.aspx?updateid=6a38fe85-98ba-4ce2-b4eb-aed947d5c203
# As of May 17, 2017:
#
# 2017-05 Cumulative Update for Windows 10 for x86-based Systems (KB4019474)
# Cumulative Update for Windows 10 (KB4015221)
# Cumulative Update for Windows 10 (KB4016637)
#

KBList.Add("4019474")
KBList.Add("4015221")
KBList.Add("4016637")

# From KB4013198
# ref: http://www.catalog.update.microsoft.com/ScopedViewInline.aspx?updateid=6d9f75f7-d998-4188-a935-7603f4e51a4d
# As of May 17, 2017:
#
# Cumulative Update for Windows 10 Version 1511 (KB4015219)
# Cumulative Update for Windows 10 Version 1511 (KB4016636)
# Cumulative Update for Windows 10 Version 1511 (KB4019473)
#

KBList.Add("4015219")
KBList.Add("4016636")
KBList.Add("4019473")

# From KB4013429
# ref: http://www.catalog.update.microsoft.com/ScopedViewInline.aspx?updateid=724ee219-b949-4d44-9e02-e464c6062ae4
# As of May 17, 2017:
#
# 2017-05 Cumulative Update for Windows 10 Version 1607 for x86-based Systems (KB4019472)
# Cumulative Update for Windows 10 Version 1607 (KB4015217)
# Cumulative Update for Windows 10 Version 1607 (KB4015438)
# Cumulative Update for Windows 10 Version 1607 (KB4016635)
#

KBList.Add("4019472")
KBList.Add("4015217")
KBList.Add("4015438")
KBList.Add("4016635")

# From: WannaCrypt Ransomware Customer Guidance: https://static.spiceworks.com/attachments/post/0017/5996/CustomerReady_WannaCrypt_Guidance.pdf
# TODO: Get short list of KBs needed to check for EternalBlue patch
#

KBList.Add("4015549")
KBList.Add("4015550")
KBList.Add("4015551")
KBList.Add("4019215")
KBList.Add("4019216")
KBList.Add("4019264")

#Script Version
$sScriptVersion = "0.1"
$sScriptName = "VerifyEternalBlue"

#Log File Info
$sLogPath = $Env:TEMP
$sLogName = "$($sScriptName)_$($Timestamp).log"
$sLogFile = Join-Path -Path $sLogPath -ChildPath $sLogName

#-----------------------------------------------------------[Execution]------------------------------------------------------------

Log-Start -LogPath $sLogPath -LogName $sLogName -ScriptVersion $sScriptVersion

If($InputFile) {
  $Hostnames = Get-Content $InputFile
}

#TODO: Implement Get-ADComputers -Computers

ForEach($Hostname in $Hostnames) {
  Write-Host "Checking connection to $Hostname..."

  If(-not (Test-Connection -ComputerName $Hostname)) {
      $LogMessage = "$Hostname is unreachable"
      Write-Host $LogMessage
      Log-Error -LogPath $sLogFile -ErrorDesc $LogMessage -ExitGracefully $False
      Continue
  }

  Write-Host "`tGetting HotFix list..."

  If($GetCredential) {
   $HotFixList = Get-HotFix -ComputerName $Hostname -Credential $Credential
  }
  Else {
    $HotFixList = Get-HotFix -ComputerName $Hostname
  }

  $Patched = $False
  ForEach($Entry in $HotFixList) {
    ForEach($KB in $KBList) {
      If($Entry -Like "*$KB*") {
        $Patched = $True
        Break
      }
      If($Patched) {
        Break
      }
    }
  }

  If($Patched) {
    $LogMessage = "`tComputer $Hostname is patched against EternalBlue ($KB)"
    Write-Host $LogMessage
    Log-Write -LogPath $sLogFile -LineValue $LogMessage
  }
  Else {
    $LogMessage = "`tComputer $Hostname is vulnerable to EternalBlue"
    Write-Host $LogMessage
    Log-Write -LogPath $sLogFile -LineValue $LogMessage
  }

}

Log-Finish -LogPath $sLogFile
Write-Host "Logfile created at $Logfile"