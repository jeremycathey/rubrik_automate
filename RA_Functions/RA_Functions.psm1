
function RA_Menu{
param($ConnectionInfo, $ScriptPath)
#Function Menu for RubrikAutomate
    ####################################################################################
    #Define File Paths
    $VMDRTestPath = $ScriptPath + 'VMDRTest.csv'
    $SQLDRTestPath = $ScriptPath + 'SQLDRTest.csv'
    $DRFailoverPath = $ScriptPath + 'VMDRFailover.csv'
    $VMListPath = $ScriptPath + 'VMList.csv'
    $LogPath = $ScriptPath + 'logs\ra_logs.log'
    ####################################################################################

    $MenuLoop = 1
    $MenuChoice = -1
    do{
        Write-Output "Welcome to Rubrik Automate. "
        do{
            Write-Output "Please select from the following menu"
            Write-Output "1.  VM DR Test (LiveMount)->From CSV"
            Write-Output "2.  Stop VM DR Test (Unmount)->From CSV"
            Write-Output "3.  SQL DR Test (LiveMount)->From CSV"
            Write-Output "4.  End SQL DR Test (Unmount)->From CSV"
            Write-Output "5.  Start Instant Recover (NOT A TEST)->From CSV"
            Write-Output "6.  Start Instant Recover (NOT A TEST)->Single VM"
            Write-Output "7.  Take On-Demand Snapshot of VMware VMs-> From CSV With Assigned SLA"
            Write-Output "8.  Take On-Demand Snapshot of VMware VM-> Single VM with Assigned SLA"
            Write-Output "9.  Verify Backup of VMware VM"
            Write-Output "10.  Search a fileset for a file and download to local machine"
            Write-Output "0.  Exit"
            $MenuChoice = Read-Host -Prompt "Select Menu Option: "
            if($MenuChoice -eq 1){RA_VMDRTest -SourceFile $VMDRTestPath -LogPath $LogPath -Creds $ConnectionInfo.creds}
            elseif($MenuChoice -eq 2){RA_VMStopDRTest -SourceFile $VMDRTestPath -LogPath $LogPath -Creds $ConnectionInfo.creds}
            elseif($MenuChoice -eq 3){RA_SQLDRTest -SourceFile $SQLDRTestPath -LogPath $LogPath -Creds $ConnectionInfo.creds}
            elseif($MenuChoice -eq 4){RA_SQLStopDRTest -SourceFile $SQLDRTestPath -LogPath $LogPath -Creds $ConnectionInfo.creds}
            elseif($MenuChoice -eq 5){RA_InstantRecoverVMsCSV -SourceFile $DRFailoverPath -Server $ConnectionInfo.server -Creds $ConnectionInfo.creds -LogPath $LogPath}
            elseif($MenuChoice -eq 6){RA_InstantRecoverVM -Server $ConnectionInfo.server -Creds $ConnectionInfo.creds -LogPath $LogPath}
            elseif($MenuChoice -eq 7){RA_VMOnDemandFromCSV -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -LogPath $LogPath -SourceFile $VMListPath}
            elseif($MenuChoice -eq 8){RA_VMOnDemand -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -LogPath $LogPath}
            elseif($MenuChoice -eq 9){RA_Verify_VMBackup -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -LogPath $LogPath}
            elseif($MenuChoice -eq 10){RA_Search_Download_From_Fileset -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds}
            elseif($MenuChoice -eq 0){Exit}
            Else{
                Write-Host "Invalid Menu Selction.  Please try again."
                $MenuChoice -eq -1
                }
            }while($MenuChoice = -1)
      }while($MenuLoop -eq 1)
}


