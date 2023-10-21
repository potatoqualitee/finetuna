function Start-TuneJob {
<#
    .SYNOPSIS
        Initiates model tuning using a specified file ID.

    .DESCRIPTION
        This command accepts a file ID to start the model tuning process via a POST request to the OpenAI API.

    .PARAMETER Id
        The file ID of the training file. This parameter allows manual specification of the file ID and can be piped in.

    .PARAMETER Model
        The model to be used for tuning. Default is 'gpt-3.5-turbo-0613'.

    .EXAMPLE
        Start-TuneJob -Id file-g8qyzvm2hxPxK1iwVaTX6Z3E

        This example demonstrates manually specifying the file ID to initiate the model tuning process.

    .EXAMPLE
        Send-TuneFile -FilePath C:\path\to\file.json | Start-TuneJob

        This example demonstrates piping the file ID to Start-TuneJob to initiate the model tuning process.
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$Id,
        [ValidateSet('gpt-3.5-turbo-0613', 'babbage-002', 'davinci-002')]
        [string]$Model = 'gpt-3.5-turbo-0613'
    )

    $body = @{
        training_file = $Id
        model         = $Model
    } | ConvertTo-Json

    $params = @{
        Uri     = "https://api.openai.com/v1/fine_tuning/jobs"
        Method  = "POST"
        Body    = $body
        ContentType = "application/json"
    }

    Invoke-RestMethod2 @params
}
