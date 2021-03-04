$hostname = '<insert VM hostname here>'
$vcenter = '<insert vCenter name here>'

Get-VMwareToWindowsDiskMapping -ComputerName $hostname -vcenter $vcenter -Credential $cred
