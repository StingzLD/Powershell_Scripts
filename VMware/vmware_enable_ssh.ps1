$venue = Read-Host("Please enter the location shortname")
$vcenter = $env:VCENTER
$domain = $env:VCENTER_DOMAIN
$vcenter_main = $env:VCENTER_MAIN
$creds = Get-Credential

Connect-VIServer "$vcenter.$venue.$domain" -Credential $creds

Get-VMHost | Get-VMHostService | Where-Object Key -EQ "TSM-SSH" | Start-VMHostService -Confirm:$False
Get-VMHost | Get-VMHostService | Where-Object Key -EQ "TSM-SSH" | Set-VMHostService -Policy "on" -Confirm:$False

Disconnect-VIServer "$vcenter.$venue.$domain" -Confirm:$False
Connect-VIServer $vcenter_main -Credential $creds

Get-DataCenter $venue | Get-VMHost | Get-VMHostService | Where-Object Key -EQ "TSM-SSH" | Start-VMHostService -Confirm:$False
Get-DataCenter $venue | Get-VMHost | Get-VMHostService | Where-Object Key -EQ "TSM-SSH" | Set-VMHostService -Policy "on" -Confirm:$False

Disconnect-VIServer $vcenter_main
