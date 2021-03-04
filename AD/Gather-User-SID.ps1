$objUser = New-Object System.Security.Principal.NTAccount("7691")
$strSID = $objUser.Translate([System.Security.Principal.SecurityIdentifier])
$strSID.Value