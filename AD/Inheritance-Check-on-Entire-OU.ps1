$users = Get-ADUser -ldapfilter “(objectclass=user)” -searchbase “OU=<ou name>,DC=<domain name>,DC=com”
ForEach($user in $users)
{
    # Binding the users to DS
    $ou = [ADSI](“LDAP://” + $user)
    $sec = $ou.psbase.objectSecurity
 
    if ($sec.get_AreAccessRulesProtected())
    {
        $isProtected = $false ## allows inheritance
        $preserveInheritance = $true ## preserver inhreited rules
        Write-Host “$user Inheritable Permission Disabled”;
    }
    else
    {
        Continue
    }
}