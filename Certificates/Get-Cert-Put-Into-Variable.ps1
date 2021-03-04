#View Currently Installed Cert Hashes
dir Cert:\LocalMachine\My


$certPath = "Cert:\LocalMachine\My"
$certName = "*"

#Put First Hash into Variable
$cert = (Get-ChildItem $certPath | Where-Object { $_.Subject -like "*$certName*" } | Select-Object -First 1).Thumbprint

#Put Second+ Hash into Variable (change "Skip" parameter to select appropriate hash)
#$cert = (Get-ChildItem $certPath | Where-Object { $_.Subject -like "*$certName*" } | Select-Object -Skip 1).Thumbprint

#Put Last Hash into Variable
#$cert = (Get-ChildItem $certPath | Where-Object { $_.Subject -like "*$certName*" } | Select-Object -Last 1).Thumbprint




$certPath = "Cert:\LocalMachine\My"
$certName = "*"

#Put First Hash into Variable
Get-ChildItem $certPath | Where-Object { $_.Subject -like "*$certName*" }