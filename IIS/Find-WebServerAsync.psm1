function Find-WebServerAsync
{    
    <#
    .Synopsis
       Queries the list of servers in batches looking for the world wide web service 'w3svc'
    .DESCRIPTION
       Proxy function for Get-Service
    .PARAMETER MaxConcurrent
       Specifies the maximum number of Find-WebServerAsync commands to run at a time.
    #>
    
    [CmdletBinding(DefaultParameterSetName='Default')]
    param(
        [Parameter(Mandatory=$true, Position=0, ValueFromPipeline=$true, ValueFromPipelineByPropertyName=$true)]
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
            Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState
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
            
            $quietStatus = New-Object psobject -Property @{Name = $Jobs[$Index].Target; Success = $false}
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

                if ($null -ne $jobs[$i] -and $jobs[$i].Job.JobStateInfo.State -ne [System.Management.Automation.JobState]::Running)
                {
                    ProcessCompletedJob -Jobs $jobs -Index $i -Quiet:$Quiet
                }
                
                if ($null -eq $jobs[$i])
                {
                    Write-Verbose "Job ${i}: Testing ${target}."

                    $job = Start-Job -ScriptBlock {(Get-Service -ComputerName $args[0] -ServiceName "W3SVC" -ErrorAction SilentlyContinue) -ne $null} -ArgumentList $target #@PSBoundParameters
                    $jobs[$i] = New-Object psobject -Property @{Target = $target; Job = $job}

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
                    if ($jobs[$i].Job.JobStateInfo.State -ne [System.Management.Automation.JobState]::Running)
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