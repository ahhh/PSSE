# From: http://blogs.msdn.com/b/dimeby8/archive/2009/06/10/change-unidentified-network-from-public-to-work-in-windows-7.aspx
# Name: ChangeCategory.ps1 
# Copyright: Microsoft 2009 
# Revision: 1.0 
# 
# This script can be used to change the network category of 
# an 'Unidentified' network to Private to allow common network 
# activity. This script should only be run when connected to 
# a network that is trusted since it will also affect the 
# firewall profile used. 
# This script is provided as-is and Microsoft does not assume any 
# liability. This script may be redistributed as long as the file 
# contains these terms of use unmodified. 
# 
# Usage: 
# Start an elevated Powershell command window and execute 
# ChangeCategory.ps1 
#  
$NLMType = [Type]::GetTypeFromCLSID('DCB00C01-570F-4A9B-8D69-199FDBA5723B')
$INetworkListManager = [Activator]::CreateInstance($NLMType)

$NLM_ENUM_NETWORK_CONNECTED  = 1
$NLM_NETWORK_CATEGORY_PUBLIC = 0x00
$NLM_NETWORK_CATEGORY_PRIVATE = 0x01
$UNIDENTIFIED = "Unidentified network"

$INetworks = $INetworkListManager.GetNetworks($NLM_ENUM_NETWORK_CONNECTED)

foreach ($INetwork in $INetworks)
{
    $Name = $INetwork.GetName()
    $Category = $INetwork.GetCategory()

    if ($INetwork.IsConnected -and ($Category -eq $NLM_NETWORK_CATEGORY_PUBLIC) -and ($Name -eq $UNIDENTIFIED))
    {
        $INetwork.SetCategory($NLM_NETWORK_CATEGORY_PRIVATE)
    }
}
