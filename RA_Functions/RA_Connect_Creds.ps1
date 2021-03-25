Function RA_Connect_Creds{
    #Gather Rubrik Cluster FQDN/IP
    param($ScriptPath)
    $Server = Read-Host -Prompt "Enter fQDN/IP of Rubrik Cluster: "

    ###############################################
    # Importing Rubrik credentials
    ###############################################
    # Setting credential file
    $RubrikCredentialsFile = $ScriptPath + "RubrikCredentials.xml"
    # Testing if file exists
    $RubrikCredentialsFileTest =  Test-Path $RubrikCredentialsFile
    # IF doesn't exist, prompting and saving credentials
    IF ($RubrikCredentialsFileTest -eq $False)
    {
    $RubrikCredentials = Get-Credential -Message "Enter Rubrik login credentials"
    $RubrikCredentials | EXPORT-CLIXML $RubrikCredentialsFile -Force
    }
    ELSE
    {
    # Importing credentials
    $RubrikCredentials = IMPORT-CLIXML $RubrikCredentialsFile
    }
    # Setting credentials
    $RubrikUser = $RubrikCredentials.UserName
    $RubrikPassword = $RubrikCredentials.Password

    $rbkConnect = Connect-Rubrik -Server $Server -Username $RubrikCredentials.UserName -Password $RubrikCredentials.Password
    $ConnectionInfo = @([pscustomobject]@{
        creds = $RubrikCredentials;
        server = $Server;
        })

        return $ConnectionInfo
} 
