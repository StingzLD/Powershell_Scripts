# Gather basic info for all installed certs
dir cert: -Recurse | Where-Object { $_.Thumbprint -like "*" }

# Gather detailed information for all certs in Personal folder
Get-ChildItem -Path Cert:\LocalMachine\My -Recurse | Format-List -Property *