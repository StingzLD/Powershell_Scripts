$scriptBlock = {
    $true
}

$jobs = @{}
$MaxConcurrent = 5

$list = $('Target0','Target1','Target2','Target3','Target4','Target5')


function StartNewJob
{
    $job = Start-Job -Name $target -ScriptBlock $scriptBlock
    $jobs[$target] = New-Object PSObject -Property @{
        Job = $job
        Result = $null
    }
}


function CheckForJobs
{
    $i = -1

    foreach ($target in $list)
    {
        ++$i
        if ($i -lt $MaxConcurrent)
        {
            StartNewJob
        }
    }
}


function ProcessJobs
{
    if ($i -ge $MaxConcurrent)
    {

    }
}


while ($null -ne $list[0])
{
    CheckForJobs
    ProcessJobs
}
