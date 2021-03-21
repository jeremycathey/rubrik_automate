Function RA_InstantRecoverVM{
        <#  
      .SYNOPSIS
      Function to allow user to Instant Recover a vm

      .DESCRIPTION
      Function to allow user to Instant Recover a vm

      .NOTES
      Written by Jeremy Cathey for community usage

      .EXAMPLE  RA_InstantRecoverVM -Server $ConnectionInfo.server -Creds $ConnectionInfo.creds
    #>
    param($Server, $Creds, $LogPath)
        
        $auth = RA_GetAPIAuth -Creds $Creds
        $vmName = Read-Host -Prompt "Enter VM Name to Instant Recover" 
        $VMDetails = RA_GQL_VMDetails -URI $Server -Creds $Creds -VMName $vmName
        do{$removeNetworkDevices = Read-Host -Prompt "Enter 'True' or 'False' for removing network devices from the VM (case sensitive): "}until($removeNetworkDevices -eq "True" -or $removeNetworkDevices -eq "False")
        do{$preserveMOID = Read-Host -Prompt "Enter 'True' or 'False' for preserving the MOID for the VM (case sensitive): "}until($preserveMOID -eq "True" -or $preserveMOID -eq "False")
        $hostId = $VMDetails.hostid

        #==========Start of InstantRecovery API Call==========
        $VMSnap = Get-RubrikVM -Name $vmName | Get-RubrikSnapshot -Latest 

        $VM_JSON = "{
                      ""vmName"": ""$vmName"",
                      ""hostId"": ""$hostID"",
                      ""removeNetworkDevices"": $removeNetworkDevices,
                      ""preserveMoid"": $preserveMOID
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
                $log = $LogDateTime + ' - ' + $vmName + ' successfully mounted on host: '+$VMDetails.hostName+'. -> User='+$Creds.username
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
