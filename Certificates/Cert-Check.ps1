# Display installed certificates
$certPath = "Cert:\LocalMachine\My"

Write-Output "The currently installed certificates are:"

$certs = Get-ChildItem $certPath
$toDisplay = @()
for ($i = 0; $i -lt $certs.Count; $i++) {
    $toDisplay += New-Object PSObject -Property @{
        'Number' = $i + 1
        'Name' = $certs[$i].DnsNameList
        'Expiration' = $certs[$i].NotAfter
        'Thumbprint' = $certs[$i].Thumbprint
    }
}
Write-Output $toDisplay | Out-Host

$selectedIndex = ((Read-Host -Prompt "`n`nWhich Certificate Number would you like to assign?`n`nIf the desired cert is not listed, please press 0" ) -as [int]) - 1
If (($selectedIndex -lt 0) -or ($selectedIndex -gt $certs.count)){
    $cert = 0
    Write-Output "`n`n************************************************************************************`n                The certificate you wish to install is not listed.`nPlease manually install and assign the certificate after installatino has completed.`n************************************************************************************"
} else {
    $cert = $certs[$selectedIndex]
}
