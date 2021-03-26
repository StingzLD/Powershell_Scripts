# Get security logs associated with logging on/off
Get-EventLog -LogName Security |
    ? {$_.EventID -in (4647,4634,4674,4624,4625)} |
    # ft TimeGenerated,EventId,Message -AutoSize –wrap      ### Uncomment if you want to view in the terminal
    Export-Csv "C:\Security_Log_Logons_Logoffs.csv"         ### Comment if you want to view in the terminal
"C:\Security_Log_Logons_Logoffs.csv"                        ### Comment if you want to view in the terminal
