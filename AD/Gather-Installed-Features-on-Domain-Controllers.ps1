$ou = '<enter OU here>'
$list = Get-ADComputer -Filter {Enabled -eq $true} -SearchBase $ou | Sort-Object Name
$toExport = @()
$csv = '<enter path to export file>'

foreach ($server in $list) {
    $hostname = $server.Name
    $temp = @()
    $tryError = $null

    try {
        Test-Connection -BufferSize 32 -Count 1 -ComputerName $hostname `
            -ErrorVariable tryError -ErrorAction Stop

        Write-Host "Collecting data on $hostname"

        try {
            $features = Get-WindowsFeature -ComputerName $hostname `
                -ErrorVariable tryError -ErrorAction Stop |
                Where-Object{$_.InstallState -eq 'Installed'}
            
            foreach ($feature in $features) {
                    $temp += @(
                        $feature.DisplayName
                    )
            }

        } catch {
            Write-Host "Data collection on $hostname failed" -ForegroundColor Red
        }

    } catch {
        Write-Host "Connection to $hostname failed" -ForegroundColor Red
    }

    if (-not $temp) {
        $temp += @(
                $tryError
        )
    }

    $toExport += New-Object PSObject -Property @{
        'Server' = $hostname
        'Features' = $temp
    }
}

$toExport | Select-Object -Property 'Server',@{Name='Features';`
    Expression={[string]::join(';', ($_.Features))}} | Export-Csv -Path $csv
