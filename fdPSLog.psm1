
###
# setup of basic parameters
$global:NewLogEntryTriggered = $false
$global:OutLogEntryTriggered = $false


function Start-Log {
    param (
        [string]$Name = 'UnnamedLog',
        [string]$FilePath = (Get-Location).Path,
        [bool]$OutputToFileEnabled = $true,
        [bool]$OutputToConsoleEnabled = $true
    )

    begin {
        $LogGuid = (New-Guid).Guid
        $FileName = $Name + '_' + (Get-Date -Format FileDateTimeUniversal) + '.log'

        $global:LogObject = @()
        $global:LogObject = [pscustomobject]@{
            Meta = @(
                [pscustomobject]@{
                    LogGuid = $LogGuid
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
        Add-Log -Prefix '#' -Message 'Inizalizing starting'
        Add-Log -Prefix '#' -Message 'All date and time prints are in UTC, this includes the filename. The date is YYYY-MM-DD, the time is HH:MM:SS'
        Add-Log -Prefix '#' -Message ('Log Guid: ' + $LogGuid)
        Add-Log -Prefix '#' -Message ('Computer: ' + $env:COMPUTERNAME)
        Add-Log -Prefix '#' -Message ('User: ' + $env:USERNAME)
        Add-Log -Prefix '#' -Message ('FilePath: ' + $global:LogObject.Meta.FileLocation)
        Add-Log -Prefix '#' -Message 'Inizalizing finished'                
    }

    end {
        # $global:LogObject.Meta.OutputFileCreated = Test-Path $global:LogObject.Meta.FileLocation
    }
}



function Add-Log {
    param (
        [parameter(ValueFromPipeline)]
        [string]$Message,
        [validateset('Info', 'Warn', 'Error', 'Debug')]
        [string]$Level = 'Info',
        [validateset($null, '#', '+', '-')]
        [string]$Prefix = $null

    )

    begin {
        if ($global:NewLogEntryTriggered -eq $false) {
            [uint]$global:LogIndexCounter = 1
            $global:NewLogEntryTriggered = $true
        }
    }

    process {    
        $global:LogObject.Data += $CurrentEntry = @(
            [pscustomobject]@{
                'TimeStamp' = Get-Date -UFormat "%Y-%m-%d %T (UTC %Z)"
                'Index'     = "{0:d5}" -f $global:LogIndexCounter
                'Level'     = $Level
                'Prefix'    = $Prefix
                'Message'   = $Message
            }
        )
    }

    end {
        $global:LogIndexCounter++
        Out-LogEntry -InputObject $CurrentEntry
    }
}


function Out-LogEntry {
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
        [pscustomobject[]]$InputObject
    )

    begin {
        $SanitisedInputObject = $InputObject | Select-Object -ExcludeProperty OutputToFileEnabled, OutputToConsoleEnabled
        $SanitisedInputObjectHead = ($SanitisedInputObject | Format-Table -AutoSize | Out-String).Trim()
        $SanitisedInputObjectBody = ($SanitisedInputObject | Format-Table -HideTableHeaders | Out-String).Trim()
    }
    
    process {
        # console output
        if ($global:LogObject.Meta.OutputToConsoleEnabled) {
            if ($global:OutLogEntryTriggered -eq $false) {
                $SanitisedInputObjectHead
            }
            if ($global:OutLogEntryTriggered -eq $true) {
                $SanitisedInputObjectBody
            }
        }
        
        # file output
        if ($global:LogObject.Meta.OutputToFileEnabled) {
            if ($global:OutLogEntryTriggered -eq $false) {
                $SanitisedInputObjectHead | Out-File -Path $global:LogObject.Meta.FileLocation -Encoding utf8
            }
            if ($global:OutLogEntryTriggered -eq $true) {
                $SanitisedInputObjectBody | Out-File -Path $global:LogObject.Meta.FileLocation -Encoding utf8 -Append
            }
        }
    }

    end {
        if ($global:OutLogEntryTriggered -eq $false) {
            $global:OutLogEntryTriggered = $true
        }
    }
}

function Stop-Log {
    Add-Log -Prefix '#' -Message 'stopped loggin'
}