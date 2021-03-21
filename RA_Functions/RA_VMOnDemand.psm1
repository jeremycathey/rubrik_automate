function RA_VMOnDemand{
<#  
      .SYNOPSIS
      Function to allow user to take on-demand snapshot of multiple VMs from a source CSV file

      .DESCRIPTION
      The RA_VMOnDemand function is used to read VMs from a CSV file and connect to a Rubrik Cluster and take on-demand backups for each VM.

      .NOTES
      Written by Jeremy Cathey for community usage

      .EXAMPLE  RA_VMOnDemand -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -$LogPath $LogPath
#>

    param($URI, $Creds, $LogPath)
    $auth = RA_GetAPIAuth -Creds $Creds
    $VMName = Read-Host -Prompt 'Enter name of VM for on-demand snapshot: '
    $VMDetails = RA_GQL_VMDetails -URI $URI -Creds $Creds -VMName $VMName

    $APIHeaders = @{
                'Authorization' = "Basic $auth"
                }
    $OnDemand_Body = @{slaId = $VMDetails.slaid} | ConvertTo-Json
    $OnDemand_params = @{
        Uri = 'https://'+ $URI + '/api/v1/vmware/vm/'+$VMDetails.id+'/snapshot'
        Headers= $APIHeaders
        Method = 'POST'
        Body = $OnDemand_Body
        ContentType = 'application/json'
    }
    $OnDemand_Call = Invoke-RestMethod @OnDemand_params
                $LogDateTime = Get-Date -Format “dddd MM/dd/yyyy HH:mm:ss”
                $log = $LogDateTime + ' - On-Demand snapshot scheduled for ' + $VMName +'. -> User='+$Creds.username
                $log | Out-File -FilePath $LogPath -Append 
    Write-Host "On-Demand snapshost is Scheduled."

}
