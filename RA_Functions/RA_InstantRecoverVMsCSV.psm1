Function RA_InstantRecoverVMsCSV{
        <#  
      .SYNOPSIS
      Function to allow user to Import CSV File with Vmware VMs and Instant Recover the vms with csv specified parameters

      .DESCRIPTION
      Function to allow user to Import CSV File with Vmware VMs and Instant Recover the vms with csv specified parameters

      .NOTES
      Written by Jeremy Cathey for community usage

      .EXAMPLE  RA_InstantRecoverVMs -SourceFile "VMDRFailover.csv"
    #>
    param($SourceFile, $Server, $Creds, $LogPath)
    $auth = RA_GetAPIAuth -Creds $Creds
    
    $csv = Import-Csv $SourceFile
    foreach($item in $csv)
    {
        $VMName = $item.VMName
        $VMDetails = RA_GQL_VMDetails -URI $Server -Creds $Creds -VMName $VMName
        $RemoveNetworkDevices = $item.RemoveNetworkDevices
        $PreserveMOID = $item.PreserveMOID
        $HostId = $VMDetails.hostid

        #==========Start of InstantRecovery API Call==========
        $VMSnap = Get-RubrikVM -Name $VMName | Get-RubrikSnapshot -Latest 

        $VM_JSON = "{
                      ""vmName"": ""$vmName"",
                      ""hostId"": ""$HostID"",
                      ""removeNetworkDevices"": $RemoveNetworkDevices,
                      ""preserveMoid"": $PreserveMOID
                    }"
        $EndPoint = 'https://' + $Server + '/api/v1/vmware/vm/snapshot/' + $VMSnap.id + '/instant_recover'
        $VM_params = @{
            Uri = $EndPoint
            Headers = @{'Authorization' = "Basic $auth" }
            Method = 'POST'
            ContentType = 'application/json'
            Body = $VM_JSON
        }

        $loop = 1
        Do{
            Write-Host 'THIS IS NOT A TEST.  This will perform an Instant Recovery for VM: '$VMName '. Are you sure you wish to proceed (y/n): ' -ForegroundColor Red -NoNewline
            $WarningResponse = Read-Host
            Write-Host ""
            If($WarningResponse -eq 'y'){
                $VM_Call = Invoke-RestMethod @VM_params
                $LogDateTime = Get-Date -Format “dddd MM/dd/yyyy HH:mm:ss”
                $log = $LogDateTime + ' - ' + $VMName + ' successfully mounted on host: '+$VMDetails.hostName+'. -> User='+$Creds.username
                $log | Out-File -FilePath $LogPath -Append 
                Write-Host $vmName + " successfully mounted on host: " + $VMDetails.hostname + '.'
                #==========End of InstantRecovery API Call==========
                $loop = 2
            }
            if($WarningResponse -eq 'n')
            {
                Write-Host "Process aborted by user." -ForegroundColor Red
                $loop = 2
            }
        }while($loop -eq 1)
    }
}
