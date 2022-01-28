<#
    .SYNOPSIS
        Queries servers in AD looking for the world wide web service 'w3svc'
    .DESCRIPTION
        The purpose of this script is to query Active Directory to gather a list
        of enabled machines running a Windows Server OS and connect to each of
        those to query if W3SVC is installed. The results will be exported into
        a CSV file located at the default path: C:\Temp

        Sample Exported File: C:\Temp\1969-12-13_Web_Servers.csv

        IMPORTANT NOTE
        This script must be run as Administrator in order for the query to be
        successful. Otherwise, all results will come back as "Not Installed".
    .PARAMETER ExportPath
        Optional parameter to provide the path where the CSV is exported to.

        Example: C:\Temp
    .PARAMETER ServerList
        Optional parameter that allows you to provide the path for a single
        column list of server names, one server name per row. The script will
        use the list provided, rather than query AD for all servers.

        Example: C:\Temp\server_list.txt

        IMPORTANT NOTE
        Use only the hostname, not the FQDN. Anything other than the hostname
        will cause the script script to fail.

        Sample server_list.txt:
            Server1
            Server2
            Server3
#>

[CmdletBinding(DefaultParameterSetName='Default')]
param(
    [Parameter(Mandatory=$false,
            Position=0,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
    )]
    [ValidateNotNullOrEmpty()]
    [string] $ExportPath='C:\Temp',

    [Parameter(Mandatory=$false,
            Position=1,
            ValueFromPipeline=$true,
            ValueFromPipelineByPropertyName=$true
    )]
    [ValidateNotNullOrEmpty()]
    [string] $ServerList=$null
)

###############################################################################
#                                  FUNCTIONS                                  #
###############################################################################

function Find-WebServerAsync
{
    <#
    .SYNOPSIS
       Queries the list of servers in batches looking for the world wide web
       service 'w3svc'
    .DESCRIPTION
       Proxy function for Get-Service
    .PARAMETER MaxConcurrent
       Specifies the maximum number of Find-WebServerAsync commands to run at
       a time.
    #>

    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(Mandatory=$true,
                Position=0,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
        )]
        [ValidateNotNullOrEmpty()]
        [string[]] ${Name},

        [ValidateRange(1, 60)]
        [System.Int32]
        ${Delay},

        [ValidateScript({$_ -ge 1})]
        [System.UInt32]
        $MaxConcurrent = 20,

        [Parameter(ParameterSetName='Quiet')]
        [Switch]
        $Quiet
    )

    begin
    {
        if ($null -ne ${function:Get-CallerPreference})
        {
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState `
                $ExecutionContext.SessionState
        }

        $null = $PSBoundParameters.Remove('MaxConcurrent')
        $null = $PSBoundParameters.Remove('Quiet')

        $jobs = @{}
        $i = -1

        function ProcessCompletedJob
        {
            [CmdletBinding()]
            param (
                [Parameter(Mandatory = $true)]
                [hashtable]
                $Jobs,

                [Parameter(Mandatory = $true)]
                [int]
                $Index,

                [switch]
                $Quiet
            )

            $quietStatus = New-Object psobject -Property @{Name = `
                $Jobs[$Index].Target; Success = $false}

            if ($Jobs[$Index].Job.HasMoreData)
            {
                foreach ($result in (Receive-Job $Jobs[$Index].Job))
                {
                    if ($Quiet)
                    {
                        $quietStatus.Success = $result
                        break
                    }

                    else
                    {
                        Write-Output $result
                    }
                }
            }

            if ($Quiet)
            {
                Write-Output $quietStatus
            }

            Remove-Job -Job $Jobs[$Index].Job -Force
            $Jobs[$Index] = $null

        } # function ProcessCompletedJob

    } # begin

    process
    {
        $null = $PSBoundParameters.Remove('Name')

        foreach ($target in $Name)
        {
            while ($true)
            {
                if (++$i -eq $MaxConcurrent)
                {
                    Start-Sleep -Milliseconds 100
                    $i = 0
                }

                if ($null -ne $jobs[$i] -and $jobs[$i].Job.JobStateInfo.State `
                        -ne [System.Management.Automation.JobState]::Running)
                {
                    ProcessCompletedJob -Jobs $jobs -Index $i -Quiet:$Quiet
                }

                if ($null -eq $jobs[$i])
                {
                    Write-Verbose "Job ${i}: Testing ${target}."

                    $job = Start-Job -ScriptBlock {
                        (Get-Service -ComputerName $args[0] -ServiceName "W3SVC" `
                        -ErrorAction SilentlyContinue) -ne $null} -ArgumentList `
                        $target #@PSBoundParameters
                    $jobs[$i] = New-Object psobject -Property @{
                        Target = $target;
                        Job = $job}

                    break
                }
            }
        }
    }

    end
    {
        while ($true)
        {
            $foundActive = $false

            for ($i = 0; $i -lt $MaxConcurrent; $i++)
            {
                if ($null -ne $jobs[$i])
                {
                    if ($jobs[$i].Job.JobStateInfo.State -ne `
                        [System.Management.Automation.JobState]::Running)
                    {
                        ProcessCompletedJob -Jobs $jobs -Index $i -Quiet:$Quiet
                    }
                    else
                    {
                        $foundActive = $true
                    }
                }
            }

            if (-not $foundActive)
            {
                break
            }
            Start-Sleep -Milliseconds 100
        }
    }

} # function Find-WebServerAsync


