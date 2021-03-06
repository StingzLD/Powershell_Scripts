$servers = '<insert comma separated mail server FQDNs here>'
$recipient = Read-Host -Prompt "Please enter the sender's email address."
$startDate = Read-Host -Prompt "Please enter the start date (M/D/YYYY)."
$endDate = Read-Host -Prompt "Please enter the end date (M/D/YYYY)."
$csvPath = (Read-Host -Prompt "Please enter the CSV file path (C:\Folder1\Folder2).")+'\Exchange_Log_Inbound.csv'

$results = foreach ($server in $servers){
    get-messagetrackinglog -Recipients $recipient -Server $server -Start "$startDate 00:00:00 AM" -End "$endDate 00:00:00 AM" | 
    select timestamp, source, messagesubject, sender, {$_.recipients}, totalbytes
    }

$results | export-csv -Path $csvPath -NoType