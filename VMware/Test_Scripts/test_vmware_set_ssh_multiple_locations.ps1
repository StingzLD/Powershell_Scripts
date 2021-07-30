################################################################################
# The purpose of this script is to either enable or disable the SSH service on
# ALL of the VMware hosts for the specified environments.
#
# This script is custom designed for a multi-location company, where each
# location is a subdomain of the main company domain. Some locations have their
# own vCenter appliance (e.g., appliance.location.company.com), others use the
# main locations' vCenter (e.g., appliance.main.company.com), and a few utilize
# both their on-site and the main location's vCenter. All of the hosts at the
# specified location will have their SSH service disabled/enabled with this
# script.
#
#
# ****************************** IMPORTANT NOTES *******************************
# This script requires the installation of the PowerCLI module. If this is not
# yet installed on this machine, open PowerShell and run the following command:
# Install-Module VMware.PowerCLI
#
# There are three CSVs required for this script, all of which contain the
# locations in a single column with a Header of 'Name':
# csv1 = list of target locations
# csv2 = full list of all locations using an on-site vCenter
# csv3 = full list of all locations using the main location's vCenter
#
# You will also need to define the following System Environment Variables:
# VCENTER = The appliances hostname ('appliance' in the example above)
# VCENTER_DOMAIN = The company's domain ('company.com' in the example above)
# VCENTER_MAIN = The main location's vCenter appliance's FQDN
################################################################################

# Variables defined from System Environment Variables
$vcenter = $env:VCENTER
$domain = $env:VCENTER_DOMAIN
$vcenter_main = $env:VCENTER_MAIN


# Starts a timer for script runtime
# Uncomment the code inside the function, if you wish to time the script
function startTimer {
#    $(Get-Date)
}


# Stops the timer and prints the runtime
# Uncomment the code inside the function, if you wish to time the script
function stopTimer {
#    $timerStop = $(Get-Date) - $timerStart
#    $timerTotal = "{0:HH:mm:ss}" -f ([datetime]$timerStop.Ticks)
#    Write-Host "This script completed in $timerTotal"
}


# Formatted choice selection text
function chooseOptionText {
    Write-Host "`nPlease enter '" -NoNewline
    Write-Host "e" -ForegroundColor Cyan -NoNewline
    Write-Host "' to " -NoNewline
    Write-Host "enable " -ForegroundColor Green -NoNewline
    Write-Host "SSH or '" -NoNewline
    Write-Host "d" -ForegroundColor Cyan -NoNewline
    Write-Host "' to " -NoNewline
    Write-Host "disable " -ForegroundColor DarkGray -NoNewline
    Write-Host "SSH"
}


# Get input from user on whether to enable or disable SSH
function getUserInput {
    # Determine if SSH is to be enabled or disabled
    chooseOptionText
    $userInput = Read-Host

    # If input is invalid, retry until input is valid
    do {
        if (($userInput -ne 'e') -and ($userInput -ne 'd')){
            Write-Host "`n***** Incorrect character selected *****" -ForegroundColor Red -NoNewline
            chooseOptionText
            $userInput = Read-Host
        }
    } until (($userInput -eq 'e') -or ($userInput -eq 'd'))
}


# Enables SSH at locations with on-site vCenters
function Enable-SSH {
    Param (
        [string[]]$Location
    )

    # Start the SSH service
    try{
#        Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" |
#                Start-VMHostService -Confirm:$false -ErrorAction Stop

        Write-Host "$Location " -ForegroundColor Cyan -NoNewline
        Write-Host "SSH " -NoNewline
        Write-Host "Enabled" -ForegroundColor Green
    }
    catch {
        Write-Host "***** Enabling SSH for " -ForegroundColor Red -NoNewline
        Write-Host "$Location " -ForegroundColor Blue -NoNewline
        Write-Host "failed *****" -ForegroundColor Red
    }

    # Enable the SSH service policy
    try {
#        Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" |
#                Set-VMHostService -Policy "on" -Confirm:$false -ErrorAction Stop

        Write-Host "$Location " -ForegroundColor Cyan -NoNewline
        Write-Host "SSH Policy " -NoNewline
        Write-Host "Enabled" -ForegroundColor Green
    }
    catch {
        Write-Host "***** Enabling SSH Policy for " -ForegroundColor Red -NoNewline
        Write-Host "$Location " -ForegroundColor Blue -NoNewline
        Write-Host "failed *****" -ForegroundColor Red
    }
}


