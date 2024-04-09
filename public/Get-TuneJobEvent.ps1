function Get-TuneJobEvent {
    <#
    .SYNOPSIS
    Retrieves a specific fine-tuning event from the API.

    .DESCRIPTION
    Sends a GET request to the API to retrieve a specified fine-tuning event.

    .PARAMETER Id
    The fine-tuning job object to retrieve its event.

    .EXAMPLE
    Get-ModelFineTune -Id "job-1234" | Get-TuneJobEvent

    This command retrieves the fine-tuning event of the job with the ID job-1234 from the API.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string[]]$Id
    )
    process {
        foreach ($jobid in $Id) {
            $params = @{
                #https://api.openai.com/v1/fine_tuning/jobs/ftjob-abc123/events
                Uri    = "$script:baseUrl/fine_tuning/jobs/$jobid/events?limit=1000"
                Method     = "GET"
            }
            Invoke-RestMethod2 @params

        }
    }
}