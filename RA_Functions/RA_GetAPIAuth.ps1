Function RA_GetAPIAuth{
    param($Creds)
        $auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Creds.UserName + ':' + $Creds.GetNetworkCredential().Password))
        return $auth
    }