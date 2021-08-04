$location = Read-Host("Please enter the location")
$vcenter = $env:VCENTER
$domain = $env:VCENTER_DOMAIN
$vcenter_main = $env:VCENTER_MAIN
$creds = Get-Credential

Connect-VIServer "$vcenter.$location.$domain" -Credential $creds

#Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" | Start-VMHostService -Confirm:$false
#Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" | Set-VMHostService -Policy "on" -Confirm:$false

Disconnect-VIServer "$vcenter.$location.$domain" -Confirm:$false
Connect-VIServer $vcenter_main -Credential $creds

#Get-DataCenter $location | Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" | Start-VMHostService -Confirm:$false
#Get-DataCenter $location | Get-VMHost | Get-VMHostService | Where-Object Key -eq "TSM-SSH" | Set-VMHostService -Policy "on" -Confirm:$false

Disconnect-VIServer $vcenter_main -Confirm:$false
