$servers = '<insert comma separated mail server FQDNs here>'
$emailAddress = Read-Host -Prompt "Please enter the user's email address."
$startDate = Read-Host -Prompt "Please enter the start date (M/D/YYYY)."
$endDate = Read-Host -Prompt "Please enter the end date (M/D/YYYY)."
$csvPath = (Read-Host -Prompt "Please enter the CSV file path (C:\Folder1\Folder2).")+'\Exchange_Log_Outbound.csv'

$resultsSend = foreach ($server in $servers){
    get-messagetrackinglog -Sender $emailAddress -Server $server -Start "$startDate 00:00:00 AM" -End "$endDate 00:00:00 AM" | 
    select timestamp, source, messagesubject, sender, {$_.recipients}, totalbytes
    }
$resultsReceive = foreach ($server in $servers){
    get-messagetrackinglog -Recipients $emailAddress -Server $server -Start "$startDate 00:00:00 AM" -End "$endDate 00:00:00 AM" | 
    select timestamp, source, messagesubject, sender, {$_.recipients}, totalbytes
    }

$resultsSend+$resultsReceive | export-csv -Path $csvPath -NoType