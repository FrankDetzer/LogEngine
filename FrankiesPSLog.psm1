function Initialize-Log {
    param (
        [string]$Name = 'UnnamedLog',
        [string]$FilePath = (Get-Location).Path,
        [bool]$OutputToFileEnabled = $true,
        [bool]$OutputToConsoleEnabled = $true
    )

    begin {
        $FileName = $Name + '_' + (Get-Date -Format FileDateTimeUniversal) + '.log'

        $global:LogObject = @()
        $global:LogObject = [pscustomobject]@{
            Meta = @(
                [pscustomobject]@{
                    FileName               = $FileName
                    FilePath               = $FilePath
                    FileLocation           = $FilePath + '\' + $FileName
                    OutputToFileEnabled    = $OutputToFileEnabled
                    OutputToConsoleEnabled = $OutputToConsoleEnabled
                    OutputFileCreated      = $false
                }
            )
            Data = @()            
        }
    }

    process {
        New-LogEntry -Prefix '#' -Message 'Inizalizing starting'
        New-LogEntry -Prefix '#' -Message 'All date and time prints are in UTC, this includes the filename. The date is YYYY-MM-DD, the time is HH:MM:SS'
        New-LogEntry -Prefix '#' -Message ('Computer: ' + $env:COMPUTERNAME)
        New-LogEntry -Prefix '#' -Message ('User: ' + $env:USERNAME)
        New-LogEntry -Prefix '#' -Message ('FilePath: ' + $global:LogObject.Meta.FileLocation)
        New-LogEntry -Prefix '#' -Message 'Inizalizing finished'                
    }

    end {
        $global:LogObject.Data | Out-LogEntry
        $global:LogObject.Meta.OutputFileCreated = Test-Path $global:LogObject.Meta.FileLocation
    }
}



function New-LogEntry {
    param (
        [parameter(ValueFromPipeline)]
        [string]$Message,
        [validateset('Info', 'Warn', 'Error', 'Debug')]
        [string]$Level = 'Info',
        # [bool]$LineConsoleOutputEnabled = $true,
        # [bool]$LineFileOutputEnabled = $true,
        [validateset($null, '#', '+', '-')]
        [string]$Prefix = $null

    )

    begin {
        if ($global:NewLogEntryTriggered -ne $true) {
            [uint]$global:LogIndexCounter = 1
        }
    }

    process {    
        $global:LogObject.Data += $CurrentEntry = @(
            [pscustomobject]@{
                'TimeStamp' = Get-Date -UFormat "%Y-%m-%d %T (UTC %Z)"
                'Index'     = "{0:d5}" -f $global:LogIndexCounter
                'Prefix'    = $Prefix
                'Level'     = $Level
                'Message'   = $Message
                # # 'OutputMessage' = (("{0:d5}" -f $global:LogIndexCounter) + ' ' + $Prefix + ' ' + $Message)
                # 'LineConsoleOutputEnabled' = $LineConsoleOutputEnabled
                # 'LineFileOutputEnabled'   = $LineFileOutputEnabled
            }
        )
    }

    end {
        $global:LogIndexCounter++

        if ($global:NewLogEntryTriggered -ne $true) {
            $global:NewLogEntryTriggered = $true
        }

        # $SanitisedEntry = $CurrentEntry | Select-Object -ExcludeProperty LineConsoleOutputEnabled, LineFileOutputEnabled

        # # console output
        # if ($global:LogObject.Meta.OutputToConsoleEnabled) {
        #     if ($global:NewLogEntryTriggered -ne $true) {
        #         $SanitisedEntry | Write-Output
        #     }
        #     $SanitisedEntry = ($Content | Format-Table -HideTableHeaders | Out-String).Trim() | Write-Output
        # }
        
        # # file output
        # if ($global:LogObject.Meta.OutputToFileEnabled) {
        #     if ($global:NewLogEntryTriggered -ne $true) {
        #         $SanitisedEntry | Out-File -Path $global:LogObject.Meta.FilePath -Encoding utf8
        #     }
        #     $SanitisedEntry = ($Content | Format-Table -HideTableHeaders | Out-String).Trim() | Out-File -Path $global:LogObject.Meta.FilePath -Encoding utf8 -Append
        # }
    }
}


function Out-LogEntry {
    param (
        [parameter(ValueFromPipeline)]
        [pscustomobject]$Content
    )

    begin {
        $SanitisedEntry = $Content | Select-Object -ExcludeProperty LineConsoleOutputEnabled, LineFileOutputEnabled
    }
    
    process {
        # console output
        if ($global:LogObject.Meta.OutputToConsoleEnabled) {
            if ($global:OutLogEntryTriggered -ne $true) {
                $SanitisedEntry | Write-Output
            }
            $SanitisedEntry = ($Content | Format-Table -HideTableHeaders | Out-String).Trim() | Write-Output
        }
        
        # file output
        if ($global:LogObject.Meta.OutputToFileEnabled) {
            # $OutputFile = New-Item -Path $global:LogObject.Meta.FilePath -Name $global:LogObject.Meta.FileName

            if ($global:OutLogEntryTriggered -ne $true) {
                $SanitisedEntry | Out-File -Path $global:LogObject.Meta.FileLocation -Encoding utf8
            }
            $SanitisedEntry = ($Content | Format-Table -HideTableHeaders | Out-String).Trim() | Out-File -Path $global:LogObject.Meta.FileLocation -Encoding utf8 -Append
        }
    }

    end {
        if ($global:OutLogEntryTriggered -ne $true) {
            $global:OutLogEntryTriggered = $true
        }
    }
}


# function Out-LogEntry {
#     param (
#         [parameter(ValueFromPipeline)]
#         [pscustomobject]$Content
#     )

#     begin {
#         $SanitisedContent = $Content | Select-Object -ExcludeProperty LineConsoleOutputEnabled, LineFileOutputEnabled

#         if ($global:OutLogEntryTriggered -ne $true) {

#             if ($global:LogObject.Meta.OutputToFileEnabled) {
#                 $SanitisedContent | Out-File -Path $global:LogObject.Meta.FilePath -Encoding utf8
#             }

#             $global:OutLogEntryTriggered = $true
#         }

#         if ($global:LogObject.Meta.)



#         #     $OutputMessage = ($Content | Format-Table -HideTableHeaders | Out-String).Trim()
#         # }
    
#         # process {
#         #     Write-Information $OutputMessage
#         #     Write-Verbose $OutputMessage

#         #     switch ($Level) {
#         #         'Info' { Write-Output $OutputMessage }
#         #         'Warn' { Write-Warning $OutputMessage }
#         #         'Error' { Write-Error $OutputMessage }
#         #     }
    
#         #     if ($PrintToFile) {
#         #         $OutputMessage 
#         #     }
#         # }

#         # end {

#         # }
#     }