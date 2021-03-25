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
    $Host_Name = Read-Host -Prompt 'Enter name of the fileset host: '
    $File2Download = Read-Host -Prompt 'Enter full name of file to search for (example: samplefile.txt): '
    $DestPath = Read-Host -Prompt 'Enter path to download file to (example: C:\File Downloads\): '

    #Gather ID of Fileset and latest snapshot
    $FS = Get-RubrikFileset -Name $FS_Name -HostName $Host_Name
    $FSID = $FS.id

    #=====Search File Section=====
    $FS_params = @{
        Uri = $Address + '/api/v1/fileset/' + $FSID + '/search?path=' + $File2Download
        Headers = $APIHeaders
        Method = 'GET'
        ContentType = 'application/json'
    }
    $FS_Call = Invoke-RestMethod @FS_params
    #=====End of Search File Section=====

    $PathCount = $FS_Call.data.path.count - 1
    if($PathCount -ne 0){
    Write-Host 'Multiple files found.'
    $PCount = 0
    Do{
        Write-Host $PCount '-' $FS_Call.data[$PCount].path
        $PCount = $PCount + 1
    }until($PCount -gt $PathCount)
    $PCount = Read-host -Prompt 'Please select file to recover'
    }else{$PCount = 0}

    #=====Restore File Section (download link in UI)=====
    $RF_BodyText = @{sourceDir = $FS_Call.data[$PCount].path}
    $RF_JSON = $RF_BodyText | ConvertTo-Json

    $RF_params = @{
        Uri = $Address + '/api/v1/fileset/snapshot/' + $FS_Call.data[$PCount].fileversions.snapshotId[0] + '/download_file'
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

   Invoke-WebRequest -Uri $F_Link.ToString() -OutFile $OutFile -Credential $Creds

   Write-Host 'File Downloaded Successfully -> Opening Directory'
   start $DestPath
<##>
}