function RA_VMDRTest{
    <#  
      .SYNOPSIS
      Function to allow user to Import CSV File with Vmware VMs and mount the vms with csv specified parameters

      .DESCRIPTION
      Function to allow user to Import CSV File with Vmware VMs and mount the vms with csv specified parameters

      .NOTES
      Written by Jeremy Cathey for community usage

      .EXAMPLE  RA_VMDRTest -SourceFile "VMDRTest.csv"
    #>
    param($SourceFile, $LogPath, $Creds)
    
    $csv = Import-Csv $SourceFile

    foreach($item in $csv){
        $VMName = $item.VMName
        $RemoveNetworkDevices = $item.RemoveNetworkDevices
        $PowerOn = $item.PowerOn

        if(($RemoveNetworkDevices -eq 'True') -and ($PowerOn -eq 'True')){
            Get-RubrikVM -Name $VMName | Get-RubrikSnapshot -Latest | New-RubrikMount -DisableNetwork -PowerOn
            $LogDateTime = Get-Date -Format “dddd MM/dd/yyyy HH:mm:ss”
            $log = $LogDateTime + ' - ' + $VMName + ' successfully mounted'+'. -> User='+$Creds.username
            $log | Out-File -FilePath $LogPath -Append
            Write-host $VMName + " successfully mounted."
        }elseif(($RemoveNetworkDevices -eq 'True') -and ($PowerOn -eq 'False')){
            Get-RubrikVM -Name $VMName | Get-RubrikSnapshot -Latest | New-RubrikMount -DisableNetwork
            $LogDateTime = Get-Date -Format “dddd MM/dd/yyyy HH:mm:ss”
            $log = $LogDateTime + ' - ' + $VMName + ' successfully mounted'+'. -> User='+$Creds.username
            $log | Out-File -FilePath $LogPath -Append
            Write-host $VMName + " successfully mounted."
        }elseif(($RemoveNetworkDevices -eq 'False') -and ($PowerOn -eq 'True')){
            Get-RubrikVM -Name $VMName | Get-RubrikSnapshot -Latest | New-RubrikMount -PowerOn
            $LogDateTime = Get-Date -Format “dddd MM/dd/yyyy HH:mm:ss”
            $log = $LogDateTime + ' - ' + $VMName + ' successfully mounted'+'. -> User='+$Creds.username
            $log | Out-File -FilePath $LogPath -Append
            Write-host $VMName + " successfully mounted."
        }elseif((RemoveNetworkDevices -eq 'False') -and ($PowerOn -eq 'False')){
            Get-RubrikVM -Name $VMName | Get-RubrikSnapshot -Latest | New-RubrikMount
            $LogDateTime = Get-Date -Format “dddd MM/dd/yyyy HH:mm:ss”
            $log = $LogDateTime + ' - ' + $VMName + ' successfully mounted'+'. -> User='+$Creds.username
            $log | Out-File -FilePath $LogPath -Append
            Write-host $VMName + " successfully mounted."
        }
    }
}


function RA_VMStopDRTest{
    <#  
      .SYNOPSIS
      Function to allow user to Import CSV File with Vmware VMs and umount the vms previously mounted by the RA_VMDRTest function call

      .DESCRIPTION
      Function to allow user to Import CSV File with Vmware VMs and umount the vms previously mounted by the RA_VMDRTest function call

      .NOTES
      Written by Jeremy Cathey for community usage

      .EXAMPLE  RA_VMStopDRTest -SourceFile "VMDRTest.csv"
    #>
    param($SourceFile, $LogPath, $Creds)

    $csv = Import-Csv $SourceFile

    foreach($item in $csv){
        $VMName = $item.VMName
        Get-RubrikMount -VMID (Get-RubrikVM -VM $VMName).id | Remove-RubrikMount
        $LogDateTime = Get-Date -Format “dddd MM/dd/yyyy HH:mm:ss”
        $log = $LogDateTime + ' - ' + $VMName + ' successfully un-mounted'+'. -> User='+$Creds.username
        $log | Out-File -FilePath $LogPath -Append
        Write-Host $VMName + ' successfully un-mounted.'
    }         
}


