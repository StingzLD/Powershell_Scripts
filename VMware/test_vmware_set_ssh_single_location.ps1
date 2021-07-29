###############################################################################
# The purpose of this script is to either enable or disable the SSH service on
# ALL of the VMware hosts for the specified environment.
#
# This script is designed for a multi-location company, where each location is
# a subdomain of the parent company, and each location has its own vCenter
# appliance (e.g., appliance.location.company.com). All hosts at the specified
# location will have the SSH service disabled/enabled with this script.
#
# This script is unique in that it assumes each location also has VMs for the
# specified location at the company parent's location. If this is not the case,
# please scroll down and comment out everything under the section labelled:
# COMMENT OUT THE SECTION BELOW IF NO VMS RESIDE AT THE PARENT'S LOCATION
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


function Enable-SSH {
    # # Start the SSH service
    # Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" |
    #     Start-VMHostService -Confirm:$false
    # # Enable the SSH service policy
    # Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" |
    #     Set-VMHostService -Policy "on" -Confirm:$false
    Write-Output "SSH Enabled"
}

function Disable-SSH {
    # # Stop the SSH service
    # Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" |
    #     Stop-VMHostService -Confirm:$false
    # # Disable the SSH service policy
    # Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" |
    #     Set-VMHostService -Policy "off" -Confirm:$false
    Write-Output "SSH Disabled"
}


# Store credentials
# $creds = Get-Credential

# Gather location from user
$location = Read-Host "`nPlease enter the location"

# Determine if SSH is to be enabled or disabled
$userInput = Read-Host "`nPlease enter 'e' to enable SSH or 'd' to disable SSH"
# If input is invalid, retry until input is valid
do {
    if (($userInput -ne 'e') -and ($userInput -ne 'd')){
        $userInput = Read-Host "`nIncorrect character selected. Please type either 'e' or 'd'"
    }
} until (($userInput -eq 'e') -or ($userInput -eq 'd'))


# Conect to the vCenter applicance
Connect-VIServer "$vcenter.$location.$domain" -Credential $creds


# Enable/Disable SSH per user input
if ($userInput -eq 'e') {
    Enable-SSH
}
else {
    Disable-SSH
}


# Disconnect from the vCenter appliance
Disconnect-VIServer "$vcenter.$location.$domain" -Confirm:$False


###############################################################################
# COMMENT OUT THE SECTION BELOW IF NO VMS RESIDE AT THE PARENT'S LOCATION
###############################################################################


# Variable defined from System Environment Variables
$vcenter_main = $env:VCENTER_MAIN


function Enable-SSH-MAIN {
    # # Stop the SSH service
    # Get-DataCenter $location | Get-VMHost | Get-VMHostService |
    #     Where-Object Key -eq "TSM-SSH" | Start-VMHostService -Confirm:$false
    # # Disable the SSH service policy
    # Get-DataCenter $location |Get-VMHost | Get-VMHostService | 
    #     Where-Object Key -eq "TSM-SSH" |
    #     Set-VMHostService -Policy "on" -Confirm:$false
    Write-Output "Main SSH Enabled"
}

function Disable-SSH-MAIN {
    # # Stop the SSH service
    # Get-DataCenter $location | Get-VMHost | Get-VMHostService |
    #     Where-Object Key -eq "TSM-SSH" | Stop-VMHostService -Confirm:$false
    # # Disable the SSH service policy
    # Get-DataCenter $location |Get-VMHost | Get-VMHostService | 
    #     Where-Object Key -eq "TSM-SSH" |
    #     Set-VMHostService -Policy "off" -Confirm:$false
    Write-Output "Main SSH Disabled"
}


# Conect to the vCenter applicance
Connect-VIServer $vcenter_main -Credential $creds


# Enable/Disable SSH per user input
if ($userInput -eq 'e') {
    Enable-SSH-MAIN
}
else {
    Disable-SSH-MAIN
}


# Disconnect from the vCenter appliance
Disconnect-VIServer $vcenter_main -Confirm:$false
