Function RA_GetAPIAuth{
    param([parameter(Mandatory=$true)]$Creds)
        Try{$auth = [System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes($Creds.UserName + ':' + $Creds.GetNetworkCredential().Password))}
            catch{Write-Host 'Invalid Credential Format.  Exiting . . .'
                  exit}
        return $auth
    }