function RA_SQLDRTest{
    <#  
      .SYNOPSIS
      Function to allow user to Import CSV File with SQL DBs and mount the databases to CSV specified hosts with csv specified parameters

      .DESCRIPTION
      Function to allow user to Import CSV File with SQL DBs and mount the databases to CSV specified hosts with csv specified parameters

      .NOTES
      Written by Jeremy Cathey for community usage

      .EXAMPLE  RA_SQLDRTEST -SourceFile "SQLDRTest.csv"
    #>
    param($SourceFile, $LogPath, $Creds)
    
    $csv = Import-Csv $SourceFile
    $count = 0
    foreach($item in $csv){
        $SourceSQLServerInstance = $item.SourceSQLServerInstance
        $SourceSQLDatabaseName = $item.SourceSQLDatabaseName
        $TargetSQLServerInstance = $item.TargetSQLServerInstance
        $LiveMountName = $item.LiveMountName
        if($count -le 25){
            # Get database information from Rubrik
            $RubrikDatabase = Get-RubrikDatabase -Name $SourceSQLDatabaseName -ServerInstance $SourceSQLServerInstance

            #Mount a database to a SQL Server
            $TargetInstance = Get-RubrikSQLInstance -ServerInstance $TargetSQLServerInstance
            $RubrikRequest = New-RubrikDatabaseMount -id $RubrikDatabase.id `
	            -TargetInstanceId $TargetInstance.id `
	            -MountedDatabaseName $LiveMountName `
	            -recoveryDateTime (Get-date (Get-RubrikDatabase -id $RubrikDatabase.id).latestRecoveryPoint) `
               -Confirm:$false
                $LogDateTime = Get-Date -Format “dddd MM/dd/yyyy HH:mm:ss”
                $log = $LogDateTime + ' - ' + $item.SourceSQLDatabaseName + ' successfully mounted on host: '+$item.TargetSQLServerInstance+' as '+$item.LiveMountName+'. -> User='+$Creds.username
                $log | Out-File -FilePath $LogPath -Append 
                Write-Host $item.SourceSQLDatabaseName + ' successfully mounted on host: ' + $item.TargetSQLServerInstance + ' as ' + $item.LiveMountName '.'
            #If you want to see progress of each individual task
            Get-RubrikRequest -id $RubrikRequest.id -Type mssql
        }else{
                # Get database information from Rubrik
                $RubrikDatabase = Get-RubrikDatabase -Name $SourceSQLDatabaseName -ServerInstance $SourceSQLServerInstance

                #Mount a database to a SQL Server
                $TargetInstance = Get-RubrikSQLInstance -ServerInstance $TargetSQLServerInstance
                $RubrikRequest = New-RubrikDatabaseMount -id $RubrikDatabase.id `
	                -TargetInstanceId $TargetInstance.id `
	                -MountedDatabaseName $LiveMountName `
	                -recoveryDateTime (Get-date (Get-RubrikDatabase -id $RubrikDatabase.id).latestRecoveryPoint) `
                -Confirm:$false
                $LogDateTime = Get-Date -Format “dddd MM/dd/yyyy HH:mm:ss”
                $log = $LogDateTime + ' - ' + $item.SourceSQLDatabaseName + ' successfully mounted on host: '+$item.TargetSQLServerInstance+' as '+$item.LiveMountName+'. -> User='+$Creds.username
                $log | Out-File -FilePath $LogPath -Append 
                Write-Host $item.SourceSQLDatabaseName + ' successfully mounted on host: ' + $item.TargetSQLServerInstance + ' as ' + $item.LiveMountName '.'
                #If you want to see progress of each individual task
                Get-RubrikRequest -id $RubrikRequest.id -Type mssql
                
                $count = 0
                Start-Sleep 120  
        }
    }
}   


