﻿function Initialize-Log {
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
                    # OutputFileCreated      = $false
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
        # $global:LogObject.Meta.OutputFileCreated = Test-Path $global:LogObject.Meta.FileLocation
    }
}



function New-LogEntry {
    param (
        [parameter(ValueFromPipeline)]
        [string]$Message,
        [validateset('Info', 'Warn', 'Error', 'Debug')]
        [string]$Level = 'Info',
        [validateset($null, '#', '+', '-')]
        [string]$Prefix = $null

    )

    begin {
        if ($global:NewLogEntryTriggered -ne $true) {
            [uint]$global:LogIndexCounter = 1
            $global:NewLogEntryTriggered = $true
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
            }
        )
    }

    end {
        $global:LogIndexCounter++
        $CurrentEntry | Out-LogEntry
    }
}


function Out-LogEntry {
    param (
        [parameter(ValueFromPipeline)]
        [pscustomobject]$Content
    )

    begin {
        $SanitisedEntry = $Content | Select-Object -ExcludeProperty LineConsoleOutputEnabled, LineFileOutputEnabled
        $SanitisedString = ($SanitisedEntry | Format-Table -HideTableHeaders | Out-String).Trim()
    }
    
    process {
        # console output
        if ($global:LogObject.Meta.OutputToConsoleEnabled) {
            if ($global:OutLogEntryTriggered -ne $true) {
                $SanitisedEntry | Write-Output
            }
            $SanitisedString | Write-Output
        }
        
        # file output
        if ($global:LogObject.Meta.OutputToFileEnabled) {
            if ($global:OutLogEntryTriggered -ne $true) {
                $SanitisedEntry | Out-File -Path $global:LogObject.Meta.FileLocation -Encoding utf8
            }
            $SanitisedString | Out-File -Path $global:LogObject.Meta.FileLocation -Encoding utf8 -Append
        }
    }

    end {
        if ($global:OutLogEntryTriggered -ne $true) {
            $global:OutLogEntryTriggered = $true
        }
    }
}