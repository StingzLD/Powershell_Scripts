Import-Module Find-WebServerAsync

$cred = Get-Credential

# Gather list of web servers on domain
$webServers = Get-ADComputer -Filter {enabled -eq $true} -Properties Name | Find-WebServerAsync -Quiet | where {$_.Success -eq $true}

# Gather list of installed websites and app pools in IIS
$version = Invoke-Command -ComputerName $webServers.Name -Credential $cred -ScriptBlock {
    $PSVersionTable.PSVersion
}

$version | Out-Host