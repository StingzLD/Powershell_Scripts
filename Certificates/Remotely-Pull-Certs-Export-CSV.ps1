Import-Module Find-WebServerAsync

$cred = Get-Credential

# Gather list of web servers on domain
$webServers = Get-ADComputer -Filter {enabled -eq $true} -Properties Name | Find-WebServerAsync -Quiet | where {$_.Success -eq $true}

# Gather list of installed certificates in the Local Computer\Personal store
$remoteCerts = Invoke-Command -ComputerName $webServers.Name -Credential $cred -ScriptBlock {
    $certPath = "Cert:\LocalMachine\My"
    $certs = Get-ChildItem $certPath
    $toDisplay = @()

    For ($i = 0; $i -lt $certs.Count; $i++) {
        $toDisplay += New-Object PSObject -Property @{
            'Number' = $i + 1
            'Name' = $certs[$i].DnsNameList
            'Expiration' = $certs[$i].NotAfter
            'Thumbprint' = $certs[$i].Thumbprint
        }
    }
    Return $toDisplay
}

# Export list of certificates to CSV
$remoteCerts | Export-Csv C:\RemoteCerts.csv -append
