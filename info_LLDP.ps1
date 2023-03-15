
$Cred = Get-Credential -Message "Enter Creds for Vcenter"

#Connect-VIServer "Enter your Vcenter" -Credential $Cred -AllLinked -ErrorAction SilentlyContinue

#$Cluster
Write-Host "Enter Cluster" -ForegroundColor Green
$Cluster = Read-Host


if(!($Cluster))
{
Write-Host -Fore YELLOW "Missing parameter!"
Write-Host -Fore YELLOW "Usage:"
Write-Host -Fore YELLOW ".\LLDP_CDP_Information.ps1 <your cluster>"
Write-Host -Fore YELLOW ""
Write-Host -Fore YELLOW "Example: .\LLDP_CDP_Information.ps1 LabCluster"
exit
}
if(!(Get-Cluster $Cluster -EA SilentlyContinue))
{
Write-Host -Fore RED "No cluster found with the name: $Cluster "
Pause
Write-Host -Fore YELLOW "These clusters where found in the vCenter you have connected to:"
Get-Cluster | sort Name | Select Name
exit
}

$vmh = Get-Cluster $Cluster | Get-VMHost | sort name
$LLDPResultArray = @()
$CDPResultArray = @()

If ($vmh.ConnectionState -eq "Connected" -or $vmh.State -eq "Maintenance")
{
Get-View $vmh.ID | `
% { $esxname = $_.Name; Get-View $_.ConfigManager.NetworkSystem} | `
% { foreach ($physnic in $_.NetworkInfo.Pnic) {
$pnicInfo = $_.QueryNetworkHint($physnic.Device)

foreach( $hint in $pnicInfo )
{
## If the switch support LLDP, and you're using Distributed Virtual Swicth with LLDP
if ($hint.LLDPInfo)
{
#$hint.LLDPInfo.Parameter
$LLDPResult = "" | select-object VMHost, PhysicalNic, PhysSW_Trunk, PhysSW_LAN, PhysSW_RF, PhysSW_Name, PhysSW_Description, PhysSW_MGMTIP, PhysSW_MTU, PortsID

$PortSWDDetail = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "Port Description" }).Value;
$PortSWDShort = $PortSWDDetail -split " "
$PortSWTrunk = $PortSWDShort[0]
$PortSWLAN = ($PortSWDShort[1] -split ":")[1]
$PortSWRF = $PortSWDShort[2]
$PortID = $hint.LLDPInfo.portid
$PortID = $PortID -replace "Ethernet", "E"

$LLDPResult.VMHost = $esxname
$LLDPResult.PhysicalNic = $physnic.Device
$LLDPResult.PhysSW_Trunk = $PortSWTrunk
$LLDPResult.PhysSW_LAN = $PortSWLAN
$LLDPResult.PhysSW_RF = $PortSWRF
$LLDPResult.PhysSW_Name = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "System Name" }).Value
$LLDPResult.PhysSW_Description = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "System Description" }).Value
$LLDPResult.PhysSW_MGMTIP = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "Management Address" }).Value
$LLDPResult.PhysSW_MTU = ($hint.LLDPInfo.Parameter | ? { $_.Key -eq "MTU" }).Value
#$LLDPResult.PortsID = ($hint.LLDPInfo.Parameter | ? {$_.Key -eq "portid" }).Value
$LLDPResult.PortsID = $PortID

$LLDPResultArray += $LLDPResult
}

## If it's a Cisco switch behind the server ;)
if ($hint.ConnectedSwitchPort)
{
#$hint.ConnectedSwitchPort
$CDPResult = "" | select-object VMHost, PhysicalNic, PhysSW_Port, PhysSW_Name, PhysSW_HWPlatform, PhysSW_Software, PhysSW_MGMTIP, PhysSW_MTU, PortsID

$CDPResult.VMHost = $esxname
$CDPResult.PhysicalNic = $physnic.Device
$CDPResult.PhysSW_Port = $hint.ConnectedSwitchPort.PortID
$CDPResult.PhysSW_Name = $hint.ConnectedSwitchPort.DevID
$CDPResult.PhysSW_HWPlatform = $hint.ConnectedSwitchPort.HardwarePlatform
$CDPResult.PhysSW_Software = $hint.ConnectedSwitchPort.SoftwareVersion
$CDPResult.PhysSW_MGMTIP = $hint.ConnectedSwitchPort.MgmtAddr
$CDPResult.PortsID = $hint.ConnectedSwitchPort.PortsID
$CDPResult.PhysSW_MTU = $hint.ConnectedSwitchPort.Mtu


$CDPResultArray += $CDPResult
}
if(!($hint.LLDPInfo) -and (!($hint.ConnectedSwitchPort)))
{
Write-Host -Fore YELLOW "No CDP or LLDP information available! "
Write-Host -Fore YELLOW "Check if your switches support these protocols and if"
Write-Host -Fore YELLOW "the CDP/LLDP features are enabled."
}
}
}
}
}

else
{
Write-Host "No host(s) found in Connected or Maintenance state!"
exit
}

$currentDate = Get-Date -format "MM/dd/yyyy_HH-mm"

## Output to screen and/or file
if ($CDPResultArray)
{
$CDPResultArray | ft -autosize
$CDPResultArray | Export-Csv .\CDP_$Cluster-$currentDate.txt -useculture -notypeinformation
}
if ($LLDPResultArray)
{
$LLDPResultArray | ft -autosize
$LLDPResultArray | Export-Csv .\LLDP_$Cluster-$currentDate.csv -useculture -notypeinformation
}

Read-Host "press any key:"