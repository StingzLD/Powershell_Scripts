# Gather list of workstations that have not talked to AD in the last 30 days
$ou = '<insert OU here>'
$staleWorkstationsAD = @()
$staleWorkstationsAD = Get-ADComputer -Filter * -Properties *  -SearchBase @ou | Where {$_.LastLogonDate -le (get-date).AddDays(-30)} | Sort LastLogonDate

# Export list to HTML
$header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
TR:nth-child(even) {background-color: #ededed;}
</style>
"@
$htmlPath = '<insert path here>\Dormant_Workstations.html'

$staleWorkstationsAD | ConvertTo-Html -Property Name,LastLogonDate -Head $header | Out-File -FilePath $htmlPath

# Export list to CSV
$date = Get-Date -Format "yyyy-MM-dd"
$csvPath = "<insert path here>\Dormant_Workstations_$date.csv"

$staleWorkstationsAD | Select-Object -Property Name,LastLogonDate | Export-Csv -Path $csvPath

# Send email with CSV attachment using HTML file
$messsageServer = '<insert SMTP server here>'
$messageFrom = 'User Name <email>'
$messageTo = 'User Name <email>'
$messageSubject = 'Report - Dormant Workstations'
$messageBody = Get-Content $htmlPath -Raw
$messageAttachments = $csvPath

Send-MailMessage -SmtpServer $messsageServer -From $messageFrom -To $messageTo -Subject $messageSubject -BodyAsHtml $messageBody -Attachments $messageAttachments