function RA_SQLStopDRTest{
    <#  
      .SYNOPSIS
      Function to allow user to Import CSV File with SQL DBs and unmount the databases (previously mounted with SQLDRTest Function call).

      .DESCRIPTION
      Function to allow user to Import CSV File with SQL DBs and unmount the databases (previously mounted with SQLDRTest Function call).

      .NOTES
      Written by Jeremy Cathey for community usage

      .EXAMPLE  RA_SQLSTOPDRTEST -SourceFile "SQLDRTest.csv"
    #>
    param($SourceFile, $Creds)

    #Import CSV File with SQL DBs
    $csv = Import-Csv $SourceFile
    $count = 0
    foreach($item in $csv){
        $SourceSQLServerInstance = $item.SourceSQLServerInstance
        $SourceSQLDatabaseName = $item.SourceSQLDatabaseName
        $TargetSQLServerInstance = $item.TargetSQLServerInstance
        $LiveMountName = $item.LiveMountName
        $count = $count + 1
        # Get database information from Rubrik
        if($count  -le 25){
        $RubrikDatabase = Get-RubrikDatabase -Name $SourceSQLDatabaseName -ServerInstance $SourceSQLServerInstance

        #Get TargetInstance
        $TargetInstance = Get-RubrikSQLInstance -ServerInstance $TargetSQLServerInstance

        #Unmount a database from SQL Server
        $RubrikDatabaseMount = Get-RubrikDatabaseMount -MountedDatabaseName $LiveMountName -TargetInstanceId $TargetInstance.id
        $RubrikRequest = Remove-RubrikDatabaseMount -id $RubrikDatabaseMount.id -Confirm:$false
                $LogDateTime = Get-Date -Format “dddd MM/dd/yyyy HH:mm:ss”
                $log = $LogDateTime + ' - ' + $item.LiveMountName + ' successfully un-mounted on host: '+$item.TargetSQLServerInstance+'. -> User='+$Creds.username
                $log | Out-File -FilePath $LogPath -Append 
                Write-Hhost $item.LiveMountName + ' successfully un-mounted on host: ' + $item.TargetSQLServerInstance + '.'
        #If you want to see progress of each individual task
        Get-RubrikRequest -id $RubrikRequest.id -Type mssql    
        }else{
           $RubrikDatabase = Get-RubrikDatabase -Name $SourceSQLDatabaseName -ServerInstance $SourceSQLServerInstance

           #Get TargetInstance
           $TargetInstance = Get-RubrikSQLInstance -ServerInstance $TargetSQLServerInstance

           #Unmount a database from SQL Server
           $RubrikDatabaseMount = Get-RubrikDatabaseMount -MountedDatabaseName $LiveMountName -TargetInstanceId $TargetInstance.id
           $RubrikRequest = Remove-RubrikDatabaseMount -id $RubrikDatabaseMount.id -Confirm:$false
                $LogDateTime = Get-Date -Format “dddd MM/dd/yyyy HH:mm:ss”
                $log = $LogDateTime + ' - ' + $item.LiveMountName + ' successfully un-mounted on host: '+$item.TargetSQLServerInstance+'. -> User='+$Creds.username
                $log | Out-File -FilePath $LogPath -Append 
                Write-Hhost $item.LiveMountName + ' successfully un-mounted on host: ' + $item.TargetSQLServerInstance + '.'
           #If you want to see progress of each individual task
           Get-RubrikRequest -id $RubrikRequest.id -Type mssql   
           $count = 0
           Start-Sleep 120
        }
    }
}


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


function RA_VMOnDemandFromCSV{
<#  
      .SYNOPSIS
      Function to allow user to take on-demand snapshot of multiple VMs from a source CSV file

      .DESCRIPTION
      The RA_VMOnDemand function is used to read VMs from a CSV file and connect to a Rubrik Cluster and take on-demand backups for each VM.

      .NOTES
      Written by Jeremy Cathey for community usage

      .EXAMPLE  RA_VMOnDemandFromCSV -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -SourceFile "VMList.csv" -LogPath $LogPath
#>
    param($URI, $Creds, $SourceFile, $LogPath)
    $auth = RA_GetAPIAuth -Creds $Creds
    #Import CSV file that contains a list of VMs process
    $csv = Import-Csv $SourceFile
    #loop through each row of the CSV file and take the on-demand snapshot for each VM
    foreach($item in $csv){
        $VMName = $item.VMName
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
        Write-Host "On-Demand snapshost is scheduled for " + $VMDetails.name + "."
    }
}


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


