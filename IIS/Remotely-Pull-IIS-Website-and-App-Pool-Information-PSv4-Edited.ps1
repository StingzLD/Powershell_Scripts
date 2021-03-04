Import-Module Find-WebServerAsync

$cred = Get-Credential

# Gather list of web servers on domain
$webServers = Get-ADComputer -Filter {enabled -eq $true} -Properties Name | Find-WebServerAsync -Quiet | where {$_.Success -eq $true}

# Gather list of installed websites and app pools in IIS
$remoteSites = Invoke-Command -ComputerName $webServers.Name -Credential $cred -ScriptBlock {
    Import-Module WebAdministration
    Add-WindowsFeature Web-WMI

    $sites = Get-Website
    $serverName = (Get-WmiObject win32_operatingsystem).CSName
    $serverOS = ((Get-WmiObject win32_operatingsystem).Name).Split('|')
    $toDisplay = @()

    For ($i = 0; $i -lt $sites.Count; $i ++){
        If ($sites[$i].state -eq 'Started'){
            ForEach ($bind in $sites[$i].bindings.Collection){
                $appPool = 
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
    Return $toDisplay
}

# Export list to CSV
$remoteSites | Select-Object 'Server Name','Server OS','App Pool','App Identity','.Net Version','Website','Path','IP','Port','Protocol','Host Header','Certificate','Expiration','Thumbprint' | Export-Csv C:\RemoteWebsitesAndAppPools.csv






Iterate through apps until the $sites[$i].applicationPool equals the app, then run the table against it.