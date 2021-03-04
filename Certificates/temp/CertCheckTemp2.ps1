$csvFile = '<insert path here>\CertList.csv'
$certAuth = '<insert certAuth server FQDN here>'

# Gather list of installed certificates in the Local Computer\Personal store
$remoteCerts = Invoke-Command -ComputerName $certAuth -Credential $cred -ScriptBlock {
    $certPath = "Certification Authority\<insert path here>\Issued Certificates"
    $certs = Get-Certificate $certPath
    $toDisplay = @()

    For ($i = 0; $i -lt 2; $i++) {
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
$remoteCerts | Export-Csv $csvFile -append