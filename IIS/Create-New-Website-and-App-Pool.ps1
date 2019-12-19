#Variables
$siteName = Read-Host -Prompt "Enter the Website Name"
$appName = $siteName
$hostname = $siteName
$siteIP = Read-Host -Prompt "Enter the Website IP"
$phyPath = "E:\Websites\$siteName"
$dirPath = "E:\Websites\"
$dirCheck = 0
$requireSSL = Read-Host -Prompt "Does the website require an SSL Binding? (Y/N)"

If ($requireSSL -eq "Y"){
    
    #Variables
    $certPath = "Cert:\LocalMachine\My"
    $chooseCert = Read-Host -Prompt "Which certificate would you like to assign? `nPress 1 for Internal Wildcard.`nPress 2 for External Wildcard.`nPress 3 for Other. `n"
        
    If ($chooseCert -eq "1"){
        $certHash = "<insert cert hash here>"
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
        $certHash = "<insert cert hash here>"
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
        Write-Output "`n`n***********************************************************************`nPlease assign certificate manually after the installation is complete.`n***********************************************************************"
        $certInstalled = "Manual"
    }
}

#Create Directory if One Does Not Exist
Get-ChildItem $dirPath | Where-Object Name -eq $siteName | ForEach-Object { $dirCheck = $dirCheck + 1 }
If ($dirCheck -eq 0){
    New-Item -ItemType directory -Path $phyPath
    Write-Output "`n`n*****************************************************`n               No Directory Detected.`n*****************************************************`n`nDirectory for $siteName has been created.`n`n"
}

#Create a New IIS App Pool
New-WebAppPool -Name $appName

#Variables
$appIdentity = Read-Host -Prompt "`n`nEnter the App Pool Identity"
$gmsaCheck = Read-Host -Prompt "`nIs this is a gMSA account? (Y/N)"

#Assign Application Pool Identity
If ($gmsaCheck -eq "Y"){
    Set-ItemProperty IIS:\AppPools\$appName -name processModel -value @{userName=$appIdentity;identitytype=3}
}
else {
    $appIdentityPassword = Read-Host -Prompt "`nEnter the App Pool Identity Password"
    Set-ItemProperty IIS:\AppPools\$appName -name processModel -value @{userName=$appIdentity;password=$appIdentityPassword;identitytype=3}
}

#Create a New Website with HTTP Binding using Newly Created App Pool
New-Website -Name $siteName -IPAddress $siteIP -Port 80 -HostHeader $hostname -PhysicalPath $phyPath -ApplicationPool $appName

#If Website Requires SSL Binding
If ($requireSSL -eq "Y"){
    #Create New SSL Web Binding for New Website
    New-WebBinding -Name $siteName -Protocol "https" -IPAddress $siteIP -Port 443 -HostHeader $hostname -SslFlags 0

    #New Variable
    $bindingInfo = Get-WebBinding -Name $siteName -Protocol "https"

    #Assign Cert to New SSL Binding
    If ($certInstalled -eq "None"){
        Write-Output "`n`n**********************************************************************************`nPlease install certificate and manually assign after the installation is complete.`n**********************************************************************************"
    } elseif ($certInstalled -eq "Internal"){
        $bindingInfo.AddSslCertificate($certHash, "My")
        Write-Output "`n`nThe Internal Wildcard certificate has been installed."
    } elseif ($certInstalled -eq "External"){
        $bindingInfo.AddSslCertificate($certHash, "My")
        Write-Output "`n`nThe External Wildcard certificate has been installed."
    } elseif ($certInstalled -eq "Manual"){
    }
}
Read-Host -Prompt "`n`nInstallation complete. Press Enter to continue..."