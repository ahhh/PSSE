<#  
 .SYNOPSIS  
  Remove All Windows Updates
    
 .DESCRIPTION   
  Remove All Windows Updates from OS.
    
 .NOTES   
  Original Author   : Justin Bennett   
  Date              : 2015-12-01  
  Contact           : http://www.allthingstechie.net
  Adopted           : Ahhh
  Date              : 2016-03-18
  Contace           : http://lockboxx.blogspot.com
  Revision          : v1.666
 .EXAMPLE 
  C:\PS> #Uninstall All Updates
  C:\PS> Remove-WindowsUpdates.ps1

#>
Function Remove-WindowsUpdates {

	$Searcher = New-Object -ComObject Microsoft.Update.Searcher
	$RemoveCollection = New-Object -ComObject Microsoft.Update.UpdateColl

	#Gather All Installed Updates
	$SearchResult = $Searcher.Search("IsInstalled=1")

	#Add any of the specified KBs to the RemoveCollection
	$SearchResult.Updates | % { $RemoveCollection.Add($_) }

	if ($RemoveCollection.Count -gt 0) {
		$Installer = New-Object -ComObject Microsoft.Update.Installer
		$Installer.Updates = $RemoveCollection
		$Installer.Uninstall()
	} else { Write-Warning "No matching Windows Updates found" }
} 

Remove-WindowsUpdates
