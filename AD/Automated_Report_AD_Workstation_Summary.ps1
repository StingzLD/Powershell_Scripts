# Gather list of workstations that have not talked to AD in the last 30 days
$ou = '<insert OU here>'
$workstationsOS = @()
$workstationsOS = Get-ADComputer -Filter * -SearchBase $ou -Property * | Sort Name

function Rename-OSVersion ($List,$OSColumn){
    foreach ($workstation in $List) {
        If ($workstation.$OSColumn -eq "10.0 (18362)"){
            $workstation.$OSColumn = "Version 1903"
        }
        elseif ($workstation.$OSColumn -eq "10.0 (17763)"){
            $workstation.$OSColumn = "Version 1809"
        }
        elseif ($workstation.$OSColumn -eq "10.0 (17134)"){
            $workstation.$OSColumn = "Version 1803"
        }
        elseif ($workstation.$OSColumn -eq "10.0 (16299)"){
            $workstation.$OSColumn = "Version 1709"
        }
        elseif ($workstation.$OSColumn -eq "10.0 (15063)"){
            $workstation.$OSColumn = "Version 1703"
        }
        elseif ($workstation.$OSColumn -eq "10.0 (14393)"){
            $workstation.$OSColumn = "Version 1607"
        }
        elseif ($workstation.$OSColumn -eq "10.0 (10586)"){
            $workstation.$OSColumn = "Version 1511"
        }
    }
}

Rename-OSVersion -List $workstationsOS -OSColumn OperatingSystemVersion

# Export list to CSV
$date = Get-Date -Format "yyyy-MM-dd"
$csvPath = "<insert path here>\Report_AD_Workstation_Summary_$date.csv"

$workstationsOS | Select-Object -Property Name,OperatingSystem,OperatingSystemVersion,LastLogonDate | Export-Csv -Path $csvPath
