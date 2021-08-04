################################################################################
#
#                    <<< INSERT SCRIPT DESCRIPTION HERE >>>
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
# This script must be run as an administrator and requires the installation of
# the PowerCLI module. If this is not yet installed on this machine, open
# PowerShell and run the following command:  Install-Module VMware.PowerCLI
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
#
# A log is automatically created when running this script and is located at:
# C:\Program Files\WindowsPowerShell\Logs
################################################################################


################################################################################
#                                                                              #
#                   This section contains optional functions                   #
#                                                                              #
#          These functions must exist, but the contents can be edited          #
#                      or commented out, if not required                       #
#                                                                              #
################################################################################

# Parameters
param (
    # Typical "Credential" parameter
    [ValidateNotNull()]
    [PSCredential]
    [System.Management.Automation.CredentialAttribute()]
    $Credential = $null,

    # Allows user to specificy the Enable or Disable state
    [Parameter(HelpMessage = "Values are either 'Enable' or 'Disable'")]
    [ValidateSet("Enable", "Disable")]
    [string] $State = $null
)


# Starts a timer for script runtime
# Uncomment the code inside the function, if you wish to time the script
function startTimer
{
#    $(Get-Date)
}


# Stops the timer and prints the runtime
# Uncomment the code inside the function, if you wish to time the script
function stopTimer
{
#    $timerStop = $(Get-Date) - $timerStart
#    $timerTotal = "{0:HH:mm:ss}" -f ([datetime]$timerStop.Ticks)
#    Write-Host "This script completed in $timerTotal"
}


# Get input from user
function getUserInput
{
    # <<< IF YOU NEED USER INPUT, WRITE THE FUNCTION HERE >>>
    #
    #    THE RETURNED VALUE WILL BE STORED IN THE $userInput
    #    VARIABLE AND CAN BE USED IN YOUR HELPER FUNCTIONS

}


################################################################################
#                                                                              #
#                This section contains all of the editable code                #
#                                                                              #
#           All functions created in this section will be used in the          #
#             required *LocationCode functions in the next section             #
#                                                                              #
################################################################################

# <<< CREATE YOUR HELPER FUNCTIONS HERE >>>


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
function localLocationCode
{
    # <<< THIS CODE WILL RUN ON THE LOCAL VCENTER APPLIANCES >>>
}


