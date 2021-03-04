ForEach ($app in Get-IISAppPool){
    [pcustomobject]@{
        Name=$app.Name;
        Status=$app.