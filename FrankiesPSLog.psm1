function Initialize-Log {
    param (
        [string]$Name = 'UnnamedLog',
        [string]$FilePath = $PSScriptRoot,
        [bool]$OutputToFile = $true,
        [bool]$OutputToConsole = $true
    )

    begin {
        $FileName = $Name + '_' + (Get-Date -Format FileDateTimeUniversal) + '.log'

        $global:LogObject = @()
        $global:LogObject = [pscustomobject]@{
            Meta = @(
                [pscustomobject]@{
                    FileName          = $FileName
                    FilePath          = $FilePath + '\' + $FileName
                    OutputToFile      = $OutputToFile
                    OutputToConsole   = $OutputToConsole
                    OutputFileCreated = $false
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
        New-LogEntry -Prefix '#' -Message ('FullFilePath: ' + $global:LogObject.Meta.FullFilePath)
        New-LogEntry -Prefix '#' -Message 'Inizalizing finished'                
    }

    end {
        $global:LogObject.Data | Out-LogEntry
        $global:LogObject.Meta.OutputFileCreated = Test-Path $global:LogObject.Meta.FullFilePath
    }
}



function New-LogEntry {
    param (
        [parameter(ValueFromPipeline)]
        [string]$Message,
        [validateset('Info', 'Warn', 'Error', 'Debug')]
        [string]$Level = 'Info',
        [bool]$PrintLineToOutput = $true,
        [bool]$PrintLineToFile = $true,
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
        $global:LogObject.Data += $CurrentMessge = @(
            [pscustomobject]@{
                'TimeStamp'         = Get-Date -UFormat "%Y-%m-%d %T (UTC %Z)"
                'Index'             = "{0:d5}" -f $global:LogIndexCounter
                'Prefix'            = $Prefix
                'Level'             = $Level
                'Message'           = $Message
                # 'OutputMessage' = (("{0:d5}" -f $global:LogIndexCounter) + ' ' + $Prefix + ' ' + $Message)
                'PrintLineToOutput' = $PrintLineToOutput
                'PrintLineToFile'   = $PrintLineToFile
            }
        )
    }

    end {
        $global:LogIndexCounter++
        $CurrentMessge | Out-LogEntry
    }

}


function Out-LogEntry {
    param (
        [parameter(ValueFromPipeline)]
        [pscustomobject]$Content
    )

    begin {
        $Content | Select-Object -ExcludeProperty PrintLineToOutput, PrintLineToFile

        if ($global:OutLogEntryTriggered -ne $true) {

            if ($global:LogObject.Meta.OutputToFile) {
                $Content | Out-File -Path $global:LogObject.Meta.FilePath -Encoding utf8
            }

            $global:OutLogEntryTriggered = $true
        }



    #     $OutputMessage = ($Content | Format-Table -HideTableHeaders | Out-String).Trim()
    # }
    
    # process {
    #     Write-Information $OutputMessage
    #     Write-Verbose $OutputMessage

    #     switch ($Level) {
    #         'Info' { Write-Output $OutputMessage }
    #         'Warn' { Write-Warning $OutputMessage }
    #         'Error' { Write-Error $OutputMessage }
    #     }
    
    #     if ($PrintToFile) {
    #         $OutputMessage 
    #     }
    # }

    # end {

    # }
}