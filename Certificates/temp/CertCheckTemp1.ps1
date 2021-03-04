$global:list = Get-Content -Path '<insert path here>\DecommisisonList.txt'
$certAuth = '<insert certAuth server FQDN here>'


Invoke-Command -ComputerName $certAuth -Credential $cred -ScriptBlock {
    ForEach ($name in $global:list){    
        try{
            $certCheck = Get-Certificate -Path 'Cert:\<insert path here>\Issued Certificates' -ErrorAction SilentlyContinue
            If ($certCheck){
                $ip = ([System.Net.DNS]::GetHostEntry($name)).AddressList[0].IpAddressToString
                "$name exists in DNS at IP:$ip" | Out-File -Append '<insert path here>\DecommisisonList.csv'
            }
        } catch {
        }
    }
}
