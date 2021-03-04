#Gather IIS Website Information

Import-Module WebAdministration

$toDisplay = @()

ForEach ($Site in Get-Website){
    ForEach ($Bind in $Site.Bindings.Collection){
        $toDisplay += New-Object PSObject -Property @{
            'Name' = $Site.Name;
            'Protocol' = $Bind.Protocol;
            'Bindings' = $Bind.BindingInformation;
            'Cert' = $Bind.CertificateHash;
            'Path' = $Site.PhysicalPath;
            'AppPool' = $Site.ApplicationPool;
        }
    }
}

Write-Output $toDisplay | Out-Host
