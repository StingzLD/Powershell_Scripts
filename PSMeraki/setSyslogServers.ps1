########################################################################################
# This script is used to set the Syslog Servers for specified Meraki networks.
# To use this script, you will need the following:
#     1) Your Organization ID
#     2) Your profile's API Key
#     3) JSON file with the specified Syslog Settings. For example:
#                {
#                    "servers": [
#                        {
#                            "host": "1.2.3.4",
#                            "port": "1234",
#                            "roles": [
#                                "Flows",
#                                "URLs",
#                                "Security events",
#                                "Appliance event log"
#                            ]
#                        }
#                    ]
#                }
#     4) CSV file with a single column called "name". Each line will contain the name
#        of the network you wish to apply the Syslog Settings to. For example:
#                name
#                HQ Network
#                Branch Network 1
#                Branch Network 2
########################################################################################

Import-Module PSMeraki -Force -PassThru


# Variables to set
$orgId = Read-Host "Please enter your Organization ID"
$mrkRestApiKey = Read-Host "Please enter your API Key"
$syslog_settings_file = Read-Host "Please enter the path to the Syslog Server Settings JSON"
$network_list_file = Read-Host "Please enter the path to the Network List"


# Set Meraki REST API Key
Set-MrkRestApiKey -key $mrkRestApiKey -Verbose


# JSON containing Syslog server settings
$syslogJSON = Get-Content $syslog_settings_file | Out-String

# Converts the JSON to a hash table the function can use
$hash = @{}
foreach ($property in ($syslogJSON | ConvertFrom-Json).PSObject.Properties) {
    $hash[$property.Name] = $property.Value
}


# Get list of networks for organization
$networks = Get-mrkNetwork -orgId $orgId

# Import list of networks to modify
$network_list = Import-Csv -Path $network_list_file

# Set the Syslog servers to the hash table for applicable networks
foreach ($network in $networks){
    foreach ($target_network in $network_list){
        if ($network.name -EQ $target_network.name){
            $network.name
            $network.id
            Invoke-MrkRestMethod -Method 'PUT' -ResourceID ('/networks/' + $network.id + '/syslogServers') -body $hash
        }
    }
}
