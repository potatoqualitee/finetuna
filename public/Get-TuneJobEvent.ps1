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
        foreach ($eventid in $Id) {
            $OpenAIParameter = Get-OpenAIAPIParameter -Endpoint FineTuning.JobEvents
            $params = @{
                Method       = 'GET'
                Uri          = ($OpenAIParameter.Uri -f $eventid)
                ContentType  = $OpenAIParameter.ContentType
                ApiKey       = $OpenAIParameter.ApiKey
                AuthType     = $OpenAIParameter.AuthType
                Organization = $OpenAIParameter.Organization
            }
            if ($Raw) {
                Invoke-OpenAIAPIRequest @params
            } else {
                $Response = Invoke-OpenAIAPIRequest @params
                $Response = $Response | ConvertFrom-Json
                if ($Response.data) {
                    $Response.data
                } else {
                    $Response
                }
            }
        }
    }
}