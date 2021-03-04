$list = Get-Content -Path '<insert path here>\NON-PROD(All_Phases)_ComputersList.txt'

$export = foreach ($server in $list){
    Get-NetFrameworkVersion -ComputerName $server
}

$export | Export-Csv -Path '<insert path here>\NetVersion_NON-PROD(All_Phases).csv'
