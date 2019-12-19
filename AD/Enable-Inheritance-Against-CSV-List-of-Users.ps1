$csvfile = Import-Csv -Path “<path to file>”

ForEach($line in $csvfile) {

Try {
$user = Get-ADUser $line.username -ErrorAction stop
} Catch {
Write-Host “Could not find $($line.username), skipping”
continue
}

# Binding the users to DS

$ou = [ADSI](“LDAP://” + $user)
$sec = $ou.psbase.objectSecurity

if ($sec.AreAccessRulesProtected) {
$isProtected = $false
## allows inheritance
$preserveInheritance = $true
## preserve inherited rules

$sec.SetAccessRuleProtection($isProtected, $preserveInheritance)
$ou.psbase.commitchanges()

Write-Host “$user is now inheriting permissions”;

} else {

Write-Host “$User Inheritable Permission already set”

}
Get-ADUser $user | Set-ADObject -Clear AdminCount

}