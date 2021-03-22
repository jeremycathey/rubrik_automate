$ScriptPath = 'G:\My Drive\Scripts\Powershell\Rubrik_Automate\'

################################################
# Importing All Functions
################################################
$FunctionsDirectory = $ScriptPath + 'RA_Functions\'
$Functions = Get-ChildItem -Path $FunctionsDirectory -Recurse
# Adding each function
ForEach ($Function in $Functions)
{
# Setting path
$FullFunctionPath = $Function.FullName
# Importing
. $FullFunctionPath
}
################################################

#Connect with Rubrik Cluster Using Username/Password (Basic Auth)
$ConnectionInfo = RA_Connect_Creds -ScriptPath $ScriptPath

#Present RubrikAutomate Menu for a menu driven system to LiveMount VMs and Databases via CSV Import
RA_Menu -ConnectionInfo $ConnectionInfo -ScriptPath $ScriptPath
