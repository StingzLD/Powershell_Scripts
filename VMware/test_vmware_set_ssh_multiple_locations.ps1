###############################################################################
# The purpose of this script is to either enable or disable the SSH service on
# ALL of the VMware hosts for the specified environment.
#
# This script is designed for a multi-location company, where each location is
# a subdomain of the parent company, and each location has its own vCenter
# appliance (e.g., appliance.location.company.com). All hosts at the specified
# location will have the SSH service disabled/enabled with this script. This
# script also assumes each location also has VMs for the specified location at
# the company parent's location.
#
#
# ****************************** IMPORTANT NOTES ******************************
# This script requires the installation of the PowerCLI module. If this is not
# yet installed on this machine, open PowerShell and run the following command:
# Install-Module VMware.PowerCLI
#
# You will also need to define the following System Environment Variables:
# VCENTER = The appliances hostname ('appliance' in the example above)
# VCENTER_DOMAIN = The company's domain ('company.com' in the example above)
# VCENTER_MAIN = The parent location's vCenter appliance's FQDN
###############################################################################


# Variables defined from System Environment Variables
$vcenter = $env:VCENTER
$domain = $env:VCENTER_DOMAIN
$vcenter_main = $env:VCENTER_MAIN


function Enable-SSH {
    Param (
        [string[]]$Location
    )

    Write-Output "$Location SSH Enabled"

    # # Start the SSH service
    # Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" |
    #     Start-VMHostService -Confirm:$false
    # # Enable the SSH service policy
    # Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" |
    #     Set-VMHostService -Policy "on" -Confirm:$false

}

function Disable-SSH {
    Param (
        [string[]]$Location
    )

    Write-Output "$Location SSH Disabled"

    # # Stop the SSH service
    # Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" |
    #     Stop-VMHostService -Confirm:$false
    # # Disable the SSH service policy
    # Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" |
    #     Set-VMHostService -Policy "off" -Confirm:$false

}

function Enable-SSH-MAIN {
    Param (
        [string[]]$Location
    )

    Write-Output "$Location at Main SSH Enabled"

    # # Stop the SSH service
    # Get-DataCenter $Location | Get-VMHost | Get-VMHostService |
    #     Where-Object Key -eq "TSM-SSH" | Start-VMHostService -Confirm:$false
    # # Disable the SSH service policy
    # Get-DataCenter $Location |Get-VMHost | Get-VMHostService |
    #     Where-Object Key -eq "TSM-SSH" |
    #     Set-VMHostService -Policy "on" -Confirm:$false
}

function Disable-SSH-MAIN {
    Param (
        [string[]]$Location
    )

    Write-Output "$Location at Main SSH Disabled"

    # # Stop the SSH service
    # Get-DataCenter $Location | Get-VMHost | Get-VMHostService |
    #     Where-Object Key -eq "TSM-SSH" | Stop-VMHostService -Confirm:$false
    # # Disable the SSH service policy
    # Get-DataCenter $Location |Get-VMHost | Get-VMHostService |
    #     Where-Object Key -eq "TSM-SSH" |
    #     Set-VMHostService -Policy "off" -Confirm:$false
}


# Store credentials
$creds = Get-Credential


# Gather paths for CSVs
$csv1 = Read-Host "Please enter the full path for the CSV of vCenter locations"
$csv2 = Read-Host "Please enter the full path for the CSV of locations at main"

# Import CSVs as variables
$csv_locations = Import-Csv -Path $csv1
$csv_locations_main = Import-Csv -Path $csv2


# Determine if SSH is to be enabled or disabled
$userInput = Read-Host "`nPlease enter 'e' to enable SSH or 'd' to disable SSH"
# If input is invalid, retry until input is valid
do {
    if (($userInput -ne 'e') -and ($userInput -ne 'd')){
        $userInput = Read-Host "`nIncorrect character selected. Please type either 'e' or 'd'"
    }
} until (($userInput -eq 'e') -or ($userInput -eq 'd'))




foreach ($location in $csv_locations.Name) {
    # Conect to the location's vCenter applicance
    Connect-VIServer "$vcenter.$location.$domain" -Credential $creds

    # Enable/Disable SSH per user input
    if ($userInput -eq 'e') {
        Enable-SSH -Location $location
    }
    else {
        Disable-SSH -Location $location
    }

    # Disconnect from the vCenter appliance
    Disconnect-VIServer "$vcenter.$location.$domain" -Confirm:$False


    if ($location -in $csv_locations_main.Name) {
        # Conect to the main location's vCenter applicance
        Connect-VIServer $vcenter_main -Credential $creds

        # Enable/Disable SSH per user input
        if ($userInput -eq 'e') {
            Enable-SSH-MAIN -Location $location
        }
        else {
            Disable-SSH-MAIN -Location $location
        }

        # Disconnect from the vCenter appliance
        Disconnect-VIServer $vcenter_main -Confirm:$false
    }
}
