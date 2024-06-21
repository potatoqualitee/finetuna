function Get-TuneJob {
    <#
    .SYNOPSIS
    Gets a list or a specific fine-tuning job from the OpenAI API.

    .DESCRIPTION
    The Get-TuneJob cmdlet sends a GET request to the OpenAI API to retrieve a list of fine-tuning jobs or a specific job.

    .PARAMETER Id
    Optional ID of the fine-tuning job to retrieve.

    .PARAMETER Raw
    Optional switch to return the raw response from the API.

    .EXAMPLE
    Get-TuneJob

    This command gets a list of fine-tuning jobs from the OpenAI API.

    .EXAMPLE
    Get-TuneJob -Id "job-1234"

    This command retrieves the fine-tuning job with the ID "job-1234" from the OpenAI API.
    #>

    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias("training_file", "JobId")]
        [string]$Id,
        [switch]$Raw
    )
    process {
        if ($Id) {
            $url = "$script:baseUrl/fine-tunes/$Id"
            $params = @{
                Uri    = $url
                Method = "GET"
            }
            if ($Raw) {
                $params['Raw'] = $true
            }
            Invoke-OpenAIAPIRequest @params
        } else {
            $url = "$script:baseUrl/fine-tunes"
            $params = @{
                Uri    = $url
                Method = "GET"
            }
            if ($Raw) {
                $params['Raw'] = $true
            }
            Invoke-OpenAIAPIRequest @params
        }
    }
}