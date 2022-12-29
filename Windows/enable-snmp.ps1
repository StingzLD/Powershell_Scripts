[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $SNMPServer,

    [Parameter(Mandatory=$false)]
    [string]
    $List=""
)

if ($List -eq "") {
    $ComputerList = Get-Content (Read-Host "Enter path to list")
}
else {
    $ComputerList = $List
}

$parameters = @{
    Credential = Get-Credential
    ComputerName = $ComputerList
    ScriptBlock = {
        # Check to see if the SNMP Service feature is already installed
        $check = Get-WindowsFeature | Where-Object {$_.Name -eq "SNMP-Service"}
        # Install the SNMP Service feature if it is not already installed
        if ($check.Installed -ne "True") {
            Install-WindowsFeature SNMP-Service -IncludeAllSubFeature
        }
        # Set the SNMP Permitted Managers value
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\PermittedManagers" -Name "1" -Value $SNMPServer
        # Create new folder for the public SNMP community under Trap Configuration
        New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration\public" -Force
        # Set the allowed SNMP public SNMP community accept host value
        Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\SNMP\Parameters\TrapConfiguration\public" -Name "1" -Value $SNMPServer
    }
    AsJob = $true
}

Invoke-Command @parameters
