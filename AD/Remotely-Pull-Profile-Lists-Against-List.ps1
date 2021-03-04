$list = Get-Content -Path "<insert path here>\RDSList.csv"
$csvFile = "<insert path here>\RDSUserProfiles.csv"
$cred = Get-Credential

$display = foreach ($server in $list){
    Invoke-Command -ComputerName $server -Credential $cred -ScriptBlock {
        Get-ChildItem 'HKLM:\Software\Microsoft\Windows NT\CurrentVersion\ProfileList' | Select-Object -Property PSChildName,PSComputerName,LastLogon
    }
}

$display | Export-Csv -Path $csvFile

