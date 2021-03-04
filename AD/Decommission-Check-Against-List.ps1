$list = Get-Content -Path '<insert path here>\DecommisisonList.txt'
$server = '<insert server FQDN here>'
$csvFile = '<insert path here>\DecommisisonList.csv'

function Decommission-Check ($ServerList = $list,$DC = $server,$OutPath = $csvFile) {
    foreach ($name in $ServerList){
        try{
            $adCheck = Get-AdComputer -Identity $name -ErrorAction SilentlyContinue
            If ($adCheck){
                "$name exists in AD" | Out-File -Append $OutPath
            }
        } catch {
        }    try{
            $dnsCheck = Resolve-DnsName -Name $name -Server $DC -ErrorAction SilentlyContinue
            If ($dnsCheck){
                $ip = ([System.Net.DNS]::GetHostEntry($name)).AddressList[0].IpAddressToString
                "$name exists in DNS - IP: $ip" | Out-File -Append $OutPath
            }
        } catch {
        }
    }
}

if (!(Test-Path -Path $csvFile -PathType Leaf)) {
    New-Item -Path $csvfile
    Decommission-Check
} else {
    Remove-Item -Path $csvfile
    New-Item -Path $csvfile
    Decommission-Check
}
