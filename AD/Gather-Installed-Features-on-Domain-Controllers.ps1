$ou = '<enter OU here>'
$csv = '<enter path to export file>'
$toExport = @()

# Gather a list of enabled servers in the specified OU and sort by name
$list = Get-ADComputer -Filter {Enabled -eq $true} -SearchBase $ou | Sort-Object Name

# Iterate through all enabled servers to collect their installed features
foreach ($server in $list) {
    $hostname = $server.Name  # Defines a variable for the host's name
    $temp = @()  # Creates an empty list to store data during each iteration
    $tryError = $null  # Initializes the Error Variable used to collect potential error data

    try {
        # Ping the computer to see if it is online. If it fails, collect error in Error Variable
        Test-Connection -BufferSize 32 -Count 1 -ComputerName $hostname `
            -ErrorVariable tryError -ErrorAction Stop

        Write-Host "Collecting data on $hostname"

        try {
            # Gather a list of installed features. If it fails, collect error in Error Variable
            $features = Get-WindowsFeature -ComputerName $hostname `
                -ErrorVariable tryError -ErrorAction Stop |
                Where-Object{$_.InstallState -eq 'Installed'}
            
            # Add each installed feature to the temporary list
            foreach ($feature in $features) {
                    $temp += @(
                        $feature.DisplayName
                    )
            }

        } catch {
            # If data collection failed, send message to the terminal
            Write-Host "Data collection on $hostname failed" -ForegroundColor Red
        }

    } catch {
        # If Test-Connection failed, send message to the terminal
        Write-Host "Connection to $hostname failed" -ForegroundColor Red
    }

    # If the collection errored out, add the error to the temporary list
    if (-not $temp) {
        $temp += @(
                $tryError
        )
    }

    # Add a new object to the toExport array containing the data collected
    $toExport += New-Object PSObject -Property @{
        'Server' = $hostname
        'Features' = $temp
    }
}

# Export the collected data to CSV
$toExport | Select-Object -Property 'Server',@{Name='Features';`
    Expression={[string]::join(';', ($_.Features))}} | Export-Csv -Path $csv
