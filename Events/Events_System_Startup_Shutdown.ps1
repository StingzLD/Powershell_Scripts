<# Get security events associated with system startup/shutdown

Event ID 6005: “The event log service was started.”
                This is synonymous to system startup.
Event ID 6006: “The event log service was stopped.”
                This is synonymous to system shutdown.
Event ID 6008: "The previous system shutdown was unexpected."
                Records that the system started after it was not shut down properly.
Event ID 6009:  Indicates the Windows product name, version, build number, service pack
                number, and operating system type detected at boot time.
Event ID 6013:  Displays the uptime of the computer. There is no TechNet page for this id.
Event ID 1074: "The process X has initiated the restart / shutdown of computer on behalf
                of user Y for the following reason: Z." Indicates that an application or
                a user initiated a restart or shutdown.
Event ID 1076: "The reason supplied by user X for the last unexpected shutdown of this
                computer is: Y."
                Records when the first user with shutdown privileges logs on to the computer
                after an unexpected restart or shutdown and supplies a reason for the occurrence.
#>
Get-EventLog -LogName System |
    ? {$_.EventID -in (6005,6006,6008,6009,1074,1076)} |
    ft TimeGenerated,EventId,Message -AutoSize –wrap |
    Export-Csv "C:\Application_Log_Startup_Shutdown.csv"
"C:\Application_Log_Startup_Shutdown.csv"
