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
