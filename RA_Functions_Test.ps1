$ScriptPath = 'G:\My Drive\Scripts\Powershell\Rubrik_Automate\'
$LogPath = $ScriptPath + 'logs\ra_logs.log'
################################################
# Importing All Functions
################################################
$FunctionsDirectory = $ScriptPath + 'RA_Functions\'
$Functions = Get-ChildItem -Path $FunctionsDirectory -Recurse
# Adding each function
ForEach ($Function in $Functions)
{
# Setting path
$FullFunctionPath = $Function.FullName
# Importing
. $FullFunctionPath
}
################################################

#Connect with Rubrik Cluster Using Username/Password (Basic Auth)
$ConnectionInfo = RA_Connect_Creds -ScriptPath $ScriptPath

<#
    #Call functino to get jobs that have status of Failure
    $FailureResult = RA_GQL_JobMonitoringFailures -URI $Connectioninfo.server -Creds $ConnectionInfo.creds
    $FailCount = $FailureResult.data.jobMonitoring.nodes.Count
    Write-Host $FailCount
    $FailEventIDs = @()
    Do{
        $FailEventIDs += $FailureResult.data.jobMonitoring.nodes[$FailCount].eventSeriesId
        Write-Host $FailCount + ': ' + $FailEventIDs[$FailCount]
        $FailCount = $FailCount - 1
      }while($FailCount -ge 0)

#Take Job Failure and pass Event Series ID to RA_GetEventSeriresInfo to return the reason, message, and remedy for the failure
$ES_Event = RA_GetEventSeriesInfo -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -EventSeriesID $FailEventID
#Convert the return from JSON to assign into variables below
$ES_Event_Details = $ES_Event.eventDetailList[0].eventInfo | ConvertFrom-Json
$ES_Reason = $ES_Event_Details.cause.reason
$ES_Message = $ES_Event_Details.cause.message
$ES_Remedy = $ES_Event_Details.cause.remedy
Write-Host $ES_Reason
Write-Host ""
Write-Host $ES_Message
Write-Host ""
Write-Host $ES_Remedy
Write-Host ""
#>

<#
#Call function to get Virtual Machine Details and return then in an array of custom objects for continued use
$VMDetails = RA_GQL_VMDetails -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds
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
#Call function to search a Fileset on a particular host for a file and download the file to the specified destination locally
RA_Search_Download_From_Fileset -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds
#>


<#
#Call Function to search VM for file and download the file to the specified destination locally
RA_Search_Download_From_VM -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds
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


<#
#Call function to search for file in a VM or fileset and do a hash comparison to see if the restored file is the same as the original
RA_Verify_RestoredFile -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -LogPath $LogPath
#>