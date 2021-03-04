$list = Get-Content -Path '<insert path here>\DecommisisonList.txt'

ForEach ($name in $list){
    try{
        $adCheck = Get-AdComputer -Identity $name -ErrorAction SilentlyContinue
        If ($adCheck){
            "$name" | Out-File -Append '<insert path here>\DecommisisonList.csv'
        }
    } catch {
    }
}