# Code to be executed on the main location's vCenter appliance
function mainLocationCode
{
    # <<< THIS CODE WILL RUN ON THE MAIN VCENTER APPLIANCE >>>
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

# If the entered credentials are not valid, enter them again
function invalidCredentials
{
    Write-Host "***** Invalid user name or password *****" -ForegroundColor Red
    Write-Host "***** Please re-enter your credentials *****"
    # Log Output
    "***** Invalid user name or password *****" |
            timestamp | Tee-Object -FilePath $logFile -Append | Out-Null
    "***** Please re-enter your credentials *****" |
            timestamp | Tee-Object -FilePath $logFile -Append | Out-Null

    # Give the user a chance to read the message before login window pops up
    Start-Sleep -s 1

    $newCreds = Get-Credential
    $newCreds | timestamp | Tee-Object -FilePath $logFile -Append | Out-Null

    return $newCreds
}


# Error message if the VC server is unavailable
function serverUnavailable
{
    param (
        [string] $Location
    )

    Write-Host "***** Connecting to " -ForegroundColor Red -NoNewline
    Write-Host "$Location " -ForegroundColor Yellow -NoNewline
    Write-Host "failed *****" -ForegroundColor Red
    Write-Host "***** The requested VC server is currently unavailable *****" `
            -ForegroundColor Red
    # Log Output
    "***** Connecting to $Location failed *****" |
            timestamp | Tee-Object -FilePath $logFile -Append | Out-Null
    "***** The requested VC server is currently unavailable *****" |
            timestamp | Tee-Object -FilePath $logFile -Append | Out-Null
}


# Variables defined from System Environment Variables
$vcenter = $env:VCENTER
$domain = $env:VCENTER_DOMAIN
$vcenter_main = $env:VCENTER_MAIN

# Create new log file
$logPath = "C:\Program Files\WindowsPowerShell\Logs"
$logFile = "$logPath\$(Get-Date -Format "yyyyMMdd_HHmmss").txt"
If(!(test-path $logPath))
{
    New-Item -ItemType Directory -Force -Path $logPath | Out-Null
}
New-Item -ItemType File -Force -Path $logFile | Out-Null

# Create timestamp formatting
filter timestamp {"$(Get-Date -Format "yyyy-MM-dd HH:mm:ss"):  $_"}

# Gather paths for CSVs
$csv1 = Read-Host "`nPlease enter full path for the CSV of target locations"
$csv2 = Read-Host "`nPlease enter full path for the CSV of locations using an on-site vCenter"
$csv3 = Read-Host "`nPlease enter full path for the CSV of locations using the main location's vCenter"

# Import CSVs as variables
$csv_locations = Import-Csv -Path $csv1
$csv_locations_vxrails = Import-Csv -Path $csv2
$csv_locations_main = Import-Csv -Path $csv3

# Get user input
$userInput = getUserInput

# Store credentials
if (!$Credential)
{
    $creds = Get-Credential
    $creds | timestamp | Tee-Object -FilePath $logFile -Append | Out-Null
}
else
{
    $creds = $Credential
}

# Start the runtime timer
$timerStart = startTimer

# Set SSH for hosts with a local vCenter appliance
foreach ($location in $csv_locations.Name)
{
    $connectError = $null

    if ($location -in $csv_locations_vxrails.Name)
    {
        $connected = $false

        do
        {
            Clear-Variable connectError

            try
            {
                Write-Host "`nConnecting to $vcenter.$location.$domain..."
                # Log Output
                "Connecting to $vcenter.$location.$domain..." |
                        timestamp | Tee-Object -FilePath $logFile -Append |
                        Out-Null

                # Connect to the location's vCenter appliance
                $currentConnection = Connect-VIServer "$vcenter.$location.$domain" `
                        -Credential $creds -ErrorVariable connectError `
                        -ErrorAction Stop
                # Log Connection Details
                "Connected to: $($currentConnection.Name)" | timestamp |
                        Tee-Object -FilePath $logFile -Append | Out-Null
                "Port: $($currentConnection.Port)" | timestamp |
                        Tee-Object -FilePath $logFile -Append | Out-Null
                "User: $($currentConnection.User)" | timestamp |
                        Tee-Object -FilePath $logFile -Append | Out-Null

                $connected = $true
            }
            catch
            {
                # Log full error details
                $connectError | timestamp | Tee-Object -FilePath $logFile -Append |
                        Out-Null

                if ($connectError -match 'incorrect user name or password')
                {
                    $creds = invalidCredentials
                }
                elseif ($connectError -match 'Could not resolve the requested VC server')
                {
                    serverUnavailable "$vcenter.$location.$domain"
                }
            }
        } while ($connectError -match 'incorrect user name or password')

        if ($connected -eq $true)
        {
            localLocationCode

            Write-Host "Disconnecting from $vcenter.$location.$domain..."
            # Log Output
            "Disconnecting from $vcenter.$location.$domain..." |
                    timestamp | Tee-Object -FilePath $logFile -Append | Out-Null

            # Disconnect from the vCenter appliance
            Disconnect-VIServer "$vcenter.$location.$domain" -Confirm:$false

        }
    }
}

# Set SSH for hosts with a vCenter appliance at the main location
$connectError = $null
$connected = $false

do
{
    Clear-Variable connectError

    try
    {
        Write-Host "`nConnecting to $vcenter_main..."
        #Log Output
        "Connecting to $vcenter_main..." |
                timestamp | Tee-Object -FilePath $logFile -Append | Out-Null

        # Connect to the main location's vCenter appliance
        $currentConnection = Connect-VIServer $vcenter_main -Credential $creds `
                -ErrorVariable connectError -ErrorAction Stop
        # Log Connection Details
        "Connected to: $($currentConnection.Name)" | timestamp |
                Tee-Object -FilePath $logFile -Append | Out-Null
        "Port: $($currentConnection.Port)" | timestamp |
                Tee-Object -FilePath $logFile -Append | Out-Null
        "User: $($currentConnection.User)" | timestamp |
                Tee-Object -FilePath $logFile -Append | Out-Null

        $connected = $true
    }
    catch
    {
        # Log full error details
        $connectError | timestamp | Tee-Object -FilePath $logFile -Append | Out-Null

        if ($connectError -match 'incorrect user name or password')
        {
            $creds = invalidCredentials
        }
        elseif ($connectError -match 'Could not resolve the requested VC server')
        {
            serverUnavailable $vcenter_main
        }
    }
} while ($connectError -match 'incorrect user name or password')

if ($connected -eq $true)
{
    foreach ($location in $csv_locations.Name)
    {
        if ($location -in $csv_locations_main.Name)
        {
            mainLocationCode
        }
    }

    Write-Host "Disconnecting from $vcenter_main..."
    # Log Output
    "Disconnecting from $vcenter_main..." |
            timestamp | Tee-Object -FilePath $logFile -Append | Out-Null

    # Disconnect from the vCenter appliance
    Disconnect-VIServer $vcenter_main -Confirm:$false
}

# Stop the timer and print result
stopTimer
