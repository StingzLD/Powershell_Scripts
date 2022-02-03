[System.Collections.ArrayList]$list = @(
    'Target0','Target1','Target2','Target3','Target4','Target5','Target6','Target7','Target8','Target9','Target10'
)

$jobs = @{}
$MaxConcurrent = 5
$activeJobs = 0
$listCount = $list.Count
$targetsProcessed = 0


function StartNewJob
{
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $Name
    )

    # Count the current number of jobs in $jobs
    $jobsCount = $jobs.Count

    # Create a new job
    $job = Start-Job -Name $Name -ScriptBlock $scriptBlock

    # Create a new entry in the $jobs array
    $jobs[$jobsCount] = New-Object PSObject -Property @{
        Name = $Name
        Job = $job
        Processed = $false
        Result = $null
    }

    # Get the job's information
    Write-Host "Created job: " -NoNewLine
    Write-Host "$Name" -ForegroundColor Yellow
}


function CheckForJobs ($actJobs)
{
    # If there are still items in $list
    if ($list.Count -gt 0)
    {
        Write-Host "Checking for new jobs" -ForegroundColor Cyan

        # Create blank array to store items needing to be removed from list
        $toRemove = @()

        # Iterate through list
        foreach ($target in $list)
        {
            # Check if the max number of concurrent jobs running has been met
            if ($actJobs.Value -lt $MaxConcurrent)
            {
                StartNewJob -Name $target  # If not, create a new job for the next item in the list
                $actJobs.Value += 1  # Increase the number of active jobs running by one
                $toRemove += $target  # Stage the item from the list for removal
            }
            else
            {
                # If so, stop iterating through the list
                break
            }
        }

        # Remove all items in $toRemove from $list
        foreach ($target in $toRemove)
        {
            $list.Remove($target)
        }
    }
}


function ProcessJobs ($actJobs, $targsProcessed)
{
    Write-Host "Proccessing active jobs" -ForegroundColor Cyan

    # Count the current number of jobs in $jobs
    $jobsCount = $jobs.Count

    # Iterate through $jobs array
    for ($i=0; $i -lt $jobsCount; ++$i)
    {
        # If the job has not been processed
        if ($jobs[$i].Processed -eq $false)
        {
            # If the job has completed contains result data to retrieve
            if ($jobs[$i].Job.State -eq 'Completed' -and
                    $jobs[$i].Job.HasMoreData -eq $true)
            {
                $jobs[$i].Result = $jobs[$i].Job.HasMoreData  # Add the result data it $job array data
                $jobs[$i].Processed = $true  # Mark the job as processed
                $actJobs.Value -= 1  # Decrease the number of active jobs running by one
                $targsProcessed.Value += 1  # Increase the number of jobs that have been processed by one
                Remove-Job -Name $jobs[$i].Name  # Remove the job from the system (not the $job array)
            }
        }
    }
    # Prevents the flooding of the console
    Start-Sleep -Milliseconds 1000
}


$scriptBlock = {
    $true
}


while ($targetsProcessed -lt $listCount)
{
    CheckForJobs -actJobs ([REF]$activeJobs)
    ProcessJobs -actJobs ([REF]$activeJobs) -targsProcessed ([REF]$targetsProcessed)

#    Write-Host "Current Active Jobs: $activeJobs"
    Write-Host "$targetsProcessed of $listCount jobs processed `n"
}

$jobs | Format-Table