function Get-W3SVC
{
    <#
        .SYNOPSIS
           Runs job to check if W3SVC is installed.
        .DESCRIPTION
           Creates a job that runs Find-WebServerAsync to check if the W3SVC is
           installed. If the job times out, it is forced to stop. If not, the
           job reports back on whether or not the service is installed.
    #>


    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(Mandatory=$true,
                Position=0,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Name,

        [Parameter(Mandatory=$true,
                Position=1,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Timout
    )


    # Code to be executed in job
    $code =
    {
        Param ($Name)

        Find-WebServerAsync -Name $Name -Quiet |
            Where-Object {$_.Success -eq $true}
    }
    # Creates background job using the specified code
    $job = Start-Job -InitializationScript $export_functions `
        -ArgumentList $Name -ScriptBlock $code

    # Wait until the job termiantes or times out
    if (Wait-Job $job -Timeout $Timeout)
    {
        # If the job terminated, get the result
        $results = Receive-Job $job
    }

    # Remove the job, even if it is still running
    Remove-Job -force $job

    # Returns results from successfully terminated jobs
    return $results
}


function Append-CSV
{
    <#
        .SYNOPSIS
           Appends CSV with query results
        .DESCRIPTION
           Appends the CSV with the Name, Result, and Error (if one exists)
           acquired from the query.
    #>


    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(Mandatory=$true,
                Position=0,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Result,

        [Parameter(Mandatory=$false,
                Position=1,
                ValueFromPipeline=$true,
                ValueFromPipelineByPropertyName=$true
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Error=''
    )

    # Append CSV with Test-NetConnection Warning
    [PSCustomObject]@{
            Name = $server;
            Result = $Result;
            Error = $Error
    } | Export-Csv -Path $csvFile -Append
}


###############################################################################
#                                  VARIABLES                                  #
###############################################################################

# Function export for use in Check-W3SVC job
$export_functions = [ScriptBlock]::Create(@"
    Function Find-WebServerAsync {${function:Find-WebServerAsync} }
"@)

# Timeout for Wait-Job
$timeout = 30

# CSV file details
$date = Get-Date -Format "yyyy-MM-dd"
$filePath = "$ExportPath\"
$csvName = '_Web_Servers.csv'
$csvFile = $filePath + $date + $csvName


###############################################################################
#                                  MAIN CODE                                  #
###############################################################################

# Create a blank CSV file
if (-Not $csvFile)
{
    New-Item $csvFile
}

if ($ServerList)
{
    # Import list of server names
    $servers = Get-Content $ServerList
}
else
{
    # Gather list of all servers in Active Directory
    $servers = (Get-ADComputer -Filter {
        Enabled -eq $true -and OperatingSystem -like '*Windows Server*'
        } -Properties Name | Sort-Object Name).Name
}

foreach ($server in $servers)
{
    $hostname = "$server.topgolfusa.com"

    Write-Host "Testing connection to $server"

    # Check to see if host is reachable
    $testConn = Test-NetConnection -ComputerName $hostname `
        -InformationLevel Detailed -WarningVariable connectionError `
        -WarningAction SilentlyContinue

    # If host is reachable
    if ($testConn.PingSucceeded)
    {
        try
        {
            Write-Host "Checking if " -NoNewline
            Write-Host "$server " -ForegroundColor Cyan -NoNewline
            Write-Host "has IIS installed: " -NoNewline

            # Check if the W3SVC is installed
            $hasIIS = Get-W3SVC -Name $hostname -Timout $timeout

            # If W3SVC is installed
            if ($hasIIS.Success)
            {
                Write-Host "Installed" -ForegroundCOlor Green

                # Append CSV with W3SVC result
                Append-CSV -Result 'Installed'
            }
            else
            {
                Write-Host "Not Installed" -ForegroundCOlor DarkGray

                # Append CSV with W3SVC result
                Append-CSV -Result 'Not Installed'
            }
        }
        catch
        {
            Write-Host $Error[0] -ForegroundColor Red

            # Append CSV with Error
            Append-CSV -Result 'Error' -Error $Error[0]
        }
    }
    else
    {
        Write-Host $connectionError[0] -ForegroundColor Yellow

        # Append CSV with Test-NetConnection Warning
        Append-CSV -Result 'Error' -Error $connectionError[0]
    }
}
