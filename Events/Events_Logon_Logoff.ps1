# Get security logs associated with logging on/off
Get-EventLog -LogName Security |
    ? {$_.EventID -in (4647,4634,4674,4624,4625)} |
    # ft TimeGenerated,EventId,Message -AutoSize –wrap |
    Export-Csv "C:\Security_Log_Logons_Logoffs.csv"
"C:\Security_Log_Logons_Logoffs.csv"
