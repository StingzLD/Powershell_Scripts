# Gather list of workstations OS versions
$ou = '<insert OU here>'
$workstationsOS = @()
$workstationsOS = Get-ADComputer -Filter * -SearchBase $ou -Property * | Sort OperatingSystemVersion,Name
$total = $workstationsOS.Count

foreach ($workstation in $workstationsOS) {
    If ($workstation.OperatingSystemVersion -eq "10.0 (18362)"){
        $workstation.OperatingSystemVersion = "Version 1903"
        $1903 = ($workstationsOS.OperatingSystemVersion -eq "Version 1903").Count
    }
    elseif ($workstation.OperatingSystemVersion -eq "10.0 (17763)"){
        $workstation.OperatingSystemVersion = "Version 1809"
        $1809 = ($workstationsOS.OperatingSystemVersion -eq "Version 1809").Count
    }
    elseif ($workstation.OperatingSystemVersion -eq "10.0 (17134)"){
        $workstation.OperatingSystemVersion = "Version 1803"
        $1803 = ($workstationsOS.OperatingSystemVersion -eq "Version 1803").Count
    }
    elseif ($workstation.OperatingSystemVersion -eq "10.0 (16299)"){
        $workstation.OperatingSystemVersion = "Version 1709"
        $1709 = ($workstationsOS.OperatingSystemVersion -eq "Version 1709").Count
    }
    elseif ($workstation.OperatingSystemVersion -eq "10.0 (15063)"){
        $workstation.OperatingSystemVersion = "Version 1703"
        $1703 = ($workstationsOS.OperatingSystemVersion -eq "Version 1703").Count
    }
    elseif ($workstation.OperatingSystemVersion -eq "10.0 (14393)"){
        $workstation.OperatingSystemVersion = "Version 1607"
        $1607 = ($workstationsOS.OperatingSystemVersion -eq "Version 1607").Count
    }
    elseif ($workstation.OperatingSystemVersion -eq "10.0 (10586)"){
        $workstation.OperatingSystemVersion = "Version 1511"
        $1511 = ($workstationsOS.OperatingSystemVersion -eq "Version 1511").Count
    }
    elseif ($workstation.OperatingSystemVersion -eq $null){
        $unknown = ($workstationsOS.OperatingSystemVersion -eq $null).Count
    }
}

# Create new table for Version number counts
$osCount = @()
$osCount = @(
    [PSCustomObject]@{'OS Version' = '1903';'Count' = $1903;'Percentage' = ($1903/$total).ToString("P")}
    [PSCustomObject]@{'OS Version' = '1809';'Count' = $1809;'Percentage' = ($1809/$total).ToString("P")}
    [PSCustomObject]@{'OS Version' = '1803';'Count' = $1803;'Percentage' = ($1803/$total).ToString("P")}
    [PSCustomObject]@{'OS Version' = '1709';'Count' = $1709;'Percentage' = ($1709/$total).ToString("P")}
    [PSCustomObject]@{'OS Version' = '1703';'Count' = $1703;'Percentage' = ($1703/$total).ToString("P")}
    [PSCustomObject]@{'OS Version' = '1607';'Count' = $1607;'Percentage' = ($1607/$total).ToString("P")}
    [PSCustomObject]@{'OS Version' = '1511';'Count' = $1511;'Percentage' = ($1511/$total).ToString("P")}
    [PSCustomObject]@{'OS Version' = 'No Value';'Count' = $unknown;'Percentage' = ($unknown/$total).ToString("P")}
    [PSCustomObject]@{'OS Version' = 'Total';'Count' = $total;'Percentage' = ""}
)

# Export lists to HTML
$header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
TR:nth-child(even) {background-color: #ededed;}
</style>
"@
$htmlPath = '<insert path here>\Workstations_OS.html'
$htmlPath2 = '<insert path here>\OS_Counts.html'
$workstationsOS | ConvertTo-Html -Property 'Name','OperatingSystem','OperatingSystemVersion' -Head $header | Out-File -FilePath $htmlPath
$osCount | ConvertTo-Html -Property 'OS Version','Count','Percentage' -Head $header | Out-File -FilePath $htmlPath2

# Export list to CSV
$date = Get-Date -Format "yyyy-MM-dd"
$csvFile = "<insert path here>\Workstations_OS_$date.csv"
$csvFile2 = "<insert path here>\OS_Counts_$date.csv"

$workstationsOS | Select-Object -Property 'Name','OperatingSystem','OperatingSystemVersion' | Export-Csv -Path $csvFile
$osCount | Select-Object -Property 'OS Version','Count','Percentage' | Export-Csv -Path $csvFile2

# Send email with CSV attachment using HTML file
$messsageServer = '<insert SMTP server>'
$messageFrom = 'User Name <email>'
$messageTo = 'User Name <email>'
$messageSubject = 'AD Workstation OS Versions Report'
$messageBody = Get-Content $htmlPath2 -Raw
$messageBody += Get-Content $htmlPath -Raw
$messageAttachments = $csvFile,$csvFile2

Send-MailMessage -SmtpServer $messsageServer -From $messageFrom -To $messageTo -Subject $messageSubject -BodyAsHtml $messageBody -Attachments $messageAttachments