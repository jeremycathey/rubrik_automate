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
    Write-Host ""
}   
