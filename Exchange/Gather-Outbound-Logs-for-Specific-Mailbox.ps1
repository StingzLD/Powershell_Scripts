$servers = '<insert comma separated mail server FQDNs here>'
$sender = Read-Host -Prompt "Please enter the sender's email address."
$startDate = Read-Host -Prompt "Please enter the start date (M/D/YYYY)."
$endDate = Read-Host -Prompt "Please enter the end date (M/D/YYYY)."
$csvPath = (Read-Host -Prompt "Please enter the CSV file path (C:\Folder1\Folder2).")+'\Exchange_Log_Outbound.csv'

$results = foreach ($server in $servers){
    get-messagetrackinglog -Sender $sender -Server $server -Start "$startDate 00:00:00 AM" -End "$endDate 00:00:00 AM" | 
    select timestamp, source, messagesubject, sender, {$_.recipients}, totalbytes
    }

$results | export-csv -Path $csvPath -NoType