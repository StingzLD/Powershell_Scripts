$venue = Read-Host("Please enter the location shortname")
$vcenter = $env:VCENTER
$domain = $env:VCENTER_DOMAIN
$creds = Get-Credential

Connect-VIServer "$vcenter.$venue.$domain" -Credential $creds

Get-VMHost | Get-VMHostService | Where-Object Key -EQ "TSM-SSH" |
    Where-Object Running -EQ True | Select-Object VMHost, Running |
    Format-Table -AutoSize

Disconnect-VIServer "$vcenter.$venue.$domain" -Confirm:$False
