Import-Module Find-WebServerAsync
$webServers = Get-ADComputer -Filter {enabled -eq $true} -Properties Name | Find-WebServerAsync -Quiet | where {$_.Success -eq $true}
$webServers | Export-Csv C:\WebServers.csv
$webServers
