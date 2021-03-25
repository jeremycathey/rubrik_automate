function RA_GQL_VMDetails{
    param([parameter(Mandatory=$true)]$URI, [parameter(Mandatory=$true)]$Creds, [parameter(Mandatory=$false)]$VMName)
    #Check if $VMName was provided and if not, get from user
    If($VMName -eq $null){$VMName = Read-Host -Prompt 'Enter name of VM'}
    $VMName = Get-RubrikVM -Name $VMName
    $VMName = $VMName.name
    If($VMName -eq $null){Write-Host 'VM not found. Exiting . . .'
      exit}

    #Create Auth for Basic API Authentication
    $auth = RA_GetAPIAuth -Creds $Creds
    $headers = @{
        'Content-Type'  = 'application/json';
        'Accept'        = 'application/json';
        'Authorization' = "Basic $auth";
    }
    $endpoint = 'https://' + $URI + '/api/internal/graphql'
    # Get number of vms Protected
    $payload = @{
        "operationName" = "FindVMDetails";
        "query"         = "query FindVMDetails(`$vmName: String!)
                          {
                           vmwareVirtualMachineConnection(name:`$vmName) 
                            {
                                    nodes{
                                       name
                                       id
                                       guestOsName
                                       hostName
                                       hostId
                                       effectiveSlaDomain{
                                            name
                                            id
                                          }
                                      }
                            }
                          }";
                            
                         "variables" = @{"vmName" = "$VMName";}
                 }

    $response = Invoke-RestMethod -Method POST -Uri $endpoint -Body $($payload | ConvertTo-JSON -Depth 100) -Headers $headers

    $VMDetails = @([pscustomobject]@{name=$response.data.vmwareVirtualMachineConnection.nodes.name;
                                     id=$response.data.vmwareVirtualMachineConnection.nodes.id;
                                     guestOsName = $response.data.vmwareVirtualMachineConnection.nodes.guestOsName;
                                     hostName = $response.data.vmwareVirtualMachineConnection.nodes.hostName;
                                     hostid = $response.data.vmwareVirtualMachineConnection.nodes.hostId;
                                     slaname = $response.data.vmwareVirtualMachineConnection.nodes.effectiveSlaDomain.name;
                                     slaid = $response.data.vmwareVirtualMachineConnection.nodes.effectiveSlaDomain.id;})

    return $VMDetails
    }