function RA_Restore_From_Fileset_To_SourceServer{
    <#  
      .SYNOPSIS
      Function to allow user to search fileset for file and download to a user specified destination
      .DESCRIPTION
      The RA_Restore_From_Fileset_To_SourceServer function is used to call the fileset API for a file search and download to a user specified destination on the source server
      .NOTES
      Written by Jeremy Cathey for community usage
      .EXAMPLE  RA_Restore_From_Fileset_To_SourceServer -URI $Server -APIToken $Token -FS_Name "FS-am1-jerecath-w1" -Host_Name "am1-jerecath-w1" -File2Download "Where Am I.txt" -DestPath "C:\Scripts\"
    #>

    param($URI, $Creds, $FS_Name, $Host_Name, $File2Download, $DestPath)
    $auth = RA_GetAPIAuth -Creds $Creds
    $FS = Get-RubrikFileset -Name $FS_Name -HostName $Host_Name
    $FSID = $FS.id
    $FS_Snap = Get-RubrikSnapshot -id $FSID -Latest
    $FS_SnapID = $FS_Snap.id
$APIHeaders = @{
                'Authorization' = "Basic $auth"
                }
    #=====Search File Section=====
    $FS_params = @{
        Uri = 'https://' + $URI + '/api/v1/fileset/' + $FSID + '/search?path=' + $File2Download
        Headers = $APIHeaders
        Method = 'GET'
        ContentType = 'application/json'
    }
    $FS_Call = Invoke-RestMethod @FS_params
    #=====End of Search File Section=====
    
    #=====Restore File Section (Download to directory)=====
    $RF_BodyText = @{
                     sourceDir = $FS_Call.data[0].path
                     destinationDir = $DestPath
                     }
    $RF_JSON = $RF_BodyText | ConvertTo-Json
    Write-Output $RF_JSON
    $RF_params = @{
        Uri = 'https://'+ $URI + '/api/v1/fileset/snapshot/' + $FS_SnapID + '/restore_file'
        Headers= $APIHeaders
        Method = 'POST'
        Body = $RF_JSON
        ContentType = 'application/json'
    }
    $RF_Call = Invoke-RestMethod @RF_params
    #=====End of Restore File Section=====
    
}


function RA_Search_Download_From_Fileset{
    param($URI, $Creds)

    #Create Auth for Basic API Authentication
    $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Creds.UserName + ':' + $Creds.GetNetworkCredential().Password))

    #Create API Header with basic authorization and user input credentials
    $APIHeaders = @{
                'Authorization' = "Basic $auth"
                }
    #Create $Address to simplify Uri calls
    $Address = 'https://'+$URI

    $FS_Name = Read-Host -Prompt 'Enter name of the Fileset you wish to search: '
    $Host_Name = Read-Host -Prompt 'Enter name of the host server: '
    $File2Download = Read-Host -Prompt 'Enter full name of file to search for (example: samplefile.txt): '
    $DestPath = Read-Host -Prompt 'Enter path to download file to (example: C:\File Downloads\): '

    #Gather ID of Fileset and latest snapshot
    $FS = Get-RubrikFileset -Name $FS_Name -HostName $Host_Name
    $FSID = $FS.id
    $FS_Snap = Get-RubrikSnapshot -id $FSID -Latest
    $FS_SnapID = $FS_Snap.id

    #=====Search File Section=====
    $FS_params = @{
        Uri = $Address + '/api/v1/fileset/' + $FSID + '/search?path=' + $File2Download
        Headers = $APIHeaders
        Method = 'GET'
        ContentType = 'application/json'
    }
    $FS_Call = Invoke-RestMethod @FS_params
    #=====End of Search File Section=====

    #=====Restore File Section (download link in UI)=====
    $RF_BodyText = @{sourceDir = $FS_Call.data[0].path}
    $RF_JSON = $RF_BodyText | ConvertTo-Json

    $RF_params = @{
        Uri = $Address + '/api/v1/fileset/snapshot/' + $FS_SnapID + '/download_file'
        Headers= $APIHeaders
        Method = 'POST'
        Body = $RF_JSON
        ContentType = 'application/json'
    }
    $RF_Call = Invoke-RestMethod @RF_params

    Write-Host 'File download operation is: ' $RF_Call.status
    Write-Host 'Preparing download link...'
    #=====End of Restore File Section=====

    #Build Download Link for Files (check status before fetching)
    $F_ID = $RF_Call.id -replace ".{4}$" #drop last 4 chars
    $F_Link = [System.Text.StringBuilder]::new();
    $F_Link.Append($Address);
    $F_Link.Append('/download_dir/'); 
    $F_Link.Append([uri]::EscapeDataString($F_ID).ToString());
    $F_Link.Append('/');
    $F_Link.Append([uri]::UnescapeDataString($File2Download).ToString());
    $OutFile = $DestPath+$File2Download

    #Check Status of Async Download Request
    $AsyncStatus_params = @{
        Uri = $Address + '/api/v1/fileset/request/' + $RF_Call.id
        Headers= $APIHeaders
        Method = 'GET'
        ContentType = 'application/json'
    } 
    $AsyncStatus_Call = Invoke-RestMethod @AsyncStatus_params
    Write-Host $AsyncStatus_Call.status

    #Check status of Async Download Request until status shows complete aka "SUCCEEDED"
    $statusCount = 0
    Do{$AsyncStatus_Call = Invoke-RestMethod @AsyncStatus_params
       if($StatusCount -lt 21){Write-Host -NoNewline '. '
                               $statusCount = $statusCount+1}else{Write-Host '.'
                                                             $statusCount = 0}}While($AsyncStatus_Call.status -ne 'SUCCEEDED')
    Write-Host ''
    Write-Host 'File download link successfully generated...'
    Write-Host 'Proceeding to download file to destination directory...'
    Write-host 'Retriving file from: ' $F_Link.ToString() ' and downloading to ' $OutFile

   Invoke-WebRequest -Uri $F_Link.ToString() -OutFile $OutFile -Credential $Creds

