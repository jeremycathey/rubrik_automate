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
    Write-Host ""     
}
