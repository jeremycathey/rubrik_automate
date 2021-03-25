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
    param([parameter(Mandatory=$true)]$SourceFile, [parameter(Mandatory=$true)]$Creds, [parameter(Mandatory=$true)]$LogPath)

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
                Write-Host $item.LiveMountName + ' successfully un-mounted on host: ' + $item.TargetSQLServerInstance + '.'
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
    pause
    Write-Host ""
}
