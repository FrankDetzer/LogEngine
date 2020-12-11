

function New-LogEntry {
    param (
        [parameter(ValueFromPipeline)]
        [string]$Input,
        [validateset('Info', 'Warn', 'Error', 'Debug')],
        [string]$Level = "Info",
        [Switch]$PrintToFile = $false

    )

    $CurrentMessge = $LogObject.Data += @(
        [pscustomobject]@{
            'TimeStamp'   = Get-Date -UFormat "%Y-%m-%d %T (UTC %Z)"
            'Level'       = $Level
            'PrintToFile' = $PrintToFile
            'Message'     = $Input
        }
    )

}

function Out-LogEntry {
    param (
        [validateset('Info', 'Warn', 'Error', 'Debug')],
        [string]$Level = "Info",
        [switch]$PrintToFile = $true
    )

    $OutputMessage = ($CurrentMessge | Format-Table -HideTableHeaders | Out-String).Trim()

    switch ($Level) {
        'Info' { Write-Output $OutputMessage }
        'Warn' { Write-Warning $OutputMessage }
        'Error' { Write-Error $OutputMessage }
    }
    
    if ($PrintToFile) {
        $OutputMessage | Out-File -Path $LogObject.Meta.FullFilePath -Encoding UTF8 -Append
    }
}

function Initialize-Log {
    param (
        [string]$Name = 'UnnamedLog'
    )
    begin {
        $LogObject = @()
        $LogObject = [pscustomobject]@{
            Meta = @(
                [pscustomobject]@{
                    FileName     = "$($Name)_$(Get-Date -Format FileDateTimeUniversal).log"
                    FullFilePath = $PSScriptRoot + '.\' + $FileName
                }
            )
            Data = @(
                [pscustomobject]@{
                    'TimeStamp'   = Get-Date -UFormat "%Y-%m-%d %T (UTC %Z)"
                    'Level'       = 'Info'
                    'PrintToFile' = $true
                    'Message'     = 'starting inizalizing'
                }
            )
            
        }
        $LastLogMessage = $LogObject.Data | Select-Object -Last 1
    }

    process {
        $LogObject.Data += @(
            [pscustomobject]@{
                'TimeStamp'   = Get-Date -UFormat "%Y-%m-%d %T (UTC %Z)"
                'Level'       = 'Info'
                'PrintToFile' = $true
                'Message'     = 'all date and time prints are in UTC, this includes the filename.'
            }
        )

        $LogObject.Data += @(
            [pscustomobject]@{
                'TimeStamp'   = Get-Date -UFormat "%Y-%m-%d %T (UTC %Z)"
                'Level'       = 'Info'
                'PrintToFile' = $true
                'Message'     = 'Computer: ' + $env:COMPUTERNAME
            }
        )

        $LogObject.Data += @(
            [pscustomobject]@{
                'TimeStamp'   = Get-Date -UFormat "%Y-%m-%d %T (UTC %Z)"
                'Level'       = 'Info'
                'PrintToFile' = $true
                'Message'     = 'User: ' + $env:USERNAME
            }
        )
                
        $LogObject.Data += @(
            [pscustomobject]@{
                'TimeStamp'   = Get-Date -UFormat "%Y-%m-%d %T (UTC %Z)"
                'Level'       = 'Info'
                'PrintToFile' = $true
                'Message'     = 'FullFilePath: ' + $LogObject.Meta.FullFilePath
            }
        )
        $LastLogMessage = $LogObject.Data | Select-Object -Last 1
                
    }

    end {
        $LogObject.Data += @(
            [pscustomobject]@{
                'TimeStamp'   = Get-Date -Format FileDateTimeUniversal
                'Level'       = 'Info'
                'PrintToFile' = $true
                'Message'     = 'finished inizalizing'
            }
        )
        $LastLogMessage = $LogObject.Data | Select-Object -Last 1

        $LogObject.Data | Select-Object -ExcludeProperty PrintToFile | Out-File -Path $LogObject.FullFilePath
    }
}