<##>
}


function RA_GQL_VMDetails{
    param($URI, $Creds, $VMName)
    #Create Auth for Basic API Authentication
    $auth = RA_GetAPIAuth -Creds $Creds
    $headers = @{
        'Content-Type'  = 'application/json';
        'Accept'        = 'application/json';
        'Authorization' = "Basic $auth";
    }
    $endpoint = 'https://' + $URI + '/api/internal/graphql'
    # Get number of vms Protected
    $payload = @{
        "operationName" = "FindVMDetails";
        "query"         = "query FindVMDetails(`$vmName: String!)
                          {
                           vmwareVirtualMachineConnection(name:`$vmName) 
                            {
                                    nodes{
                                       name
                                       id
                                       guestOsName
                                       hostName
                                       hostId
                                       effectiveSlaDomain{
                                            name
                                            id
                                          }
                                      }
                            }
                          }";
                            
                         "variables" = @{"vmName" = "$VMName";}
                 }

    $response = Invoke-RestMethod -Method POST -Uri $endpoint -Body $($payload | ConvertTo-JSON -Depth 100) -Headers $headers

    $VMDetails = @([pscustomobject]@{name=$response.data.vmwareVirtualMachineConnection.nodes.name;
                                     id=$response.data.vmwareVirtualMachineConnection.nodes.id;
                                     guestOsName = $response.data.vmwareVirtualMachineConnection.nodes.guestOsName;
                                     hostName = $response.data.vmwareVirtualMachineConnection.nodes.hostName;
                                     hostid = $response.data.vmwareVirtualMachineConnection.nodes.hostId;
                                     slaname = $response.data.vmwareVirtualMachineConnection.nodes.effectiveSlaDomain.name;
                                     slaid = $response.data.vmwareVirtualMachineConnection.nodes.effectiveSlaDomain.id;})

    return $VMDetails
    }


Function RA_Connect_Creds{
        
        #Gather Rubrik Cluster FQDN/IP
        $Server = Read-Host -Prompt "Enter fQDN/IP of Rubrik Cluster: "
        #Gather Rubrik Credentials & Connect-Rubrik with Secure Username/Password
        $Credentials = Get-Credential -Message 'Enter Rubrik Credentials'
        $rbkConnect = Connect-Rubrik -Server $Server -Username $Credentials.UserName -Password $Credentials.Password
        $ConnectionInfo = @([pscustomobject]@{
            creds = $Credentials;
            server = $Server;
        })

        return $ConnectionInfo
    } 


Function RA_GetAPIAuth{
    param($Creds)
        $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Creds.UserName + ':' + $Creds.GetNetworkCredential().Password))
        return $auth
    }