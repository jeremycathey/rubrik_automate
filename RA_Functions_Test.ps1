$ScriptPath = 'G:\My Drive\Scripts\Powershell\Rubrik_Automate\'
$ModulePath = $ScriptPath + 'RA_Functions\RA_Functions.psm1'
Import-Module  $ModulePath -Force
$VMDRTestPath = $ScriptPath + 'VMDRTest.csv'
$SQLDRTestPath = $ScriptPath + 'SQLDRTest.csv'
$DRFailoverPath = $ScriptPath + 'VMDRFailover.csv'
$VMListPath = $ScriptPath + 'VMList.csv'
$LogPath = $ScriptPath + 'logs\ra_logs.log'

#Connect with Rubrik Cluster Using Username/Password (Basic Auth)
$ConnectionInfo = RA_Connect_Creds

<#
#Call function to get Virtual Machine Details and return then in an array of custom objects for continued use
$VMDetails = RA_GQL_VMDetails -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -VMName 'am1-jerecath-l2'
Write-Host $VMDetails.name
Write-Host $VMDetails.id
Write-Host $VMDetails.hostName
Write-Host $VMDetails.hostid
Write-host $VMDetails.slaname
Write-host $VMDetails.slaid
#>

<#
#Call function to verify backup of virtual machine
RA_Verify_VMBackup -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -LogPath $LogPath
#>

<#
#Call function to search a Windows Fileset on a particular server for a file and download the file to the specified destination locally
RA_Restore_From_Fileset_From_Link -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -FS_Name 'FS-am1-jerecath-w1' -Host_Name 'am1-jerecath-w1' -File2Download 'Where Am I.txt' -DestPath 'C:\Scripts\'
#>

<#
#Call function to Instant Recover VMs from a CSV file (THIS IS NOT A TEST)
RA_InstantRecoverVMsCSV -SourceFile 'G:\My Drive\Scripts\Powershell\Rubrik_Automate\VMDRFailover.csv' -Server $ConnectionInfo.server -Creds $ConnectionInfo.creds -LogPath $LogPath
#>

<#
#Call function to Instant Recover Specific VM (THIS IS NOT A TEST)
RA_InstantRecoverVM -Server $ConnectionInfo.server -Creds $ConnectionInfo.creds -LogPath $LogPath
#>

<#
#Call function to take an On-Demand snapshot of a VMware Virtual Machine
RA_VMOnDemand -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -LogPath $LogPath
#>

<#
#Call function to take On-Demand snapshots for list of virtual machines from a CSV file
RA_VMOnDemandFromCSV -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -SourceFile $VMListPath -LogPath $LogPath
#>


