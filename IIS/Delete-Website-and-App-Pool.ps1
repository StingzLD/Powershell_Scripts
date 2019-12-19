$siteName = Read-Host -Prompt "Enter the Website Name"
$appName = $siteName
$hostname = $siteName
$siteIP = Read-Host -Prompt "Enter the Website IP"

Remove-Website -Name $siteName
Remove-WebAppPool -Name $appName
netsh http delete sslcert ipport=${siteIP}:443


#Remove-WebBinding -Name $siteName -Protocol "https" -IPAddress $siteIP -Port 443 -HostHeader $hostname
#Remove-Item -Path E:\Websites\$siteName