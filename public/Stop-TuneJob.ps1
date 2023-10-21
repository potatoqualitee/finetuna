function Stop-TuneJob {
    <#
    .SYNOPSIS
    Cancels a fine-tuning job in the OpenAI API.

    .DESCRIPTION
    Sends a POST request to the OpenAI API to cancel a specified fine-tuning job.

    .PARAMETER Id
    The ID of the fine-tuning job to cancel.

    .EXAMPLE
    Stop-TuneJob -Id job-1234

    This command cancels the fine-tuning job with the ID job-1234 in the OpenAI API.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$Id
    )

    process {
        if (-not $script:WebSession) {
            $null = Connect-TuneService
        }

        $params = @{
            Uri        = "https://api.openai.com/v1/fine-tuning/jobs/$Id/cancel"
            Method     = "POST"
        }
        Invoke-RestMethod2 @params
    }
}