function Stop-TuneJob {
    <#
    .SYNOPSIS
    Cancels a fine-tuning job in the OpenAI API.

    .DESCRIPTION
    Sends a POST request to the OpenAI API to cancel a specified fine-tuning job.

    .PARAMETER Id
    The ID of the fine-tuning job to cancel.

    .PARAMETER WhatIf
    Shows what would happen if the cmdlet runs. The cmdlet is not run.

    .PARAMETER Confirm
    Prompts you for confirmation before running the cmdlet.

    .EXAMPLE
    Stop-TuneJob -Id job-1234

    This command cancels the fine-tuning job with the ID job-1234 in the OpenAI API.

    .EXAMPLE
    Stop-TuneJob -Id job-1234 -WhatIf

    Shows what would happen if the cmdlet runs, but does not execute the cmdlet.

    .EXAMPLE
    Stop-TuneJob -Id job-1234 -Confirm

    Prompts for confirmation before executing the cmdlet.
    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Low')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [Alias('JobId')]
        [string[]]$Id
    )
    process {
        foreach ($jobid in $Id) {
            if ($PSCmdlet.ShouldProcess("Job ID: $jobid", 'Cancel')) {
                $OpenAIParameter = Get-OpenAIAPIParameter -EndpointName Files

                $QueryUri = "{0}/fine-tunes/{1}/cancel" -f $OpenAIParameter.Uri, $jobid

                $params = @{
                    Method       = 'Post'
                    Uri          = $QueryUri
                }
                Invoke-OpenAIAPIRequest @params
            }
        }
    }
}