# Disables SSH at locations with on-site vCenters
function Disable-SSH {
    Param (
        [string[]]$Location
    )

    # Stop the SSH service
    try {
#        Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" |
#                Stop-VMHostService -Confirm:$false  -ErrorAction Stop

        Write-Host "$Location " -ForegroundColor Cyan -NoNewline
        Write-Host "SSH " -NoNewline
        Write-Host "Disabled" -ForegroundColor DarkGray
    }
    catch {
        Write-Host "***** Disabling SSH for " -ForegroundColor Red -NoNewline
        Write-Host "$Location " -ForegroundColor Blue -NoNewline
        Write-Host "failed *****" -ForegroundColor Red
    }

    # Disable the SSH service policy
    try {
#        Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" |
#                Set-VMHostService -Policy "off" -Confirm:$false -ErrorAction Stop

        Write-Host "$Location " -ForegroundColor Cyan -NoNewline
        Write-Host "SSH Policy " -NoNewline
        Write-Host "Disabled" -ForegroundColor DarkGray
    }
    catch {
        Write-Host "***** Disabling SSH Policy for " -ForegroundColor Red -NoNewline
        Write-Host "$Location " -ForegroundColor Blue -NoNewline
        Write-Host "failed *****" -ForegroundColor Red
    }
}


# Enables SSH at locations using the main location's vCenter
function Enable-SSH-MAIN {
    Param (
        [string[]]$Location
    )

    # Start the SSH service
    try {
#        Get-DataCenter $Location | Get-VMHost | Get-VMHostService |
#                Where-Object Key -eq "TSM-SSH" |
#                Start-VMHostService -Confirm:$false -ErrorAction Stop

        Write-Host "`n$Location " -ForegroundColor Cyan -NoNewline
        Write-Host "at Main SSH " -NoNewline
        Write-Host "Enabled" -ForegroundColor Green
    }
    catch {
        Write-Host "***** Enabling SSH for " -ForegroundColor Red -NoNewline
        Write-Host "$Location " -ForegroundColor Blue -NoNewline
        Write-Host "at Main failed *****" -ForegroundColor Red

    }

    # Enable the SSH service policy
    try {
#        Get-DataCenter $Location |Get-VMHost | Get-VMHostService |
#                Where-Object Key -eq "TSM-SSH" |
#                Set-VMHostService -Policy "on" -Confirm:$false -ErrorAction Stop

        Write-Host "$Location " -ForegroundColor Cyan -NoNewline
        Write-Host "at Main SSH Policy " -NoNewline
        Write-Host "Enabled" -ForegroundColor Green
    }
    catch {
        Write-Host "***** Enabling SSH Policy for " -ForegroundColor Red -NoNewline
        Write-Host "$Location " -ForegroundColor Blue -NoNewline
        Write-Host "at Main failed *****" -ForegroundColor Red
    }
}


# Disables SSH at locations using the main location's vCenter
function Disable-SSH-MAIN {
    Param (
        [string[]]$Location
    )

    # Stop the SSH service
    try {
#        Get-DataCenter $Location | Get-VMHost | Get-VMHostService |
#                Where-Object Key -eq "TSM-SSH" |
#                Stop-VMHostService -Confirm:$false -ErrorAction Stop

        Write-Host "`n$Location " -ForegroundColor Cyan -NoNewline
        Write-Host "at Main SSH " -NoNewline
        Write-Host "Disabled" -ForegroundColor DarkGray
    }
    catch {
        Write-Host "***** Disabling SSH for " -ForegroundColor Red -NoNewline
        Write-Host "$Location " -ForegroundColor Blue -NoNewline
        Write-Host "at Main failed *****" -ForegroundColor Red
    }

    # Disable the SSH service policy
    try{
#        Get-DataCenter $Location |Get-VMHost | Get-VMHostService |
#                Where-Object Key -eq "TSM-SSH" |
#                Set-VMHostService -Policy "off" -Confirm:$false -ErrorAction Stop

        Write-Host "$Location " -ForegroundColor Cyan -NoNewline
        Write-Host "at Main SSH Policy " -NoNewline
        Write-Host "Disabled" -ForegroundColor DarkGray
    }
    catch {
        Write-Host "***** Disabling SSH Policy for " -ForegroundColor Red -NoNewline
        Write-Host "$Location " -ForegroundColor Blue -NoNewline
        Write-Host "at Main failed *****" -ForegroundColor Red
    }
}


