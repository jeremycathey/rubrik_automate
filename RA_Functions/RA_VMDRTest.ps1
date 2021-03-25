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
    Write-Host ""
}
