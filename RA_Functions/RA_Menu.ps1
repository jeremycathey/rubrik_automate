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
            Write-Output "1.  VM DR Test (LiveMount) -> From CSV"
            Write-Output "2.  Stop VM DR Test (Unmount) -> From CSV"
            Write-Output "3.  SQL DR Test (LiveMount) -> From CSV"
            Write-Output "4.  End SQL DR Test (Unmount) -> From CSV"
            Write-Output "5.  Start Instant Recover (NOT A TEST) -> From CSV"
            Write-Output "6.  Start Instant Recover (NOT A TEST) -> Single VM"
            Write-Output "7.  Take On-Demand Snapshot of VMware VMs -> From CSV With Assigned SLA"
            Write-Output "8.  Take On-Demand Snapshot of VMware VM -> Single VM with Assigned SLA"
            Write-Output "9.  Verify Backup of VMware VM"
            Write-Output "10.  Search a fileset for a file and download to local machine"
            Write-Output "11.  Search a VM for a file and download to local machine"
            Write-Output "12.  Search a VM or Fileset for a file, download, and do a hash comparison to another file"
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
            elseif($MenuChoice -eq 11){RA_Search_Download_From_VM -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds}
            elseif($MenuChoice -eq 12){RA_Verify_RestoredFile -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -LogPath $LogPath}
            elseif($MenuChoice -eq 0){Exit}
            Else{
                Write-Host "Invalid Menu Selction.  Please try again."
                $MenuChoice -eq -1
                }
            }while($MenuChoice = -1)
      }while($MenuLoop -eq 1)
}