################################################################################
################################################################################
#                                                                              #
#                       THESE TWO FUNCTIONS MUST EXIST!!!                      #
#                                                                              #
#                  Only edit the code inside of the functions                  #
#                                                                              #
################################################################################
################################################################################

# Code to be executed on the local locations' vCenter appliances
function localLocationCode {
    # Enable/Disable SSH per user input
    if ($userInput -eq 'e') {
        Enable-SSH -Location $location
    }
    else {
        Disable-SSH -Location $location
    }
}


# Code to be executed on the main location's vCenter appliance
function mainLocationCode {
    if ($location -in $csv_locations_main.Name) {
        # Enable/Disable SSH per user input
        if ($userInput -eq 'e') {
            Enable-SSH-MAIN -Location $location
        }
        else {
            Disable-SSH-MAIN -Location $location
        }
    }
}


################################################################################
# **************************************************************************** #
################################################################################
#                                                                              #
#                    DO NOT MODIFY ANY OF THE CODE BELOW!!!                    #
#                                                                              #
################################################################################
# **************************************************************************** #
################################################################################

# Store credentials
$creds = Get-Credential

# Gather paths for CSVs
$csv1 = Read-Host "`nPlease enter full path for the CSV of target locations"
$csv2 = Read-Host "`nPlease enter full path for the CSV of locations using an on-site vCenter"
$csv3 = Read-Host "`nPlease enter full path for the CSV of locations using the main location's vCenter"

# Import CSVs as variables
$csv_locations = Import-Csv -Path $csv1
$csv_locations_vxrails = Import-Csv -Path $csv2
$csv_locations_main = Import-Csv -Path $csv3

# Get user input
getUserInput

# Start the runtime timer
$timerStart = startTimer

# Set SSH for hosts with a local vCenter appliance
foreach ($location in $csv_locations.Name) {

    if ($location -in $csv_locations_vxrails.Name) {
        $connected = $false

        try {
            # Conect to the location's vCenter applicance
            Write-Host "`nConnecting to $vcenter.$location.$domain..."
            Connect-VIServer "$vcenter.$location.$domain" -Credential $creds -ErrorAction Stop

            $connected = $true
        }
        catch {
            Write-Host "***** Connecting to " -ForegroundColor Red -NoNewline
            Write-Host "$vcenter.$location.$domain " -ForegroundColor Blue -NoNewline
            Write-Host "failed *****" -ForegroundColor Red
            Write-Host "***** The requested VC server is currently unavailable *****" -ForegroundColor Red
        }

        if ($connected -eq $true) {
            localLocationCode

            # Disconnect from the vCenter appliance
            Disconnect-VIServer "$vcenter.$location.$domain" -Confirm:$false
        }
    }
}

# Set SSH for hosts with a vCenter appliance at the main location
$connected = $false

try {
    # Conect to the main location's vCenter applicance
    Write-Host "`nConnecting to $vcenter_main..."
    Connect-VIServer $vcenter_main -Credential $creds -ErrorAction Stop

    $connected = $true
}
catch {
    Write-Host "***** Connecting to " -ForegroundColor Red -NoNewline
    Write-Host "$vcenter_main " -ForegroundColor Blue -NoNewline
    Write-Host "failed *****" -ForegroundColor Red
    Write-Host "***** The requested VC server is currently unavailable *****" -ForegroundColor Red
}

if ($connected -eq $true) {
    foreach ($location in $csv_locations.Name) {
        mainLocationCode
    }

    # Disconnect from the vCenter appliance
    Disconnect-VIServer $vcenter_main -Confirm:$false
}

# Stop the timer and print result
stopTimer
