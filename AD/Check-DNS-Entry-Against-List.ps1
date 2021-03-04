$list = Get-Content -Path '<insert path here>\DecommisisonList.txt'
$server = '<insert server FQDN>'

ForEach ($name in $list){
    try{
        $dnsCheck = Resolve-DnsName -Name $name -Server $server -ErrorAction SilentlyContinue
        If ($dnsCheck){
            $ip = ([System.Net.DNS]::GetHostEntry($name)).AddressList[0].IpAddressToString
            "$name exists in DNS at IP:$ip" | Out-File -Append '<insert path here>\DecommisisonList.csv'
        }
    } catch {
    }
}
