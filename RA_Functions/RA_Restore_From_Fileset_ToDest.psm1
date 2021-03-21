function RA_Restore_From_Fileset_ToDest{
    <#  
      .SYNOPSIS
      Function to allow user to search fileset for file and download to a user specified destination
      .DESCRIPTION
      The RA_Restore_From_Fileset_To_Dest function is used to call the fileset API for a file search and download to a user specified destination
      .NOTES
      Written by Jeremy Cathey for community usage
      .EXAMPLE  RA_Restore_From_Fileset_To_Dest -URI $Server -APIToken $Token -FS_Name "FS-am1-jerecath-w1" -Host_Name "am1-jerecath-w1" -File2Download "Where Am I.txt" -DestPath "C:\Scripts\"
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
