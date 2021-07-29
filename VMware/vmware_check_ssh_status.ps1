$location = Read-Host("Please enter the location")
$vcenter = $env:VCENTER
$domain = $env:VCENTER_DOMAIN
$creds = Get-Credential

Connect-VIServer "$vcenter.$location.$domain" -Credential $creds

Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" |
    Select-Object VMHost, Running, Policy | Format-Table -AutoSize

Disconnect-VIServer "$vcenter.$location.$domain" -Confirm:$false
