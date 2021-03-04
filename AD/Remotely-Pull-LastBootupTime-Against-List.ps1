$serverList = Get-Content -Path "<insert path here>\ComputersList.txt"
$toDisplay = @()

$toDisplay = Invoke-Command -ComputerName $serverList -Credential $cred -ErrorAction SilentlyContinue -ScriptBlock {
    Get-CimInstance -ClassName win32_operatingsystem | select csname, lastbootuptime
    }

$toDisplay | Export-Csv "<insert path here>\ComputersRebootTimes.csv"