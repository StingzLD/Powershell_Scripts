<# Get security logs associated with logging on/off

Event ID 4624: "An account was successfully logged on."
                This event is generated when a logon session is created.
                It is generated on the computer that was accessed.
Event ID 4634: "An account was logged off."
                This event is generated when a logon session is destroyed.
                It may be positively correlated with a logon event using the Logon ID value.
                Logon IDs are only unique between reboots on the same computer.
Event ID 4647: "User initiated logoff"
                This event signals the end of a logon session and can be correlated back to
                the logon event 4624 using the Logon ID. This event appears in place of 4634
                in the case of Interactive and RemoteInteractive (remote desktop) logons.
Event ID 4625: "An account failed to log on."
                This event is generated when a logon request fails.
                It is generated on the computer where access was attempted.

#>
Get-EventLog -LogName Security |
    ? {$_.EventID -in (4624,4634,4647,4625)} |
    # ft TimeGenerated,EventId,Message -AutoSize –wrap      ### Uncomment if you want to view in the terminal
    Export-Csv "C:\Security_Log_Logons_Logoffs.csv"         ### Comment if you want to view in the terminal
"C:\Security_Log_Logons_Logoffs.csv"                        ### Comment if you want to view in the terminal
