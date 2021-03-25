# rubrik_automate
Collection of scripts for Rubrik Automation
This is intended to make it easier to demonstrate the Rubrik API first ecosystem and allow prospects and existing customers to more easily see/use Rubrik's APIs for common tasks.

This will be an ongoing project with the next phase to include automatic code upgrades to the latest version.  Please stay tuned.  Feel free to let me know if there are any feature requests or modifications that you would like to see.

Download and place files in a directory of your choosing.  Modify the $ScriptPath variable in rubrik_automate.ps1 to reflect this directory and you should be good to go.

Notes:
The Rubrik PowerShell SDK is utilized and required (future release will remove dependency), so make sure this is installed.  
(https://github.com/rubrikinc/rubrik-sdk-for-powershell/blob/master/docs/quick-start.md)

The Sample CSV files contain sample names, so you will need to update them with appropriate VM/Server/DB information or replace with your own for testing.  
