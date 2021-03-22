function RA_Verify_VMBackup{
    <#  
      .SYNOPSIS
      Function to allow user to call the backup verify API to verify a virtual machine backup
      .DESCRIPTION
      The RA_VerifyVMBackup function is used to call the backup verify api to start a backup verification job for a virtual machine.
      .NOTES
      Written by Jeremy Cathey for community usage
      .EXAMPLE  RA_VerifyVMBackup -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds
    #>
    param($URI, $Creds, $LogPath)
    $auth = RA_GetAPIAuth -Creds $Creds
    $VMName = read-host -Prompt 'Enter name of VM to Verify: '
    $VMSnapshotDate = read-host -Prompt 'Enter date for snapshot to verify (example: mm/dd/yyyy HH:mm): '
    #Store virtual machine details in $VM variable
    $VM = Get-RubrikVM -Name $VMName
    #Assign virtual machine id stored in $VM into $VMID variable
    $VMID = $VM.id
    #Retrieve snapshot details for a selected date
    $Snap = Get-RubrikVM $VMName | Get-RubrikSnapshot -Date $VMSnapshotDate
    #Assign snapshot id stored in $Snap inot SnapshotID variable
    $SnapshotID = $Snap.id
    $APIHeaders = @{
                'Authorization' = "Basic $auth"
                }
    $Verify_BodyText = @{objectId = $VMID
                         snapshotIDsOpt = $SnapshotID}
    $Verify_JSON = $Verify_BodyText | ConvertTo-Json
    $Verify_params = @{
        Uri = 'https://'+ $URI + '/api/v1/backup/verify'
        Headers= $APIHeaders
        Method = 'POST'
        Body = $Verify_JSON
        ContentType = 'application/json'
    }
    $RF_Call = Invoke-RestMethod @Verify_params
                $LogDateTime = Get-Date -Format “dddd MM/dd/yyyy HH:mm:ss”
                $log = $LogDateTime + ' - Backup Verification job scheduled for ' + $VMName +'. -> User='+$Creds.username
                $log | Out-File -FilePath $LogPath -Append 
    Write-Host "Backup Verification Job is Scheduled Successfully."
    Write-host " "
    Write-host " "

}
