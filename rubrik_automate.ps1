$ScriptPath = 'G:\My Drive\Scripts\Powershell\Rubrik_Automate\'
$FunctionPath = $ScriptPath + 'RA_Functions\RA_Functions.psm1'
Import-Module $FunctionPath

#Connect with Rubrik Cluster Using Username/Password (Basic Auth)
$ConnectionInfo = RA_Connect_Creds

#Present RubrikAutomate Menu for a menu driven system to LiveMount VMs and Databases via CSV Import
RA_Menu -ConnectionInfo $ConnectionInfo -ScriptPath $ScriptPath
