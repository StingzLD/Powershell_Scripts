# Initialization
$appName = ""
$appIdentity = ""
$appIdentityPassword = ""
$gmsaCheck = ""
$siteNameCheck = ""
$siteName = ""
$global:siteIP = ""
$global:siteIPCheck = ""
$hostname = ""
$phyPath = ""
$dirPath = ""
$dirCheck = 0
$requireSSL = ""
$certPath = ""
$certs = ""
$toDisplay = @()
$selectedIndex = 0
$bindingInfo = ""

Function IP-Check{
    $octets = 0
    $lastOctet = ""

    DO{
        # Ensure there are four octets in the IP
        $octets = ($global:siteIP.Split('.')).count
        If ($octets -ne 4){
            $global:siteIP = Read-Host -Prompt "`nIP $global:siteIP has an invalid amount of octets. Please enter the IP again."
        }
        # Ensure IP is within valid IP range
        If ($octets -eq 4){
            $global:siteIPCheck = "$global:siteIP" -as [IPAddress] -as [Bool]
            If ($global:siteIPCheck -eq $false){
                $global:siteIP = Read-Host -Prompt "`nIP '$global:siteIP' is not a valid IP. Enter a new IP"
            }
        }
        # Ensure last octet is not 0
        If (($octets -eq 4) -and ($global:siteIPCheck -eq $true)){
            $lastOctet = ($global:siteIP.Split('.'))[-1]
            If ($lastOctet -eq "0"){
                $global:siteIP = Read-Host -Prompt "`nLast octet must not be zero. Please enter the IP again."
            }
        }
    } Until (($octets -eq 4) -and ($lastOctet -ne "") -and ($lastOctet -ne "0") -and ($global:siteIPCheck -eq $true))
}


# Assign app pool name
$appName = Read-Host -Prompt "`nEnter the Application Pool Name"

# Create a new app pool
New-WebAppPool -Name $appName

# Assign app pool identity
$appIdentity = Read-Host -Prompt "`n`nEnter the App Pool Identity"
$gmsaCheck = Read-Host -Prompt "`nIs this is a gMSA account? (Y/N)"
DO{
    If (($gmsaCheck -ne "Y") -and ($gmsaCheck -ne "N")){
        $gmsaCheck = Read-Host -Prompt "`nIncorrect character selected. Please type either 'Y' or 'N'"
    }
} Until (($gmsaCheck -eq "Y") -or ($gmsaCheck -eq "N"))
If ($gmsaCheck -eq "Y"){
    Set-ItemProperty IIS:\AppPools\$appName -name processModel -value @{userName=$appIdentity;identitytype=3}
}
else {
    $appIdentityPassword = Read-Host -Prompt "`nEnter the App Pool Identity Password"
    Set-ItemProperty IIS:\AppPools\$appName -name processModel -value @{userName=$appIdentity;password=$appIdentityPassword;identitytype=3}
}

# Assign website name
$siteNameCheck = Read-Host -Prompt "`nIs the Website Name the same as the Application Pool Name? (Y/N)"
DO{
    If (($siteNameCheck -ne "Y") -and ($siteNameCheck -ne "N")){
        $siteNameCheck = Read-Host -Prompt "`nIncorrect character selected. Please type either 'Y' or 'N'"
    }
} Until (($siteNameCheck -eq "Y") -or ($siteNameCheck -eq "N"))
If ($siteNameCheck -eq "Y"){
    $siteName = $appName
}
else {
    $siteName = Read-Host -Prompt "`nEnter the Website Name"
}
$hostname = $siteName

# Create directory if one does not exist
$phyPath = "E:\Websites\$siteName"
$dirPath = "E:\Websites\"
$dirCheck = 0
Get-ChildItem $dirPath | Where-Object Name -eq $siteName | ForEach-Object { $dirCheck = $dirCheck + 1 }
If ($dirCheck -eq 0){
    New-Item -ItemType directory -Path $phyPath
    New-Item -ItemType directory -Path $phyPath\logs
    Write-Output "`n`n*****************************************************`n               No Directory Detected.`n*****************************************************`n`nDirectory for $siteName has been created at $dirPath.`n`n"
}

# Assign website IP
$global:siteIP = Read-Host -Prompt "`nEnter the Website IP"

# Perform valid IP check
If ($global:siteIP -eq ""){
    $global:siteIP = "*" 
}
else{
    IP-Check
}

# Does website need SSL binding
$requireSSL = Read-Host -Prompt "`nDoes the website require an SSL Binding? (Y/N)"
DO{
    If (($requireSSL -ne "Y") -and ($requireSSL -ne "N")){
        $requireSSL = Read-Host -Prompt "`nIncorrect character selected. Please type either 'Y' or 'N'"
    }
} Until (($requireSSL -eq "Y") -or ($requireSSL -eq "N"))

# SSL IP check
If (($requireSSL -eq "Y") -and ($global:siteIP -eq "*")){ 
    $global:siteIP = Read-Host -Prompt "`n`n*****************************************************`n             SSL Binding Requires an IP.`n*****************************************************`n`nEnter IP for SSL Binding."
    If ($global:siteIP -eq ""){
        $global:siteIP = "*"
    }
    If ($global:siteIP -eq "*"){
        Write-Output "`n`n********************************************************************************************`nNo SSL Binding created. Please manually create binding after the installation has completed.`n********************************************************************************************"
    }
    else {
        IP-Check
    }
}

# Choose which cert to use
If (($requireSSL -eq "Y") -and ($global:siteIP -ne "*")){ 
    $certPath = "Cert:\LocalMachine\My"
    $certs = Get-ChildItem $certPath

    # Display installed certificates
    Write-Output "`n`nThe currently installed certificates are:"
    For ($i = 0; $i -lt $certs.Count; $i++) {
        $toDisplay += New-Object PSObject -Property @{
            'Number' = $i + 1
            'Name' = $certs[$i].DnsNameList
            'Expiration' = $certs[$i].NotAfter
            'Thumbprint' = $certs[$i].Thumbprint
        }
    }
    Write-Output $toDisplay | Out-Host

    # User chooses cert
    $selectedIndex = ((Read-Host -Prompt "`nWhich Certificate Number would you like to assign?`n`nIf the desired cert is not listed, please press 0" ) -as [int]) - 1
    If (($selectedIndex -lt 0) -or ($selectedIndex -gt $certs.count)){
        $cert = 0
        Write-Output "`n`n************************************************************************************`n                The certificate you wish to install is not listed.`nPlease manually install and assign the certificate after installation has completed.`n************************************************************************************"
    } else {
        $cert = $certs[$selectedIndex]
    }
}

# Create a new website with HTTP binding using newly created app pool
If ($global:siteIP -eq "*"){
    New-Website -Name $siteName -IPAddress $global:siteIP -Port 80 -HostHeader $hostname -PhysicalPath $phyPath -ApplicationPool $appName
}
else {
    New-Website -Name $siteName -IPAddress $global:siteIP -Port 80 -PhysicalPath $phyPath -ApplicationPool $appName
}

# Create SSL binding
If (($requireSSL -eq "Y") -and ($global:siteIP -ne "*")){
    #Create new SSL binding for new website
    New-WebBinding -Name $siteName -Protocol "https" -IPAddress $global:siteIP -Port 443 -SslFlags 0
    #Assign cert to new SSL binding
    If ($cert -ne 0){
        $bindingInfo = Get-WebBinding -Name $siteName -Protocol "https"
        $bindingInfo.AddSslCertificate($cert.Thumbprint, "My")
    }
}

# Installation complete
Read-Host -Prompt "`n`nInstallation complete. Press Enter to continue..."