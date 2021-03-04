Import-Module Find-WebServerAsync

$cred = Get-Credential

Measure-Command{

# Gather list of web servers on domain
$webServers = Get-ADComputer -Filter {enabled -eq $true} -Properties Name | Find-WebServerAsync -Quiet | where {$_.Success -eq $true}

# Gather list of installed certificates in the Local Computer\Personal store
$remoteCerts = Invoke-Command -ComputerName $webServers.Name -Credential $cred -ScriptBlock {
    $certPath = "Cert:\LocalMachine\My"
    $certs = Get-ChildItem $certPath
    $toDisplay = @()

    For ($i = 0; $i -lt $certs.Count; $i++) {
        $toDisplay += New-Object PSObject -Property @{
            'Number' = $i + 1
            'Name' = $certs[$i].DnsNameList
            'Expiration' = $certs[$i].NotAfter
            'Thumbprint' = $certs[$i].Thumbprint
        }
    }
    Return $toDisplay
}

# Export list of certificates to CSV
$remoteCerts | Export-Csv C:\RemoteCerts.csv -append
}






#Gather IIS Website Information

Import-Module WebAdministration

$sites = Get-Website
$serverName = (Get-WmiObject win32_operatingsystem).CSName
$serverOS = ((Get-WmiObject win32_operatingsystem).Name).Split('|')
$toDisplay = @()

For ($i = 0; $i -lt $sites.Count; $i ++){
    If ($sites[$i].state -eq 'Started'){
        ForEach ($bind in $sites[$i].bindings.Collection){
            $appPool = Get-IISAppPool $sites[$i].applicationPool
            $bindInfo = ($bind.bindingInformation).Split(':')
            $cert = Get-ChildItem -Path 'Cert:\LocalMachine\My' | Where-Object { $_.Thumbprint -like $bind.certificateHash }
            $toDisplay += New-Object PSObject -Property @{
                'Server Name' = $serverName;
                'Server OS' = $serverOS[-3];
                'App Pool' = $appPool.name;
                'App Identity' = $appPool.ProcessModel.UserName;
                '.Net Version' = $appPool.ManagedRuntimeVersion;
                'Website' = $sites[$i].name;
                'Path' = $sites[$i].physicalPath;
                'IP' = $bindInfo[-3];
                'Port' = $bindInfo[-2];
                'Protocol' = $bind.protocol;
                'Host Header' = $bindInfo[-1];
                'Certificate' = $cert.DnsNameList;
                'Expiration' = $cert.NotAfter;
                'Thumbprint' = $cert.Thumbprint;
            }
        }
    }
}

$toDisplay | Select-Object 'Server Name','Server OS','App Pool','App Identity','.Net Version','Website','Path','IP','Port','Protocol','Host Header','Certificate','Expiration','Thumbprint' | Export-Csv C:\RemoteWebsites.csv
