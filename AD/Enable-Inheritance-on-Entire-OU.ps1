$users = Get-ADUser -ldapfilter “(objectclass=user)” -searchbase “OU=<ou name>,DC=<domain name>,DC=com”

$display = ForEach($user in $users)
{
    # Binding the users to DS
    $ou = [ADSI](“LDAP://” + $user)
    $sec = $ou.psbase.objectSecurity
 
    if ($sec.get_AreAccessRulesProtected())
    {
        $isProtected = $false ## allows inheritance
        $preserveInheritance = $true ## preserve inherited rules
        $sec.SetAccessRuleProtection($isProtected, $preserveInheritance)
        $ou.psbase.commitchanges()
        Write-Output “$user is now inherting permissions”;
    }
    else
    {
        Write-Output “$User Inheritable Permission already set”
    }
}

$display | Out-File -FilePath "<path>"