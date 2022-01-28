<#
    .SYNOPSIS
        Find LastLogonDate of servers.
    .DESCRIPTION
        Queries a list of server names to determine the LastLogonDate and export
        the data to a CSV.
    .PARAMETER ServerList
        Provide the path for a single column list of server names, one server
        per row.

        For example: C:\Temp\server_list.txt
    .PARAMETER ExportPath
        Provide the path where the CSV should be exported to.

        For example: C:\Temp
#>

[CmdletBinding(DefaultParameterSetName='Default')]
param(
    [Parameter(Mandatory=$true,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
    )]
    [ValidateNotNullOrEmpty()]
    [string] $ServerList,

    [Parameter(Mandatory=$false,
            Position=1,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
    )]
    [ValidateNotNullOrEmpty()]
    [string] $ExportPath='C:\Temp'
)


$list = Get-Content $ServerList
$exportFile = "$ExportPath\Server_LastLogonDate.csv"


New-Item $exportFile

foreach ($server in $list)
{
    try
    {
        $date = Get-ADComputer -Identity $server -Properties * `
            -ErrorVariable adError -ErrorAction SilentlyContinue

        [PSCustomObject]@{
            Name = $server;
             LastLogonDate = $date.LastLogonDate;
             Error = ''
        } | Export-Csv -Path $exportFile -Append
    }
    catch
    {
        [PSCustomObject]@{
              Name = $server;
              LastLogonDate = '';
              Error = $adError[0]
        } | Export-Csv -Path $exportFile -Append
    }
}
