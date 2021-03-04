$csvFile = '<insert path here>\CertList.csv'
$certAuth = '<insert certAuth server FQDN here>'

Invoke-Command -ComputerName $certAuth -Credential $cred -ScriptBlock {
    Install-Module -Name PSPKI