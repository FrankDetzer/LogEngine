

function New-LogEntry {
    param (
        [parameter(ValueFromPipeline)]
        [string]$Message,
        [validateset('Info', 'Warn', 'Error', 'Debug')]
        [string]$Level = 'Info',
        [bool]$PrintToOutput = $true,
        [bool]$PrintToFile = $true

    )

    begin {

    }

    process {    
        $global:LogObject.Data += $CurrentMessge = @(
            [pscustomobject]@{
                'TimeStamp'     = Get-Date -UFormat "%Y-%m-%d %T (UTC %Z)"
                'Level'         = $Level
                'Message'       = $Message
                'PrintToOutput' = $PrintToOutput
                'PrintToFile'   = $PrintToFile
            }
        )
    }

    end {
        $CurrentMessge | Out-LogEntry
    }

}

function Out-LogEntry {
    param (
        [parameter(ValueFromPipeline)]
        [pscustomobject]$Content
    )

    begin {
        $LogFileCreated = 
    }
    
    process {}

    end {}

    $Content # | Format-Table -HideTableHeaders
    $global:testcontent = $Content

    # $OutputMessage = ($CurrentMessge | Format-Table -HideTableHeaders | Out-String).Trim()

    # switch ($Level) {
    #     'Info' { Write-Output $OutputMessage }
    #     'Warn' { Write-Warning $OutputMessage }
    #     'Error' { Write-Error $OutputMessage }
    # }
    
    # if ($PrintToFile) {
    #     $OutputMessage | Out-File -Path $global:LogObject.Meta.FullFilePath -Encoding UTF8 -Append
    # }
}

function Initialize-Log {
    param (
        [string]$Name = 'UnnamedLog'
    )
    begin {
        $global:LogObject = @()
        $global:LogObject = [pscustomobject]@{
            Meta = @(
                [pscustomobject]@{
                    FileName     = "$($Name)_$(Get-Date -Format FileDateTimeUniversal).log"
                    FullFilePath = $PSScriptRoot + '.\' + $FileName
                    FileCreated = $false
                }
            )
            Data = @(
                [pscustomobject]@{}
            )            
        }

        $LastLogMessage = $global:LogObject.Data | Select-Object -Last 1
    }

    process {
        New-LogEntry -Level Info -PrintToOutput $true -PrintToFile $true -Message 'inizalizing starting'
        New-LogEntry -Level Info -PrintToOutput $true -PrintToFile $true -Message 'all date and time prints are in UTC, this includes the filename.'
        New-LogEntry -Level Info -PrintToOutput $true -PrintToFile $true -Message ('Computer: ' + $env:COMPUTERNAME)
        New-LogEntry -Level Info -PrintToOutput $true -PrintToFile $true -Message ('User: ' + $env:USERNAME)
        New-LogEntry -Level Info -PrintToOutput $true -PrintToFile $true -Message ('FullFilePath: ' + $global:LogObject.Meta.FullFilePath)
        New-LogEntry -Level Info -PrintToOutput $true -PrintToFile $true -Message 'inizalizing finished'                
    }

    end {
        $global:LogObject.Data | Select-Object TimeStamp, Level, Message | Out-File -Path $global:LogObject.Meta.FullFilePath -Encoding utf8
        
        $global:LogObject.Meta = Test-Path $global:LogObject.Meta.FullFilePath
}
