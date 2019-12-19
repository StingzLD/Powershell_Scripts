$siteName = Read-Host -Prompt "Enter the Website Name"
$hostname = $siteName
$siteIP = Read-Host -Prompt "Enter the Website IP"

Remove-Website -Name $siteName
netsh http delete sslcert ipport=${siteIP}:443



#Remove-WebBinding -Name $siteName -Protocol "https" -IPAddress $siteIP -Port 443 -HostHeader $hostname