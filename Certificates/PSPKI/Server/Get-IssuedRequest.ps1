﻿function Get-IssuedRequest {
<#
.ExternalHelp PSPKI.Help.xml
#>
[OutputType('SysadminsLV.PKI.Management.CertificateServices.Database.AdcsDbRow[]')]
[CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('CA')]
        [PKI.CertificateServices.CertificateAuthority[]]$CertificationAuthority,
        [ValidateRange(2,2147483647)]
        [Alias('ID')]
        [int[]]$RequestID,
        [ValidateRange(1,2147483647)]
        [int]$Page = 1,
        [int]$PageSize = [int]::MaxValue,
        [Alias("Properties", "IncludeProperty", "IncludeProperties", "IncludedProperty", "IncludedProperties")]
        [String[]]$Property,
        [String[]]$Filter
    )
    process {
        foreach ($CA in $CertificationAuthority) {
            Get-AdcsDatabaseRow `
            -CA $CA `
            -Table "Issued" `
            -RowId $RequestID `
            -Page $Page `
            -PageSize $PageSize `
            -Property $Property `
            -Filter $Filter
        }        
    }
}
# SIG # Begin signature block
# MIIfhgYJKoZIhvcNAQcCoIIfdzCCH3MCAQExDzANBglghkgBZQMEAgEFADB5Bgor
# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG
# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDEYVnXNph6sp+y
# nR1eqM0CluDCIgWTysQQW8v7Gew04aCCGYYwggX1MIID3aADAgECAhAdokgwb5sm
# GNCC4JZ9M9NqMA0GCSqGSIb3DQEBDAUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UE
# CBMKTmV3IEplcnNleTEUMBIGA1UEBxMLSmVyc2V5IENpdHkxHjAcBgNVBAoTFVRo
# ZSBVU0VSVFJVU1QgTmV0d29yazEuMCwGA1UEAxMlVVNFUlRydXN0IFJTQSBDZXJ0
# aWZpY2F0aW9uIEF1dGhvcml0eTAeFw0xODExMDIwMDAwMDBaFw0zMDEyMzEyMzU5
# NTlaMHwxCzAJBgNVBAYTAkdCMRswGQYDVQQIExJHcmVhdGVyIE1hbmNoZXN0ZXIx
# EDAOBgNVBAcTB1NhbGZvcmQxGDAWBgNVBAoTD1NlY3RpZ28gTGltaXRlZDEkMCIG
# A1UEAxMbU2VjdGlnbyBSU0EgQ29kZSBTaWduaW5nIENBMIIBIjANBgkqhkiG9w0B
# AQEFAAOCAQ8AMIIBCgKCAQEAhiKNMoV6GJ9J8JYvYwgeLdx8nxTP4ya2JWYpQIZU
# RnQxYsUQ7bKHJ6aZy5UwwFb1pHXGqQ5QYqVRkRBq4Etirv3w+Bisp//uLjMg+gwZ
# iahse60Aw2Gh3GllbR9uJ5bXl1GGpvQn5Xxqi5UeW2DVftcWkpwAL2j3l+1qcr44
# O2Pej79uTEFdEiAIWeg5zY/S1s8GtFcFtk6hPldrH5i8xGLWGwuNx2YbSp+dgcRy
# QLXiX+8LRf+jzhemLVWwt7C8VGqdvI1WU8bwunlQSSz3A7n+L2U18iLqLAevRtn5
# RhzcjHxxKPP+p8YU3VWRbooRDd8GJJV9D6ehfDrahjVh0wIDAQABo4IBZDCCAWAw
# HwYDVR0jBBgwFoAUU3m/WqorSs9UgOHYm8Cd8rIDZsswHQYDVR0OBBYEFA7hOqhT
# OjHVir7Bu61nGgOFrTQOMA4GA1UdDwEB/wQEAwIBhjASBgNVHRMBAf8ECDAGAQH/
# AgEAMB0GA1UdJQQWMBQGCCsGAQUFBwMDBggrBgEFBQcDCDARBgNVHSAECjAIMAYG
# BFUdIAAwUAYDVR0fBEkwRzBFoEOgQYY/aHR0cDovL2NybC51c2VydHJ1c3QuY29t
# L1VTRVJUcnVzdFJTQUNlcnRpZmljYXRpb25BdXRob3JpdHkuY3JsMHYGCCsGAQUF
# BwEBBGowaDA/BggrBgEFBQcwAoYzaHR0cDovL2NydC51c2VydHJ1c3QuY29tL1VT
# RVJUcnVzdFJTQUFkZFRydXN0Q0EuY3J0MCUGCCsGAQUFBzABhhlodHRwOi8vb2Nz
# cC51c2VydHJ1c3QuY29tMA0GCSqGSIb3DQEBDAUAA4ICAQBNY1DtRzRKYaTb3moq
# jJvxAAAeHWJ7Otcywvaz4GOz+2EAiJobbRAHBE++uOqJeCLrD0bs80ZeQEaJEvQL
# d1qcKkE6/Nb06+f3FZUzw6GDKLfeL+SU94Uzgy1KQEi/msJPSrGPJPSzgTfTt2Sw
# piNqWWhSQl//BOvhdGV5CPWpk95rcUCZlrp48bnI4sMIFrGrY1rIFYBtdF5KdX6l
# uMNstc/fSnmHXMdATWM19jDTz7UKDgsEf6BLrrujpdCEAJM+U100pQA1aWy+nyAl
# EA0Z+1CQYb45j3qOTfafDh7+B1ESZoMmGUiVzkrJwX/zOgWb+W/fiH/AI57SHkN6
# RTHBnE2p8FmyWRnoao0pBAJ3fEtLzXC+OrJVWng+vLtvAxAldxU0ivk2zEOS5LpP
# 8WKTKCVXKftRGcehJUBqhFfGsp2xvBwK2nxnfn0u6ShMGH7EezFBcZpLKewLPVdQ
# 0srd/Z4FUeVEeN0B3rF1mA1UJP3wTuPi+IO9crrLPTru8F4XkmhtyGH5pvEqCgul
# ufSe7pgyBYWe6/mDKdPGLH29OncuizdCoGqC7TtKqpQQpOEN+BfFtlp5MxiS47V1
# +KHpjgolHuQe8Z9ahyP/n6RRnvs5gBHN27XEp6iAb+VT1ODjosLSWxr6MiYtaldw
# HDykWC6j81tLB9wyWfOHpxptWDCCBkowggUyoAMCAQICEBdBS6OH2/E/xEs3Bf5c
# krcwDQYJKoZIhvcNAQELBQAwfDELMAkGA1UEBhMCR0IxGzAZBgNVBAgTEkdyZWF0
# ZXIgTWFuY2hlc3RlcjEQMA4GA1UEBxMHU2FsZm9yZDEYMBYGA1UEChMPU2VjdGln
# byBMaW1pdGVkMSQwIgYDVQQDExtTZWN0aWdvIFJTQSBDb2RlIFNpZ25pbmcgQ0Ew
# HhcNMTkwODEzMDAwMDAwWhcNMjIwODEyMjM1OTU5WjCBmTELMAkGA1UEBhMCVVMx
# DjAMBgNVBBEMBTk3MjE5MQ8wDQYDVQQIDAZPcmVnb24xETAPBgNVBAcMCFBvcnRs
# YW5kMRwwGgYDVQQJDBMxNzEwIFNXIE1pbGl0YXJ5IFJkMRswGQYDVQQKDBJQS0kg
# U29sdXRpb25zIEluYy4xGzAZBgNVBAMMElBLSSBTb2x1dGlvbnMgSW5jLjCCAiIw
# DQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBANC9ao+Uw7Owaxi+v5FF1+eKGIpv
# QnKBFu61VsoHFyotJ8yoeC8tiRjmHggRbmQm0sTAdAXw23Rj5ZW6ndMWgA258car
# a6+oWB071e3ctsHoavc7NkDoCkKS2uh5tTmqclNMg6xaU1IIp9IWFq00K1jkeXex
# HIFLjTF2AA2SEteJO6VY08EiN6ktAOa1P4NbB0fTRUmca0j3W552hvU5Ig8G0DJt
# b4IDMMnu6WllNuxfqyNJiUOYkDET1p52XzvhMFMFnhbsH9JPcR4IA7Pp4xc1mRhe
# D9uE+KVx1astA/GvWtkpeZy/efbaMOxY4VuTW9kdgc8tB4VPamQQpoVmD3ULsaPz
# iv8cOum0CMrTtwKA/meas20A69u3xg8KeuDwxE0rysT4a68lXjFZViyHQQQzeZi4
# wAifk3URIABuKy6DQdQ4FJRjIvAXh5PD2WatY7aJJw9nc0biEB7bEjDNYufJ4OL9
# M9ibVqQxpLz0Vm9D+aCD1CJFySCcIOg7VRWCNyTqtDxDlWd6I7H1s2QwsiEWIOCE
# MtOlve+rZi9RgJhtrdoINgmgSPNH+lITexCMrNDvpEzYxggsTLcEs4jq6XzoD/bR
# G9gvSv/d5Di8Js0gjaqpwDZbLsProdRFX0AlAROarTVW0m9nqVHcP4o0Lc/jKCJ6
# 8073khO+aMOJKW/9AgMBAAGjggGoMIIBpDAfBgNVHSMEGDAWgBQO4TqoUzox1Yq+
# wbutZxoDha00DjAdBgNVHQ4EFgQUd9YCgc1i67qdUtY6jeRnT0YzsVAwDgYDVR0P
# AQH/BAQDAgeAMAwGA1UdEwEB/wQCMAAwEwYDVR0lBAwwCgYIKwYBBQUHAwMwEQYJ
# YIZIAYb4QgEBBAQDAgQQMEAGA1UdIAQ5MDcwNQYMKwYBBAGyMQECAQMCMCUwIwYI
# KwYBBQUHAgEWF2h0dHBzOi8vc2VjdGlnby5jb20vQ1BTMEMGA1UdHwQ8MDowOKA2
# oDSGMmh0dHA6Ly9jcmwuc2VjdGlnby5jb20vU2VjdGlnb1JTQUNvZGVTaWduaW5n
# Q0EuY3JsMHMGCCsGAQUFBwEBBGcwZTA+BggrBgEFBQcwAoYyaHR0cDovL2NydC5z
# ZWN0aWdvLmNvbS9TZWN0aWdvUlNBQ29kZVNpZ25pbmdDQS5jcnQwIwYIKwYBBQUH
# MAGGF2h0dHA6Ly9vY3NwLnNlY3RpZ28uY29tMCAGA1UdEQQZMBeBFWluZm9AcGtp
# c29sdXRpb25zLmNvbTANBgkqhkiG9w0BAQsFAAOCAQEAa4IZBlHU1V6Dy+atjrwS
# YugL+ryvzR1eGH5+nzbwxAi4h3IaknQBIuWzoamR+hRUga9/Rd4jrBbXGTgkqM7A
# tnzXP7P5NZOmxOdFOl1UfgNIv5MfJNPzsvn54bnx9rgKWJlpmKPCr1xtfj2ERlhA
# f6ADOfUyCcTnSwlBi1Bai60wqqDPuj1zcDaD2XGddVmqVrplx1zNoX7vhyErA7V9
# psRWQYIflYY0L58gposEUVMKM6TJRRjndibRnO2CI9plXDBz4j3cTni3fXGM3UuB
# VInKSeC+mTsvJVYTHjBowWohhxMBdqD0xFVbysoRKGtWSJwErdAomjMCrY2q6oYc
# xzCCBmowggVSoAMCAQICEAMBmgI6/1ixa9bV6uYX8GYwDQYJKoZIhvcNAQEFBQAw
# YjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQ
# d3d3LmRpZ2ljZXJ0LmNvbTEhMB8GA1UEAxMYRGlnaUNlcnQgQXNzdXJlZCBJRCBD
# QS0xMB4XDTE0MTAyMjAwMDAwMFoXDTI0MTAyMjAwMDAwMFowRzELMAkGA1UEBhMC
# VVMxETAPBgNVBAoTCERpZ2lDZXJ0MSUwIwYDVQQDExxEaWdpQ2VydCBUaW1lc3Rh
# bXAgUmVzcG9uZGVyMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAo2Rd
# /Hyz4II14OD2xirmSXU7zG7gU6mfH2RZ5nxrf2uMnVX4kuOe1VpjWwJJUNmDzm9m
# 7t3LhelfpfnUh3SIRDsZyeX1kZ/GFDmsJOqoSyyRicxeKPRktlC39RKzc5YKZ6O+
# YZ+u8/0SeHUOplsU/UUjjoZEVX0YhgWMVYd5SEb3yg6Np95OX+Koti1ZAmGIYXIY
# aLm4fO7m5zQvMXeBMB+7NgGN7yfj95rwTDFkjePr+hmHqH7P7IwMNlt6wXq4eMfJ
# Bi5GEMiN6ARg27xzdPpO2P6qQPGyznBGg+naQKFZOtkVCVeZVjCT88lhzNAIzGvs
# YkKRrALA76TwiRGPdwIDAQABo4IDNTCCAzEwDgYDVR0PAQH/BAQDAgeAMAwGA1Ud
# EwEB/wQCMAAwFgYDVR0lAQH/BAwwCgYIKwYBBQUHAwgwggG/BgNVHSAEggG2MIIB
# sjCCAaEGCWCGSAGG/WwHATCCAZIwKAYIKwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRp
# Z2ljZXJ0LmNvbS9DUFMwggFkBggrBgEFBQcCAjCCAVYeggFSAEEAbgB5ACAAdQBz
# AGUAIABvAGYAIAB0AGgAaQBzACAAQwBlAHIAdABpAGYAaQBjAGEAdABlACAAYwBv
# AG4AcwB0AGkAdAB1AHQAZQBzACAAYQBjAGMAZQBwAHQAYQBuAGMAZQAgAG8AZgAg
# AHQAaABlACAARABpAGcAaQBDAGUAcgB0ACAAQwBQAC8AQwBQAFMAIABhAG4AZAAg
# AHQAaABlACAAUgBlAGwAeQBpAG4AZwAgAFAAYQByAHQAeQAgAEEAZwByAGUAZQBt
# AGUAbgB0ACAAdwBoAGkAYwBoACAAbABpAG0AaQB0ACAAbABpAGEAYgBpAGwAaQB0
# AHkAIABhAG4AZAAgAGEAcgBlACAAaQBuAGMAbwByAHAAbwByAGEAdABlAGQAIABo
# AGUAcgBlAGkAbgAgAGIAeQAgAHIAZQBmAGUAcgBlAG4AYwBlAC4wCwYJYIZIAYb9
# bAMVMB8GA1UdIwQYMBaAFBUAEisTmLKZB+0e36K+Vw0rZwLNMB0GA1UdDgQWBBRh
# Wk0ktkkynUoqeRqDS/QeicHKfTB9BgNVHR8EdjB0MDigNqA0hjJodHRwOi8vY3Js
# My5kaWdpY2VydC5jb20vRGlnaUNlcnRBc3N1cmVkSURDQS0xLmNybDA4oDagNIYy
# aHR0cDovL2NybDQuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEQ0EtMS5j
# cmwwdwYIKwYBBQUHAQEEazBpMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQQYIKwYBBQUHMAKGNWh0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRENBLTEuY3J0MA0GCSqGSIb3DQEBBQUAA4IBAQCd
# JX4bM02yJoFcm4bOIyAPgIfliP//sdRqLDHtOhcZcRfNqRu8WhY5AJ3jbITkWkD7
# 3gYBjDf6m7GdJH7+IKRXrVu3mrBgJuppVyFdNC8fcbCDlBkFazWQEKB7l8f2P+fi
# EUGmvWLZ8Cc9OB0obzpSCfDscGLTYkuw4HOmksDTjjHYL+NtFxMG7uQDthSr849D
# p3GdId0UyhVdkkHa+Q+B0Zl0DSbEDn8btfWg8cZ3BigV6diT5VUW8LsKqxzbXEgn
# Zsijiwoc5ZXarsQuWaBh3drzbaJh6YoLbewSGL33VVRAA5Ira8JRwgpIr7DUbuD0
# FAo6G+OPPcqvao173NhEMIIGzTCCBbWgAwIBAgIQBv35A5YDreoACus/J7u6GzAN
# BgkqhkiG9w0BAQUFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQg
# SW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2Vy
# dCBBc3N1cmVkIElEIFJvb3QgQ0EwHhcNMDYxMTEwMDAwMDAwWhcNMjExMTEwMDAw
# MDAwWjBiMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSEwHwYDVQQDExhEaWdpQ2VydCBBc3N1cmVk
# IElEIENBLTEwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDogi2Z+crC
# QpWlgHNAcNKeVlRcqcTSQQaPyTP8TUWRXIGf7Syc+BZZ3561JBXCmLm0d0ncicQK
# 2q/LXmvtrbBxMevPOkAMRk2T7It6NggDqww0/hhJgv7HxzFIgHweog+SDlDJxofr
# Nj/YMMP/pvf7os1vcyP+rFYFkPAyIRaJxnCI+QWXfaPHQ90C6Ds97bFBo+0/vtuV
# SMTuHrPyvAwrmdDGXRJCgeGDboJzPyZLFJCuWWYKxI2+0s4Grq2Eb0iEm09AufFM
# 8q+Y+/bOQF1c9qjxL6/siSLyaxhlscFzrdfx2M8eCnRcQrhofrfVdwonVnwPYqQ/
# MhRglf0HBKIJAgMBAAGjggN6MIIDdjAOBgNVHQ8BAf8EBAMCAYYwOwYDVR0lBDQw
# MgYIKwYBBQUHAwEGCCsGAQUFBwMCBggrBgEFBQcDAwYIKwYBBQUHAwQGCCsGAQUF
# BwMIMIIB0gYDVR0gBIIByTCCAcUwggG0BgpghkgBhv1sAAEEMIIBpDA6BggrBgEF
# BQcCARYuaHR0cDovL3d3dy5kaWdpY2VydC5jb20vc3NsLWNwcy1yZXBvc2l0b3J5
# Lmh0bTCCAWQGCCsGAQUFBwICMIIBVh6CAVIAQQBuAHkAIAB1AHMAZQAgAG8AZgAg
# AHQAaABpAHMAIABDAGUAcgB0AGkAZgBpAGMAYQB0AGUAIABjAG8AbgBzAHQAaQB0
# AHUAdABlAHMAIABhAGMAYwBlAHAAdABhAG4AYwBlACAAbwBmACAAdABoAGUAIABE
# AGkAZwBpAEMAZQByAHQAIABDAFAALwBDAFAAUwAgAGEAbgBkACAAdABoAGUAIABS
# AGUAbAB5AGkAbgBnACAAUABhAHIAdAB5ACAAQQBnAHIAZQBlAG0AZQBuAHQAIAB3
# AGgAaQBjAGgAIABsAGkAbQBpAHQAIABsAGkAYQBiAGkAbABpAHQAeQAgAGEAbgBk
# ACAAYQByAGUAIABpAG4AYwBvAHIAcABvAHIAYQB0AGUAZAAgAGgAZQByAGUAaQBu
# ACAAYgB5ACAAcgBlAGYAZQByAGUAbgBjAGUALjALBglghkgBhv1sAxUwEgYDVR0T
# AQH/BAgwBgEB/wIBADB5BggrBgEFBQcBAQRtMGswJAYIKwYBBQUHMAGGGGh0dHA6
# Ly9vY3NwLmRpZ2ljZXJ0LmNvbTBDBggrBgEFBQcwAoY3aHR0cDovL2NhY2VydHMu
# ZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNydDCBgQYDVR0f
# BHoweDA6oDigNoY0aHR0cDovL2NybDMuZGlnaWNlcnQuY29tL0RpZ2lDZXJ0QXNz
# dXJlZElEUm9vdENBLmNybDA6oDigNoY0aHR0cDovL2NybDQuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0QXNzdXJlZElEUm9vdENBLmNybDAdBgNVHQ4EFgQUFQASKxOYspkH
# 7R7for5XDStnAs0wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wDQYJ
# KoZIhvcNAQEFBQADggEBAEZQPsm3KCSnOB22WymvUs9S6TFHq1Zce9UNC0Gz7+x1
# H3Q48rJcYaKclcNQ5IK5I9G6OoZyrTh4rHVdFxc0ckeFlFbR67s2hHfMJKXzBBlV
# qefj56tizfuLLZDCwNK1lL1eT7EF0g49GqkUW6aGMWKoqDPkmzmnxPXOHXh2lCVz
# 5Cqrz5x2S+1fwksW5EtwTACJHvzFebxMElf+X+EevAJdqP77BzhPDcZdkbkPZ0XN
# 1oPt55INjbFpjE/7WeAjD9KqrgB87pxCDs+R1ye3Fu4Pw718CqDuLAhVhSK46xga
# TfwqIa1JMYNHlXdx3LEbS0scEJx3FMGdTy9alQgpECYxggVWMIIFUgIBATCBkDB8
# MQswCQYDVQQGEwJHQjEbMBkGA1UECBMSR3JlYXRlciBNYW5jaGVzdGVyMRAwDgYD
# VQQHEwdTYWxmb3JkMRgwFgYDVQQKEw9TZWN0aWdvIExpbWl0ZWQxJDAiBgNVBAMT
# G1NlY3RpZ28gUlNBIENvZGUgU2lnbmluZyBDQQIQF0FLo4fb8T/ESzcF/lyStzAN
# BglghkgBZQMEAgEFAKCBhDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqG
# SIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3
# AgEVMC8GCSqGSIb3DQEJBDEiBCD6phsl2pSQ1UKgQ2Oe6DStyAm4M5K5qPO4Y3/q
# PzCRKjANBgkqhkiG9w0BAQEFAASCAgBq9Ek4G4Tv5MEHaynpy0XyuNQXPVwGTSjS
# LYktxjDn4MsAIY5H5jX4BxZRNrp2QfYhjuWnbA5ixk9aKuJm0/9buixKohCcocVR
# UPZGMxYgQInm5RiEP/9SpWQIyOMaBsCXMk3+4hgLtjjEAlb/dlWKGHH1DJANmSuL
# OmqFIwCG82lTqb3lRBUp8GSNEDc4pxMZfj/5XITu+LW73V41Y41ShKsav/IfoPXQ
# hXmuIh3yLBVrIRGjZpvEzG7Fgd9DL+3pTzkZ5jOA0v1oXUE6OlfCZG5aYEOK6pvO
# imW+UKbJsVoVD5wVOPPA6ld1Qd+WrOCCpvbW7CDosZ6uHxAjma+Nh2dxoB0oIbkI
# v4e8M8qMBed33GTt1OkobZzW5JcaJTlUny6P7Kno33luIyIDtpreaDexHuKnMVKR
# ygvVESmF8yr8YQOWiIUW6mMNrYZE47/DcDzcBxuhn7scjHPoC6uzoFnN1URctSrU
# 6gYPXTgN2AXwrjeH9F+oLQLxr2+LGAl6EMuet4ujxFLx5O2hEDM93KrcDnrKrG8/
# JxZTQfYR7h94wQOVV8FAl2SZCMD1rEmbiIBHx24sA9LJuO8SHICXxo+V6d43NX9f
# ZmeCHkMMz8Dcwor5nFKFYv7QpEHbD9NJ/35dWNPBIStyYDdsli3RLvmwGOc0D1lb
# Qk4f5b5sg6GCAg8wggILBgkqhkiG9w0BCQYxggH8MIIB+AIBATB2MGIxCzAJBgNV
# BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
# Y2VydC5jb20xITAfBgNVBAMTGERpZ2lDZXJ0IEFzc3VyZWQgSUQgQ0EtMQIQAwGa
# Ajr/WLFr1tXq5hfwZjAJBgUrDgMCGgUAoF0wGAYJKoZIhvcNAQkDMQsGCSqGSIb3
# DQEHATAcBgkqhkiG9w0BCQUxDxcNMTkxMjIzMTMxNTIzWjAjBgkqhkiG9w0BCQQx
# FgQUUCYcqKFBPy5na8c9PsGFETneQ8UwDQYJKoZIhvcNAQEBBQAEggEACIDdUN5W
# XaigxjwMeQu2v29hnWtkKDdTUATMFj+QwBpP5XYL95fxASYNC7hiiO46j4L7noja
# 72UmvLvXitvf2wrffLplwhZP/n1kcMSCiBC7E9v8U2BdGX4G9E5V3VnB9jvtQapV
# Ln6UZALLmNYK14hfSjyv9qvpUMiNd4SVQw160pIUchxeWPOaDB7MR7Ezd56teKRr
# Am8sbSWtU/guoXHN/qNa5foz0K2d+N/pVcwGm4VkohoslGR1Rrw2n0OwxV7zNZmQ
# QTN6uOCSqj2LwkWbuBRvMxc+oHjWMeSzf5E+fmR85/ha2l+TgXGY05f92ZU1JEQu
# ho4Shy+wmd3qfw==
# SIG # End signature block
