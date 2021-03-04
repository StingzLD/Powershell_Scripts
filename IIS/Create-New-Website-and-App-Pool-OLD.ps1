# Initialize variables
$appName = ""
$appIdentity = ""
$appIdentityPassword = ""
$gmsaCheck = ""
$siteNameCheck = ""
$siteName = ""
$siteIP = ""
$siteIpCheck = ""
$octets = 0
$lastOctet = ""
$hostname = ""
$phyPath = ""
$dirPath = ""
$dirCheck = 0
$requireSSL = ""
$certPath = ""
$chooseCert = ""
$certHash = ""
$certHashInternal = "8C5A9262CCCCE957D4D500FEE332FA816241C96E"
$certHashExternal = "Not Installed"
$certCheck = 0
$certInstalled = ""
$bindingInfo = ""

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
    Write-Output "`n`n*****************************************************`n               No Directory Detected.`n*****************************************************`n`nDirectory for $siteName has been created at $dirPath.`n`n"
}

# Assign website IP
$siteIP = Read-Host -Prompt "`nEnter the Website IP"

# Perform valid IP check
If ($siteIP -eq ""){
    $siteIP = "*" 
}
else{
    DO{
        # Ensure there are four octets in the IP
        $octets = ($siteIP.Split('.')).count
        If ($octets -ne 4){
            $siteIP = Read-Host -Prompt "`nIP $siteIP has an invalid amount of octets. Please enter the IP again."
        }
        # Ensure IP is within valid IP range
        If ($octets -eq 4){
            $siteIPCheck = "$siteIP" -as [IPAddress] -as [Bool]
            If ($siteIPCheck -eq $false){
                $siteIP = Read-Host -Prompt "`nIP '$siteIP' is not a valid IP. Enter a new IP"
            }
        }
        # Ensure last octet is not 0
        If (($octets -eq 4) -and ($siteIPCheck -eq $true)){
            $lastOctet = ($siteIP.Split('.'))[-1]
            If ($lastOctet -eq "0"){
                $siteIP = Read-Host -Prompt "`nLast octet must not be zero. Please enter the IP again."
            }
        }
    } Until (($octets -eq 4) -and ($lastOctet -ne "") -and ($lastOctet -ne "0") -and ($siteIPCheck -eq $true))
}

# Does website need SSL binding
$requireSSL = Read-Host -Prompt "`nDoes the website require an SSL Binding? (Y/N)"
DO{
    If (($requireSSL -ne "Y") -and ($requireSSL -ne "N")){
        $requireSSL = Read-Host -Prompt "`nIncorrect character selected. Please type either 'Y' or 'N'"
    }
} Until (($requireSSL -eq "Y") -or ($requireSSL -eq "N"))

# SSL IP check
If (($requireSSL -eq "Y") -and ($siteIP -eq "*")){ 
    $siteIP = Read-Host -Prompt "`n`n*****************************************************`n             SSL Binding Requires an IP.`n*****************************************************`n`nEnter IP for SSL Binding."
    If ($siteIP -eq ""){
        $siteIP = "*"
    }
    If ($siteIP -eq "*"){
        Write-Output "`n`n********************************************************************************************`nNo SSL Binding created. Please manually create binding after the installation has completed.`n********************************************************************************************"
    }
}

# Choose which cert to use
If (($requireSSL -eq "Y") -and ($siteIP -ne "*")){ 
    $certPath = "Cert:\LocalMachine\My"
    $chooseCert = Read-Host -Prompt "`nWhich certificate would you like to assign? `nPress 1 for Internal Wildcard.`nPress 2 for External Wildcard.`nPress 3 for Other. `n"
    If ($chooseCert -eq "1"){
        $certHash = $certHashInternal
        $certCheck = 0
        Get-ChildItem $certPath | Where-Object { $_.Thumbprint -eq "$certHash" } | ForEach-Object { $certCheck = $certCheck + 1 }
        If ($certCheck -eq 0){
            $certInstalled = "None"
            Write-Output "`n`n*******************************************`nNo Internal Wildcard certificate installed.`n*******************************************"
        }
        else {
            $certInstalled = "Internal"
        }
    }
    elseif ($chooseCert -eq "2"){
        $certHash = $certHashExternal
        $certCheck = 0
        Get-ChildItem $certPath | Where-Object { $_.Thumbprint -eq "$certHash" } | ForEach-Object { $certCheck = $certCheck + 1 }

        If ($certCheck -eq 0){
            $certInstalled = "None"
            Write-Output "`n`n*******************************************`nNo External Wildcard certificate installed.`n*******************************************"
        }
        else {
            $certInstalled = "External"
        }
    }
    elseif ($chooseCert -eq "3"){
        Write-Output "`n`n*************************************************************************`nPlease assign certificate manually after the installation has completed.`n*************************************************************************"
        $certInstalled = "Manual"
    }
}

# Create a new website with HTTP binding using newly created app pool
If ($siteIP -eq "*"){
    New-Website -Name $siteName -IPAddress $siteIP -Port 80 -HostHeader $hostname -PhysicalPath $phyPath -ApplicationPool $appName
}
else {
    New-Website -Name $siteName -IPAddress $siteIP -Port 80 -PhysicalPath $phyPath -ApplicationPool $appName
}

# Create SSL binding
If (($requireSSL -eq "Y") -and ($siteIP -ne "*")){
    #Create new SSL binding for new website
    New-WebBinding -Name $siteName -Protocol "https" -IPAddress $siteIP -Port 443 -SslFlags 0
    #Assign cert to new SSL binding
    $bindingInfo = Get-WebBinding -Name $siteName -Protocol "https"
    If ($certInstalled -eq "None"){
        Write-Output "`n`n************************************************************************************`nPlease install certificate and manually assign after the installation has completed.`n************************************************************************************"
    } elseif ($certInstalled -eq "Internal"){
        $bindingInfo.AddSslCertificate($certHash, "My")
        Write-Output "`n`nThe Internal Wildcard certificate has been assigned."
    } elseif ($certInstalled -eq "External"){
        $bindingInfo.AddSslCertificate($certHash, "My")
        Write-Output "`n`nThe External Wildcard certificate has been assigned."
    } elseif ($certInstalled -eq "Manual"){
    }
}

# Installation complete
Read-Host -Prompt "`n`nInstallation complete. Press Enter to continue..."