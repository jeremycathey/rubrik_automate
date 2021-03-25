    <#  
      .SYNOPSIS
      Function to search for a file in a vm or fileset and compare it's hash with another file to determine if the file has changed and/or was able to be restored successfully.
      .DESCRIPTION
      Function to search for a file in a vm or fileset and compare it's hash with another file to determine if the file has changed and/or was able to be restored successfully.
      .NOTES
      Written by Jeremy Cathey for community usage
      .EXAMPLE  RA_Verify_RestoredFile -URI $ConnectionInfo.server -Creds $ConnectionInfo.creds -LogPath $LogPath
    #>
Function RA_Verify_RestoredFile{
param([parameter(Mandatory=$true)]$URI,[parameter(Mandatory=$true)]$Creds,[parameter(Mandatory=$true)]$LogPath,[parameter(Mandatory=$false)]$File)
    if($File -eq $null){$File = Read-Host -Prompt 'Enter name of file to search, restore, and validate'}

    $OGFile = Read-Host -Prompt 'Enter path for the source file to compare against'
    $TestOGFile = Test-Path -Path $OGFile
    if($TestOGFile -eq $false){
        Write-Host 'File does not exist.  Try Again.'
        do{$OGFile = Read-Host -Prompt 'Enter path for the source file to compare against'
        $TestOGFile = Test-Path -Path $OGFile
        }while($TestOGFile -eq $false)
    }

    do{$SourceType = Read-host -Prompt 'Enter source type (Fileset or VM)'}until($SourceType -eq 'Fileset' -or $SourceType -eq 'VM')
    if($SourceType -eq 'Fileset'){
        $RFile = RA_Search_Download_From_Fileset -URI $URI -Creds $Creds -File2Download $File -OpenPath "False"
    }elseif($SourceType -eq 'VM'){
        $RFile = RA_Search_Download_From_VM -URI $URI -Creds $Creds -File2Download $File -OpenPath "False"
    }

    $RFile_Hash = Get-FileHash -Path $RFile -Algorithm SHA256
    $OGFile_Hash = Get-FileHash -Path $OGFile -Algorithm SHA256

    If($RFile_Hash.hash -eq $OGFile_Hash.hash){
       $LogDateTime = Get-Date -Format “dddd MM/dd/yyyy HH:mm:ss”
       $log = $LogDateTime + ' - File Hash Comparison is Successful for ' + $OGFile +'. -> User='+$Creds.username
       $log | Out-File -FilePath $LogPath -Append 
       $Message = "File Hash Comparison is Successful."
       Write-host ""
       Write-host "File Hash: "$OGFile_Hash.hash '- '$OGFile
       Write-Host "File Hash: "$RFile_Hash.hash '- '$RFile
       Write-host $Message
       pause
       Write-Host ""
    }else{
       $LogDateTime = Get-Date -Format “dddd MM/dd/yyyy HH:mm:ss”
       $log = $LogDateTime + ' - File Hash Comparison Failed for ' + $OGFile +'. -> User='+$Creds.username
       $log | Out-File -FilePath $LogPath -Append 
       $FailMessage = "File Hash Comparison Failed."
       Write-Host ""
       Write-host "File Hash: "$OGFile_Hash.hash '- '$OGFile
       Write-Host "File Hash: "$RFile_Hash.hash '- '$RFile
       Write-Host $FailMessage
       pause
       Write-Host ""
    }

}