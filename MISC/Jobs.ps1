[System.Collections.ArrayList]$Global:list = @(
    'Target0','Target1','Target2','Target3','Target4','Target5'
)

$jobs = @{}
$Global:maxConcurrent = 5
$Global:activeJobs = 0
$listCount = $list.Count
$Global:targetsProcessed = 0


function StartNewJob
{
    param(
        [Parameter(Mandatory = $true)]
        [String]
        $Name
    )

    $jobsCount = $jobs.Count

    $job = Start-Job -Name $Name -ScriptBlock $scriptBlock
    $jobs[$jobsCount] = New-Object PSObject -Property @{
        Name = $Name
        Job = $job
        Processed = $false
        Result = $null
    }

#    Start-Sleep -Milliseconds 100
    $Global:activeJobs += 1
    Get-Job -Name $Name
}


function CheckForJobs
{
    if ($Global:list.Count -gt 0)
    {
        $toRemove = @()

        foreach ($target in $Global:list)
        {
            if ($Global:activeJobs -lt $Global:maxConcurrent)
            {
                StartNewJob -Name $target
                $toRemove += $target
            }
            else
            {
                break
            }
        }

        foreach ($target in $toRemove)
        {
            $Global:list.Remove($target)
        }
    }
}


function ProcessJobs
{
    $jobsCount = $jobs.Count

    for ($i=0; $i -lt $jobsCount; ++$i)
    {
        if ($jobs[$i].Processed -eq $false)
        {
            if ($jobs[$i].Job.State -eq 'Completed' -and $jobs[$i].Job.HasMoreData -eq $true)
            {
                $jobs[$i].Result = $jobs[$i].Job.HasMoreData
                $jobs[$i].Processed = $true
                $Global:activeJobs -= 1
                $Global:targetsProcessed += 1
                Remove-Job -Name $jobs[$i].Name
            }
        }
    }
    Start-Sleep -Milliseconds 500
}


$scriptBlock = {
    $true
}


while ($Global:targetsProcessed -lt $listCount)
{
    Write-Host "Checking for new jobs" -ForegroundColor Cyan
    CheckForJobs
    Write-Host "Current Active Jobs: $Global:activeJobs"

    Write-Host "Proccessing active jobs" -ForegroundColor Cyan
    ProcessJobs
    Write-Host "$Global:targetsProcessed of $listCount jobs processed `n"
}

$jobs | Format-List
