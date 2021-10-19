$ou = '<enter OU here>'
$list = Get-ADComputer -Filter {Enabled -eq $true} -SearchBase $ou | Sort-Object Name
$toExport = @()
$csv = '<enter path to export file>'

foreach ($server in $list) {
    $hostname = $server.Name
    $temp = @()
    $connectError = $null

    try {
        Test-Connection -BufferSize 32 -Count 1 -ComputerName $hostname -ErrorVariable connectError -ErrorAction Stop

        Write-Output "Collecting data on $hostname"

        try {
            $features = Get-WindowsFeature -ComputerName $hostname -ErrorVariable connectError -ErrorAction Stop
            foreach ($feature in $features) {
                if ($feature.Installed -eq 'True') {
                    $temp += @(
                        $feature.DisplayName
                    )
                }
            } 
        } catch {
            if ($connectError -match 'Get-WindowsFeature') {
                Write-Output "Data collection on $hostname failed" -ForegroundColor Red
                
                $temp += @(
                    $connectError
                )
            }
        }
    } catch {
        Write-Output "Connection to $hostname failed" -ForegroundColor Red

        $temp += @(
            $connectError
        )
    }

    $toExport += New-Object PSObject -Property @{
        'Server' = $hostname
        'Features' = $temp
    }
}

$toExport | Select-Object -Property 'Server',@{Name='Features';Expression={[string]::join(';', ($_.Features))}} | Export-Csv -Path $csv
